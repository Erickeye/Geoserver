namespace Geo.Service.Options
{
    /// <summary>
    /// YouBike 定時更新設定（對應 appsettings 的 YouBike 區段）。
    /// </summary>
    public class YouBikeOptions
    {
        public const string SectionName = "YouBike";

        /// <summary>是否啟用定時更新</summary>
        public bool Enabled { get; set; } = true;

        /// <summary>即時資料 JSON 位址</summary>
        public string Url { get; set; } = string.Empty;

        /// <summary>更新間隔（秒）；來源資料約每分鐘更新</summary>
        public int RefreshIntervalSeconds { get; set; } = 60;
    }
}
