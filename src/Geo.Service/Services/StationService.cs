using System.Linq.Expressions;
using Geo.Service.Entities;
using Geo.Service.Enums;
using Geo.Service.Models;
using Geo.Service.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace Geo.Service.Services
{
    /// <summary>
    /// YouBike 站點查詢。
    /// </summary>
    public interface IStationService
    {
        /// <summary>
        /// 查詢站點列表（篩選、排序、分頁）。
        /// </summary>
        Task<ResultModel<PagedResult<StationVM>>> Index(StationSearchVM vm);

        /// <summary>
        /// 取得單一站點詳情。
        /// </summary>
        /// <param name="sno">站點編號</param>
        Task<ResultModel<StationVM>> Get(string sno);

        /// <summary>
        /// 取得行政區與站數（下拉選單用）。
        /// </summary>
        Task<ResultModel<List<DistrictVM>>> Districts();

        /// <summary>
        /// 取得離指定座標最近的 N 個營運中站點（含公尺距離）。
        /// </summary>
        Task<ResultModel<List<NearestStationVM>>> Nearest(NearestSearchVM vm);

        /// <summary>
        /// 取得地圖用的全部站點（精簡欄位，含停用站點）。
        /// </summary>
        Task<ResultModel<List<StationMapVM>>> Map();

        /// <summary>
        /// 取得資料更新狀態（來源資料時間、最近同步結果）。
        /// </summary>
        Task<ResultModel<StatusVM>> Status();

        /// <summary>
        /// 取得單站最近 N 小時的車輛數變化（只含數量有變動的時間點，由舊到新）。
        /// </summary>
        Task<ResultModel<List<StationHistoryVM>>> History(HistorySearchVM vm);
    }

    public class StationService : IStationService
    {
        private readonly GeoDbContext _db;
        private readonly ISyncStatusTracker _status;

        public StationService(GeoDbContext db, ISyncStatusTracker status)
        {
            _db = db;
            _status = status;
        }

        public async Task<ResultModel<StatusVM>> Status()
        {
            var dataUpdatedAt = await _db.YoubikeStations.AsNoTracking().MaxAsync(s => s.Updated);

            return ResultModel<StatusVM>.Success(new StatusVM
            {
                DataUpdatedAt = dataUpdatedAt,
                LastSyncAt = _status.LastSuccessAt,
                LastError = _status.LastError
            });
        }

        public async Task<ResultModel<List<StationHistoryVM>>> History(HistorySearchVM vm)
        {
            var station = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.Sno == vm.Sno)
                .Select(s => new { s.Bikes, s.Docks })
                .FirstOrDefaultAsync();
            if (station == null)
            {
                return ResultModel<List<StationHistoryVM>>.Error(ErrorCodeType.NotFoundData);
            }

            var since = DateTime.UtcNow.AddHours(-vm.Hours);
            var items = await _db.YoubikeSnapshots.AsNoTracking()
                .Where(h => h.Sno == vm.Sno && h.RecordedAt >= since)
                .OrderBy(h => h.RecordedAt)
                .Select(h => new StationHistoryVM
                {
                    RecordedAt = h.RecordedAt,
                    Bikes = h.Bikes,
                    Docks = h.Docks
                })
                .ToListAsync();

            // 只有「變動時」才有紀錄，所以區間起點要補上當時的值，否則沒變動的站會是空圖：
            // 優先用區間前最後一筆快照，沒有（例如快照剛開始累積）就用目前的值
            var before = await _db.YoubikeSnapshots.AsNoTracking()
                .Where(h => h.Sno == vm.Sno && h.RecordedAt < since)
                .OrderByDescending(h => h.RecordedAt)
                .Select(h => new StationHistoryVM { RecordedAt = since, Bikes = h.Bikes, Docks = h.Docks })
                .FirstOrDefaultAsync();

            if (before == null && items.Count == 0)
            {
                before = new StationHistoryVM { RecordedAt = since, Bikes = station.Bikes ?? 0, Docks = station.Docks ?? 0 };
            }

            if (before != null)
            {
                items.Insert(0, before);
            }

            return ResultModel<List<StationHistoryVM>>.Success(items);
        }

        public async Task<ResultModel<PagedResult<StationVM>>> Index(StationSearchVM vm)
        {
            var query = _db.YoubikeStations.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(vm.District))
            {
                query = query.Where(s => s.District == vm.District);
            }

            if (!string.IsNullOrWhiteSpace(vm.Keyword))
            {
                // 跳脫 LIKE 萬用字元，避免使用者輸入 % 或 _ 時比對到全部
                var keyword = vm.Keyword.Trim()
                    .Replace("\\", "\\\\").Replace("%", "\\%").Replace("_", "\\_");
                var pattern = $"%{keyword}%";
                query = query.Where(s => EF.Functions.ILike(s.Name ?? "", pattern)
                    || EF.Functions.ILike(s.Address ?? "", pattern));
            }

            if (vm.OnlyAvailable)
            {
                query = query.Where(s => s.Active == 1 && s.Bikes > 0);
            }

            var totalCount = await query.CountAsync();

            var items = await ApplySort(query, vm.SortColumn, vm.SortDirection)
                .Skip((vm.PageNumber - 1) * vm.PageSize)
                .Take(vm.PageSize)
                .Select(s => new StationVM
                {
                    Sno = s.Sno,
                    Name = s.Name,
                    NameEn = s.NameEn,
                    District = s.District,
                    Address = s.Address,
                    Total = s.Total,
                    Bikes = s.Bikes,
                    Docks = s.Docks,
                    IsActive = s.Active == 1,
                    Updated = s.Updated,
                    Lat = s.Geom != null ? s.Geom.Y : null,
                    Lon = s.Geom != null ? s.Geom.X : null
                })
                .ToListAsync();

            return ResultModel<PagedResult<StationVM>>.Success(new PagedResult<StationVM>
            {
                Items = items,
                PageNumber = vm.PageNumber,
                PageSize = vm.PageSize,
                TotalCount = totalCount
            });
        }

        public async Task<ResultModel<StationVM>> Get(string sno)
        {
            var station = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.Sno == sno)
                .Select(s => new StationVM
                {
                    Sno = s.Sno,
                    Name = s.Name,
                    NameEn = s.NameEn,
                    District = s.District,
                    Address = s.Address,
                    Total = s.Total,
                    Bikes = s.Bikes,
                    Docks = s.Docks,
                    IsActive = s.Active == 1,
                    Updated = s.Updated,
                    Lat = s.Geom != null ? s.Geom.Y : null,
                    Lon = s.Geom != null ? s.Geom.X : null
                })
                .FirstOrDefaultAsync();

            return station == null
                ? ResultModel<StationVM>.Error(ErrorCodeType.NotFoundData)
                : ResultModel<StationVM>.Success(station);
        }

        public async Task<ResultModel<List<DistrictVM>>> Districts()
        {
            var districts = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.District != null)
                .GroupBy(s => s.District!)
                .Select(g => new DistrictVM { District = g.Key, StationCount = g.Count() })
                .OrderBy(d => d.District)
                .ToListAsync();

            return ResultModel<List<DistrictVM>>.Success(districts);
        }

        public async Task<ResultModel<List<NearestStationVM>>> Nearest(NearestSearchVM vm)
        {
            // 兩段式 KNN：內層 geom <-> 點 吃 GiST 索引，但以「度」排序，東西向會高估，
            // 所以多取 3 倍候選，外層再用 geography 算出的公尺距離重排。
            // NetTopologySuite 的 Point 與 ST_MakePoint 都是 (經度, 緯度)。
            var candidates = vm.N * 3;
            var rows = await _db.Database.SqlQuery<NearestStationVM>($@"
                SELECT * FROM (
                    SELECT sno AS ""Sno"", name AS ""Name"", name_en AS ""NameEn"",
                           district AS ""District"", address AS ""Address"",
                           total AS ""Total"", bikes AS ""Bikes"", docks AS ""Docks"",
                           (active = 1) AS ""IsActive"", updated AS ""Updated"",
                           ST_Y(geom) AS ""Lat"", ST_X(geom) AS ""Lon"",
                           round(ST_Distance(geom::geography,
                                 ST_SetSRID(ST_MakePoint({vm.Lon}, {vm.Lat}), 4326)::geography)) AS ""DistM""
                    FROM youbike_stations
                    WHERE active = 1
                    ORDER BY geom <-> ST_SetSRID(ST_MakePoint({vm.Lon}, {vm.Lat}), 4326)
                    LIMIT {candidates}
                ) c
                ORDER BY ""DistM""
                LIMIT {vm.N}")
                .ToListAsync();

            return ResultModel<List<NearestStationVM>>.Success(rows);
        }

        public async Task<ResultModel<List<StationMapVM>>> Map()
        {
            // 前端一次畫出全部站點，所以只取畫圖需要的欄位，並以 Id 排序讓結果穩定
            var stations = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.Geom != null)
                .OrderBy(s => s.Id)
                .Select(s => new StationMapVM
                {
                    Sno = s.Sno,
                    District = s.District,
                    Bikes = s.Bikes,
                    IsActive = s.Active == 1,
                    Lat = s.Geom != null ? s.Geom.Y : null,
                    Lon = s.Geom != null ? s.Geom.X : null
                })
                .ToListAsync();

            return ResultModel<List<StationMapVM>>.Success(stations);
        }

        /// <summary>
        /// 排序欄位用白名單，不接受前端任意欄位名稱；未知欄位退回 Sno。
        /// </summary>
        private static IQueryable<YoubikeStation> ApplySort(
            IQueryable<YoubikeStation> query, string column, string direction)
        {
            var desc = string.Equals(direction, "desc", StringComparison.OrdinalIgnoreCase);

            IOrderedQueryable<YoubikeStation> Order<TKey>(Expression<Func<YoubikeStation, TKey>> key)
            {
                return desc ? query.OrderByDescending(key) : query.OrderBy(key);
            }

            var ordered = column.ToLowerInvariant() switch
            {
                "name" => Order(s => s.Name),
                "district" => Order(s => s.District),
                "bikes" => Order(s => s.Bikes),
                "docks" => Order(s => s.Docks),
                "updated" => Order(s => s.Updated),
                _ => Order(s => s.Sno)
            };

            // 加上 Id 當次要排序，分頁結果才穩定
            return ordered.ThenBy(s => s.Id);
        }
    }
}
