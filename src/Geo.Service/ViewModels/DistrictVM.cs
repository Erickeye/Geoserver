using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 行政區與站數。
    /// </summary>
    public class DistrictVM
    {
        /// <summary>行政區</summary>
        [Display(Name = "行政區")]
        public string District { get; set; } = string.Empty;

        /// <summary>站數</summary>
        [Display(Name = "站數")]
        public int StationCount { get; set; }
    }
}
