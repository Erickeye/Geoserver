using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 單站歷史查詢條件。
    /// </summary>
    public class HistorySearchVM
    {
        /// <summary>站點編號</summary>
        [Display(Name = "站點編號")]
        [Required]
        public string Sno { get; set; } = string.Empty;

        /// <summary>往前查詢的小時數</summary>
        [Display(Name = "小時數")]
        [Range(1, 168)]
        public int Hours { get; set; } = 24;
    }
}
