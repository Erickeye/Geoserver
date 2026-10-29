namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 站點輸出。座標為 WGS84（SRID 4326）。
    /// </summary>
    public class StationVM
    {
        public string? Sno { get; set; }
        public string? Name { get; set; }
        public string? NameEn { get; set; }
        public string? District { get; set; }
        public string? Address { get; set; }
        public int? Total { get; set; }
        public int? Bikes { get; set; }
        public int? Docks { get; set; }
        public bool IsActive { get; set; }
        public DateTime? Updated { get; set; }
        public double? Lat { get; set; }
        public double? Lon { get; set; }
    }
}
