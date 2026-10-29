using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 地圖用的精簡站點（全部站點一次回傳，所以只帶畫圖需要的欄位；詳情另用 Get 取得）。
    /// </summary>
    public class StationMapVM
    {
        /// <summary>站點編號</summary>
        [Display(Name = "站點編號")]
        public string? Sno { get; set; }

        /// <summary>行政區</summary>
        [Display(Name = "行政區")]
        public string? District { get; set; }

        /// <summary>可借車輛數</summary>
        [Display(Name = "可借車輛數")]
        public int? Bikes { get; set; }

        /// <summary>是否營運中</summary>
        [Display(Name = "是否營運中")]
        public bool IsActive { get; set; }

        /// <summary>緯度</summary>
        [Display(Name = "緯度")]
        public double? Lat { get; set; }

        /// <summary>經度</summary>
        [Display(Name = "經度")]
        public double? Lon { get; set; }
    }
}
