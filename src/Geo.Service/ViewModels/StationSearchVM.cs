using System.ComponentModel.DataAnnotations;

namespace Geo.Service.ViewModels
{
    /// <summary>
    /// 站點列表查詢條件。
    /// </summary>
    public class StationSearchVM
    {
        /// <summary>行政區（完全比對）</summary>
        [Display(Name = "行政區")]
        public string? District { get; set; }

        /// <summary>關鍵字（站名或地址）</summary>
        [Display(Name = "關鍵字")]
        [StringLength(50)]
        public string? Keyword { get; set; }

        /// <summary>只顯示營運中且有車可借的站點</summary>
        [Display(Name = "僅顯示可借車站點")]
        public bool OnlyAvailable { get; set; }

        /// <summary>頁碼</summary>
        [Display(Name = "頁碼")]
        [Range(1, int.MaxValue)]
        public int PageNumber { get; set; } = 1;

        /// <summary>每頁筆數</summary>
        [Display(Name = "每頁筆數")]
        [Range(1, 100)]
        public int PageSize { get; set; } = 20;

        /// <summary>排序欄位白名單：Sno、Name、District、Bikes、Docks、Updated</summary>
        [Display(Name = "排序欄位")]
        public string SortColumn { get; set; } = "Sno";

        /// <summary>asc 或 desc</summary>
        [Display(Name = "排序方向")]
        public string SortDirection { get; set; } = "asc";
    }
}
