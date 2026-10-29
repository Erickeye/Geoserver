using Geo.Service.Options;
using Geo.Service.Services;
using Microsoft.Extensions.Options;

namespace Geo.API.BackgroundServices
{
    /// <summary>
    /// 定時更新 YouBike 資料；單次失敗只記錄，下一輪繼續。
    /// </summary>
    public class YouBikeRefreshService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly YouBikeOptions _options;
        private readonly ILogger<YouBikeRefreshService> _logger;

        public YouBikeRefreshService(
            IServiceScopeFactory scopeFactory,
            IOptions<YouBikeOptions> options,
            ILogger<YouBikeRefreshService> logger)
        {
            _scopeFactory = scopeFactory;
            _options = options.Value;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var interval = TimeSpan.FromSeconds(Math.Max(10, _options.RefreshIntervalSeconds));
            using var timer = new PeriodicTimer(interval);

            // 啟動時先更新一次，之後每個間隔一次
            do
            {
                await RunOnce(stoppingToken);
            }
            while (await WaitNextTick(timer, stoppingToken));
        }

        private async Task RunOnce(CancellationToken stoppingToken)
        {
            try
            {
                // BackgroundService 是 Singleton，Scoped 的 DbContext 要自己建 scope 取得
                using var scope = _scopeFactory.CreateScope();
                var sync = scope.ServiceProvider.GetRequiredService<IYouBikeSyncService>();
                var result = await sync.Sync(stoppingToken);

                if (!result.IsSuccess)
                {
                    _logger.LogWarning("YouBike 更新失敗 {ErrorCode} {ErrorMessage}", result.ErrorCode, result.ErrorMessage);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                // 應用程式關閉中，不算錯誤
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "YouBike 更新發生例外，等待下一輪");
            }
        }

        private static async Task<bool> WaitNextTick(PeriodicTimer timer, CancellationToken stoppingToken)
        {
            try
            {
                return await timer.WaitForNextTickAsync(stoppingToken);
            }
            catch (OperationCanceledException)
            {
                return false;
            }
        }
    }
}
