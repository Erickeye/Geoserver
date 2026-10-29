using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace Geo.Service.Entities;

public partial class GeoDbContext : DbContext
{
    public GeoDbContext(DbContextOptions<GeoDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<YoubikeStation> YoubikeStations { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("postgis");

        modelBuilder.Entity<YoubikeStation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("youbike_stations_pkey");

            entity.ToTable("youbike_stations");

            entity.HasIndex(e => e.District, "idx_youbike_stations_district");

            entity.HasIndex(e => e.Geom, "youbike_stations_geom_geom_idx").HasMethod("gist");

            entity.HasIndex(e => e.Sno, "youbike_stations_sno_key").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Active).HasColumnName("active");
            entity.Property(e => e.Address)
                .HasColumnType("character varying")
                .HasColumnName("address");
            entity.Property(e => e.Bikes).HasColumnName("bikes");
            entity.Property(e => e.District)
                .HasColumnType("character varying")
                .HasColumnName("district");
            entity.Property(e => e.Docks).HasColumnName("docks");
            entity.Property(e => e.Geom)
                .HasColumnType("geometry(Point,4326)")
                .HasColumnName("geom");
            entity.Property(e => e.Name)
                .HasColumnType("character varying")
                .HasColumnName("name");
            entity.Property(e => e.NameEn)
                .HasColumnType("character varying")
                .HasColumnName("name_en");
            entity.Property(e => e.Sno)
                .HasColumnType("character varying")
                .HasColumnName("sno");
            entity.Property(e => e.Total).HasColumnName("total");
            entity.Property(e => e.Updated).HasColumnName("updated");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
