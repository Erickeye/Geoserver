using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 資料更新狀態。
    /// </summary>
    public class StatusVM
    {
        /// <summary>來源資料的最新更新時間（資料庫中站點的最大 updated）</summary>
        [Display(Name = "資料更新時間")]
        public DateTime? DataUpdatedAt { get; set; }

        /// <summary>伺服器最近一次成功同步的時間；服務重啟後尚未同步為空</summary>
        [Display(Name = "最近同步時間")]
        public DateTime? LastSyncAt { get; set; }

        /// <summary>最近一次同步失敗的訊息</summary>
        [Display(Name = "同步錯誤")]
        public string? LastError { get; set; }
    }
}
