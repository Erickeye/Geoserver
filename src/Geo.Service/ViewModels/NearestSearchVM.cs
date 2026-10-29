using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 最近站點查詢條件（台灣範圍）。
    /// </summary>
    public class NearestSearchVM
    {
        /// <summary>緯度</summary>
        [Display(Name = "緯度")]
        [Range(21, 26)]
        public double Lat { get; set; }

        /// <summary>經度</summary>
        [Display(Name = "經度")]
        [Range(119, 123)]
        public double Lon { get; set; }

        /// <summary>回傳站數</summary>
        [Display(Name = "回傳站數")]
        [Range(1, 20)]
        public int N { get; set; } = 5;
    }
}
