using System;
using System.Collections.Generic;
using NetTopologySuite.Geometries;

namespace Geo.Service.Entities;

public partial class YoubikeStation
{
    public int Id { get; set; }

    public string? Sno { get; set; }

    public string? Name { get; set; }

    public string? NameEn { get; set; }

    public string? District { get; set; }

    public string? Address { get; set; }

    public int? Total { get; set; }

    public int? Bikes { get; set; }

    public int? Docks { get; set; }

    public int? Active { get; set; }

    public DateTime? Updated { get; set; }

    public Point? Geom { get; set; }
}
