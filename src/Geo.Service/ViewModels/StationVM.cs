using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 站點輸出。座標為 WGS84（SRID 4326）。
    /// </summary>
    public class StationVM
    {
        /// <summary>站點編號</summary>
        [Display(Name = "站點編號")]
        public string? Sno { get; set; }

        /// <summary>站名</summary>
        [Display(Name = "站名")]
        public string? Name { get; set; }

        /// <summary>英文站名</summary>
        [Display(Name = "英文站名")]
        public string? NameEn { get; set; }

        /// <summary>行政區</summary>
        [Display(Name = "行政區")]
        public string? District { get; set; }

        /// <summary>地址</summary>
        [Display(Name = "地址")]
        public string? Address { get; set; }

        /// <summary>總車柱數</summary>
        [Display(Name = "總車柱數")]
        public int? Total { get; set; }

        /// <summary>可借車輛數</summary>
        [Display(Name = "可借車輛數")]
        public int? Bikes { get; set; }

        /// <summary>可還空位數</summary>
        [Display(Name = "可還空位數")]
        public int? Docks { get; set; }

        /// <summary>是否營運中</summary>
        [Display(Name = "是否營運中")]
        public bool IsActive { get; set; }

        /// <summary>資料更新時間</summary>
        [Display(Name = "資料更新時間")]
        public DateTime? Updated { get; set; }

        /// <summary>緯度</summary>
        [Display(Name = "緯度")]
        public double? Lat { get; set; }

        /// <summary>經度</summary>
        [Display(Name = "經度")]
        public double? Lon { get; set; }
    }
}
