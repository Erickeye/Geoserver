using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Geo.Service.Entities;
using Geo.Service.Enums;
using Geo.Service.Models;
using Geo.Service.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Geo.Service.Services
{
    /// <summary>
    /// 抓取 YouBike 即時資料並更新到資料庫。
    /// </summary>
    public interface IYouBikeSyncService
    {
        /// <summary>
        /// 抓取最新 JSON 並 upsert 站點；回傳處理的站數。
        /// </summary>
        Task<ResultModel<int>> Sync(CancellationToken cancellationToken = default);
    }

    public class YouBikeSyncService : IYouBikeSyncService
    {
        private const string NamePrefix = "YouBike2.0_";

        // 來源時間為台北當地時間且不帶時區；台灣沒有日光節約時間，固定 +8
        private static readonly TimeSpan TaipeiOffset = TimeSpan.FromHours(8);

        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            NumberHandling = JsonNumberHandling.AllowReadingFromString
        };

        private readonly HttpClient _http;
        private readonly GeoDbContext _db;
        private readonly YouBikeOptions _options;
        private readonly ISyncStatusTracker _status;
        private readonly ILogger<YouBikeSyncService> _logger;

        public YouBikeSyncService(
            HttpClient http,
            GeoDbContext db,
            IOptions<YouBikeOptions> options,
            ISyncStatusTracker status,
            ILogger<YouBikeSyncService> logger)
        {
            _http = http;
            _db = db;
            _options = options.Value;
            _status = status;
            _logger = logger;
        }

        public async Task<ResultModel<int>> Sync(CancellationToken cancellationToken = default)
        {
            try
            {
                return await SyncCore(cancellationToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                // 例外仍往外丟（由 RefreshService 記錄），這裡只留狀態給健康檢查
                _status.MarkFailure(ex.Message);
                throw;
            }
        }

        private async Task<ResultModel<int>> SyncCore(CancellationToken cancellationToken)
        {
            var source = await _http.GetFromJsonAsync<List<YouBikeSource>>(
                _options.Url, JsonOptions, cancellationToken);

            if (source == null || source.Count == 0)
            {
                _logger.LogWarning("YouBike 來源沒有資料 {Url}", _options.Url);
                _status.MarkFailure("來源沒有資料");
                return ResultModel<int>.Error(ErrorCodeType.SystemError, "來源沒有資料");
            }

            // 沒有座標的站無法上圖；同一個 sno 重複時只留一筆，否則 ON CONFLICT 會整批失敗
            var stations = source
                .Where(s => !string.IsNullOrEmpty(s.Sno) && s.Latitude != 0 && s.Longitude != 0)
                .GroupBy(s => s.Sno)
                .Select(g => g.Last())
                .ToList();

            var snos = stations.Select(s => s.Sno).ToArray();
            var names = stations.Select(s => StripPrefix(s.Name)).ToArray();
            var namesEn = stations.Select(s => StripPrefix(s.NameEn)).ToArray();
            var districts = stations.Select(s => s.District).ToArray();
            var addresses = stations.Select(s => s.Address).ToArray();
            var totals = stations.Select(s => s.Quantity).ToArray();
            var bikes = stations.Select(s => s.AvailableRentBikes).ToArray();
            var docks = stations.Select(s => s.AvailableReturnBikes).ToArray();
            var actives = stations.Select(s => s.Act == "1" ? 1 : 0).ToArray();
            var updated = stations.Select(s => ParseTaipeiTime(s.UpdateTime)).ToArray();
            var lons = stations.Select(s => s.Longitude).ToArray();
            var lats = stations.Select(s => s.Latitude).ToArray();

            // 快照與 upsert 放同一個交易：快照要在 upsert 之前，才能和「目前的值」比較
            await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);

            if (_options.SnapshotRetentionDays > 0)
            {
                // 只在可借／可還有變動（或新站）時寫一筆；recorded_at 用來源更新時間，
                // 同一版資料重複抓到時由主鍵 (sno, recorded_at) 擋掉
                await _db.Database.ExecuteSqlInterpolatedAsync($@"
                    INSERT INTO youbike_snapshots (sno, bikes, docks, recorded_at)
                    SELECT t.sno, t.bikes, t.docks, t.updated
                    FROM unnest({snos}, {bikes}, {docks}, {updated}) AS t(sno, bikes, docks, updated)
                    LEFT JOIN youbike_stations s ON s.sno = t.sno
                    WHERE s.sno IS NULL OR s.bikes <> t.bikes OR s.docks <> t.docks
                    ON CONFLICT (sno, recorded_at) DO NOTHING", cancellationToken);

                var cutoff = DateTime.UtcNow.AddDays(-_options.SnapshotRetentionDays);
                await _db.Database.ExecuteSqlInterpolatedAsync(
                    $"DELETE FROM youbike_snapshots WHERE recorded_at < {cutoff}", cancellationToken);
            }

            // 單一陳述式批次 upsert（unnest 陣列參數），避免上千次來回；全程參數化
            await _db.Database.ExecuteSqlInterpolatedAsync($@"
                INSERT INTO youbike_stations
                    (sno, name, name_en, district, address, total, bikes, docks, active, updated, geom)
                SELECT t.sno, t.name, t.name_en, t.district, t.address, t.total, t.bikes, t.docks,
                       t.active, t.updated, ST_SetSRID(ST_MakePoint(t.lon, t.lat), 4326)
                FROM unnest({snos}, {names}, {namesEn}, {districts}, {addresses},
                            {totals}, {bikes}, {docks}, {actives}, {updated}, {lons}, {lats})
                    AS t(sno, name, name_en, district, address, total, bikes, docks, active, updated, lon, lat)
                ON CONFLICT (sno) DO UPDATE SET
                    name = EXCLUDED.name,
                    name_en = EXCLUDED.name_en,
                    district = EXCLUDED.district,
                    address = EXCLUDED.address,
                    total = EXCLUDED.total,
                    bikes = EXCLUDED.bikes,
                    docks = EXCLUDED.docks,
                    active = EXCLUDED.active,
                    updated = EXCLUDED.updated,
                    geom = EXCLUDED.geom", cancellationToken);

            await transaction.CommitAsync(cancellationToken);
            _status.MarkSuccess();

            _logger.LogInformation("YouBike 更新完成 {Count} / {Total} 站", stations.Count, source.Count);
            return ResultModel<int>.Success(stations.Count);
        }

        private static string StripPrefix(string name)
        {
            return name.StartsWith(NamePrefix, StringComparison.Ordinal) ? name[NamePrefix.Length..] : name;
        }

        private static DateTime ParseTaipeiTime(string value)
        {
            if (!DateTime.TryParse(value, out var local))
            {
                return DateTime.UtcNow;
            }

            return new DateTimeOffset(DateTime.SpecifyKind(local, DateTimeKind.Unspecified), TaipeiOffset).UtcDateTime;
        }

        /// <summary>
        /// 來源 JSON 的欄位（只取需要的）。
        /// </summary>
        private class YouBikeSource
        {
            [JsonPropertyName("sno")] public string Sno { get; set; } = string.Empty;
            [JsonPropertyName("sna")] public string Name { get; set; } = string.Empty;
            [JsonPropertyName("snaen")] public string NameEn { get; set; } = string.Empty;
            [JsonPropertyName("sarea")] public string District { get; set; } = string.Empty;
            [JsonPropertyName("ar")] public string Address { get; set; } = string.Empty;
            [JsonPropertyName("act")] public string Act { get; set; } = string.Empty;
            [JsonPropertyName("Quantity")] public int Quantity { get; set; }
            [JsonPropertyName("available_rent_bikes")] public int AvailableRentBikes { get; set; }
            [JsonPropertyName("available_return_bikes")] public int AvailableReturnBikes { get; set; }
            [JsonPropertyName("latitude")] public double Latitude { get; set; }
            [JsonPropertyName("longitude")] public double Longitude { get; set; }
            [JsonPropertyName("updateTime")] public string UpdateTime { get; set; } = string.Empty;
        }
    }
}
