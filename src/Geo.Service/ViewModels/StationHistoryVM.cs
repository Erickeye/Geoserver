using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 單站歷史的一個時間點。
    /// </summary>
    public class StationHistoryVM
    {
        /// <summary>記錄時間（來源資料更新時間）</summary>
        [Display(Name = "記錄時間")]
        public DateTime RecordedAt { get; set; }

        /// <summary>可借車輛數</summary>
        [Display(Name = "可借車輛")]
        public int Bikes { get; set; }

        /// <summary>可還空位數</summary>
        [Display(Name = "可還空位")]
        public int Docks { get; set; }
    }
}
