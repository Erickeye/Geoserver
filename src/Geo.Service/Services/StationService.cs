using System.Linq.Expressions;
using Geo.Service.Entities;
using Geo.Service.Enums;
using Geo.Service.Models;
using Geo.Service.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace Geo.Service.Services
{
    /// <summary>
    /// YouBike 站點查詢。
    /// </summary>
    public interface IStationService
    {
        /// <summary>
        /// 查詢站點列表（篩選、排序、分頁）。
        /// </summary>
        Task<ResultModel<PagedResult<StationVM>>> Index(StationSearchVM vm);

        /// <summary>
        /// 取得單一站點詳情。
        /// </summary>
        /// <param name="sno">站點編號</param>
        Task<ResultModel<StationVM>> Get(string sno);

        /// <summary>
        /// 取得行政區與站數（下拉選單用）。
        /// </summary>
        Task<ResultModel<List<DistrictVM>>> Districts();
    }

    public class StationService : IStationService
    {
        private readonly GeoDbContext _db;

        public StationService(GeoDbContext db)
        {
            _db = db;
        }

        public async Task<ResultModel<PagedResult<StationVM>>> Index(StationSearchVM vm)
        {
            var query = _db.YoubikeStations.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(vm.District))
            {
                query = query.Where(s => s.District == vm.District);
            }

            if (!string.IsNullOrWhiteSpace(vm.Keyword))
            {
                // 跳脫 LIKE 萬用字元，避免使用者輸入 % 或 _ 時比對到全部
                var keyword = vm.Keyword.Trim()
                    .Replace("\\", "\\\\").Replace("%", "\\%").Replace("_", "\\_");
                var pattern = $"%{keyword}%";
                query = query.Where(s => EF.Functions.ILike(s.Name ?? "", pattern)
                    || EF.Functions.ILike(s.Address ?? "", pattern));
            }

            if (vm.OnlyAvailable)
            {
                query = query.Where(s => s.Active == 1 && s.Bikes > 0);
            }

            var totalCount = await query.CountAsync();

            var items = await ApplySort(query, vm.SortColumn, vm.SortDirection)
                .Skip((vm.PageNumber - 1) * vm.PageSize)
                .Take(vm.PageSize)
                .Select(s => new StationVM
                {
                    Sno = s.Sno,
                    Name = s.Name,
                    NameEn = s.NameEn,
                    District = s.District,
                    Address = s.Address,
                    Total = s.Total,
                    Bikes = s.Bikes,
                    Docks = s.Docks,
                    IsActive = s.Active == 1,
                    Updated = s.Updated,
                    Lat = s.Geom != null ? s.Geom.Y : null,
                    Lon = s.Geom != null ? s.Geom.X : null
                })
                .ToListAsync();

            return ResultModel<PagedResult<StationVM>>.Success(new PagedResult<StationVM>
            {
                Items = items,
                PageNumber = vm.PageNumber,
                PageSize = vm.PageSize,
                TotalCount = totalCount
            });
        }

        public async Task<ResultModel<StationVM>> Get(string sno)
        {
            var station = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.Sno == sno)
                .Select(s => new StationVM
                {
                    Sno = s.Sno,
                    Name = s.Name,
                    NameEn = s.NameEn,
                    District = s.District,
                    Address = s.Address,
                    Total = s.Total,
                    Bikes = s.Bikes,
                    Docks = s.Docks,
                    IsActive = s.Active == 1,
                    Updated = s.Updated,
                    Lat = s.Geom != null ? s.Geom.Y : null,
                    Lon = s.Geom != null ? s.Geom.X : null
                })
                .FirstOrDefaultAsync();

            return station == null
                ? ResultModel<StationVM>.Error(ErrorCodeType.NotFoundData)
                : ResultModel<StationVM>.Success(station);
        }

        public async Task<ResultModel<List<DistrictVM>>> Districts()
        {
            var districts = await _db.YoubikeStations.AsNoTracking()
                .Where(s => s.District != null)
                .GroupBy(s => s.District!)
                .Select(g => new DistrictVM { District = g.Key, StationCount = g.Count() })
                .OrderBy(d => d.District)
                .ToListAsync();

            return ResultModel<List<DistrictVM>>.Success(districts);
        }

        /// <summary>
        /// 排序欄位用白名單，不接受前端任意欄位名稱；未知欄位退回 Sno。
        /// </summary>
        private static IQueryable<YoubikeStation> ApplySort(
            IQueryable<YoubikeStation> query, string column, string direction)
        {
            var desc = string.Equals(direction, "desc", StringComparison.OrdinalIgnoreCase);

            IOrderedQueryable<YoubikeStation> Order<TKey>(Expression<Func<YoubikeStation, TKey>> key)
                => desc ? query.OrderByDescending(key) : query.OrderBy(key);

            var ordered = column.ToLowerInvariant() switch
            {
                "name" => Order(s => s.Name),
                "district" => Order(s => s.District),
                "bikes" => Order(s => s.Bikes),
                "docks" => Order(s => s.Docks),
                "updated" => Order(s => s.Updated),
                _ => Order(s => s.Sno)
            };

            // 加上 Id 當次要排序，分頁結果才穩定
            return ordered.ThenBy(s => s.Id);
        }
    }
}
