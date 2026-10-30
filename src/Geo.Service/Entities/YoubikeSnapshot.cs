namespace Geo.Service.Entities;

/// <summary>
/// 站點車輛數的歷史快照（只在數量變動時寫入）。
/// </summary>
public partial class YoubikeSnapshot
{
    public string Sno { get; set; } = null!;

    public int Bikes { get; set; }

    public int Docks { get; set; }

    public DateTime RecordedAt { get; set; }
}
