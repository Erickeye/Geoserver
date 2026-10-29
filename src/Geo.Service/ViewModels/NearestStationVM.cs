using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 最近站點輸出，含與查詢點的距離。
    /// </summary>
    public class NearestStationVM : StationVM
    {
        /// <summary>與查詢點的距離（公尺）</summary>
        [Display(Name = "距離（公尺）")]
        public double DistM { get; set; }
    }
}
