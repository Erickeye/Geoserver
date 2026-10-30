using Geo.Service.Entities;
using Geo.Service.Options;
using Geo.Service.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace Geo.API.HealthChecks
{
    /// <summary>
    /// 檢查資料庫連線，以及資料是否過期（最近一次成功同步超過 3 個間隔視為不健康）。
    /// </summary>
    public class SyncHealthCheck : IHealthCheck
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ISyncStatusTracker _status;
        private readonly YouBikeOptions _options;
        private static readonly DateTime StartedAt = DateTime.UtcNow;

        public SyncHealthCheck(
            IServiceScopeFactory scopeFactory,
            ISyncStatusTracker status,
            IOptions<YouBikeOptions> options)
        {
            _scopeFactory = scopeFactory;
            _status = status;
            _options = options.Value;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<GeoDbContext>();

            if (!await db.Database.CanConnectAsync(cancellationToken))
            {
                return HealthCheckResult.Unhealthy("資料庫無法連線");
            }

            // 沒開定時更新時只檢查資料庫
            if (!_options.Enabled)
            {
                return HealthCheckResult.Healthy("資料庫正常（定時更新已停用）");
            }

            var limit = TimeSpan.FromSeconds(Math.Max(10, _options.RefreshIntervalSeconds) * 3);
            var lastSuccess = _status.LastSuccessAt;

            if (lastSuccess == null)
            {
                // 剛啟動、第一次同步還沒完成：給一段寬限期
                return DateTime.UtcNow - StartedAt > limit
                    ? HealthCheckResult.Unhealthy($"啟動後尚未同步成功：{_status.LastError}")
                    : HealthCheckResult.Degraded("尚未完成第一次同步");
            }

            return DateTime.UtcNow - lastSuccess > limit
                ? HealthCheckResult.Unhealthy($"資料已過期，最近成功同步 {lastSuccess:O}：{_status.LastError}")
                : HealthCheckResult.Healthy($"最近成功同步 {lastSuccess:O}");
        }
    }
}
