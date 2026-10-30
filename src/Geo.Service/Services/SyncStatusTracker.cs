namespace Geo.Service.Services
{
    /// <summary>
    /// 記錄 YouBike 同步的最近結果（記憶體內，重啟後歸零），供狀態 API 與健康檢查使用。
    /// </summary>
    public interface ISyncStatusTracker
    {
        /// <summary>最近一次成功同步的時間（UTC）；尚未成功過為 null</summary>
        DateTime? LastSuccessAt { get; }

        /// <summary>最近一次同步失敗的訊息；最近一次成功時為 null</summary>
        string? LastError { get; }

        void MarkSuccess();

        void MarkFailure(string message);
    }

    public class SyncStatusTracker : ISyncStatusTracker
    {
        private readonly object _lock = new();
        private DateTime? _lastSuccessAt;
        private string? _lastError;

        public DateTime? LastSuccessAt
        {
            get { lock (_lock) { return _lastSuccessAt; } }
        }

        public string? LastError
        {
            get { lock (_lock) { return _lastError; } }
        }

        public void MarkSuccess()
        {
            lock (_lock)
            {
                _lastSuccessAt = DateTime.UtcNow;
                _lastError = null;
            }
        }

        public void MarkFailure(string message)
        {
            lock (_lock)
            {
                _lastError = message;
            }
        }
    }
}
