---
name: backend-coding-style
description: Apply the Geo project's .NET backend coding style when creating, modifying, reviewing, or explaining .NET Web API code under src/Geo.API or src/Geo.Service; Controller, Service, ViewModel, ResultModel, EF Core query, PostGIS / NetTopologySuite spatial query, nearest-station KNN, YouBike refresh BackgroundService, logging, validation, or pagination work.
---

# Backend Coding Style（.NET 10）

Geo 結業專案的後端規範。承襲 ERP.WebAPI 的核心做法，去掉 ERP 專屬與過度分層的部分，以簡潔為主。前端請見 `vue-coding-style`。

## 1. 結構

```
src/
  Geo.API/    Controller、Program.cs、Filter、Middleware、BackgroundService
  Geo.Service/   Service、Entity／DbContext、ViewModel、ResultModel、Enum
tests/
  Geo.Tests/     之後再建
```

依賴方向：`API -> Service`。Controller 不直接使用 `DbContext`，也不寫商業邏輯。

## 2. 命名

- 以功能命名，不加編號前綴：`StationController`、`StationService`、`IStationService`。
- Interface 與實作放同一個檔案；DI 在 `Program.cs` 明確 `AddScoped`，不用反射自動註冊。
- VM：`StationVM`（輸出）、`StationSearchVM`（查詢條件）、`NearestSearchVM`、`StationAddVM`（輸入）。
- **VM 的每個屬性都要加 `[Display(Name = "中文名稱")]`**（輸出、輸入、查詢條件都一樣，`using System.ComponentModel.DataAnnotations;`），驗證訊息才會顯示中文欄位名。已有 `<summary>` 的保留，`Display` 的名稱沿用 summary 的短描述（不含補充說明）。

```csharp
public class StationSearchVM
{
    /// <summary>行政區（完全比對）</summary>
    [Display(Name = "行政區")]
    public string? District { get; set; }
}
```

- 縮排 4 spaces、Allman 大括號、block-scoped namespace（沿用 ERP 慣例）；private 欄位 `_camelCase`；啟用 `Nullable`，不用 `!` 壓警告。

## 3. Controller

只做：Route、綁定參數、呼叫 Service、`return Ok(result)`。

```csharp
[ApiController]
[Route("api/[controller]")]
public class StationController : ControllerBase
{
    [SwaggerOperation("查詢站點列表")]
    [HttpGet, Route("Index")]
    public async Task<IActionResult> Index([FromQuery] StationSearchVM vm)
    {
        return Ok(await _service.Index(vm));
    }
}
```

- **Action 一律用區塊本體（`{ return ...; }`），不用 expression-bodied `=>`**；Service 與其他方法也盡量遵守，除非是單純的屬性或一行 lambda。

- Action 用明確 Route：`Index`（列表）、`Get`、`Add`、`Edit`、`Delete`，其他功能用名詞或動詞（如 `Nearest`）。
- 每個 Action 加 `[SwaggerOperation]`。
- 輸入驗證用 DataAnnotations，並**全域註冊驗證 Filter**（不必每個 Action 記得加 `[ValidateModel]`），失敗回 `ResultModel`。

## 4. Service

- 所有公開方法回傳 `ResultModel<T>`，不回傳裸型別。
- Interface 與方法加中文 `<summary>`；商業邏輯處加「為什麼」的行內註解。
- 找不到資料 → `ResultModel.Error(ErrorCodeType.NotFoundData)`。業務可預期的失敗不要 `throw`。
- Add／Edit 欄位一致時，用私有 `Modify` 集中設定 Entity。
- 同一流程只在最後 `SaveChangesAsync()` 一次；多次儲存需要全成功或全失敗時用明確的交易。

## 5. API 回傳與錯誤

統一 HTTP 200 搭配 `ResultModel<T>`（與 ERP 前端規範一致）：

```json
{ "isSuccess": true, "errorCode": 0, "errorMessage": null, "data": {} }
```

- 錯誤碼一律用 `ErrorCodeType`，**數值不可重複**，不寫魔術數字。
- `ExceptionMiddleware` 必須記錄例外（`LogError`），不可吞掉。

## 6. 查詢與空間資料

- 查詢型 API：`AsNoTracking()` + 直接 `Select` 成 VM；篩選、排序、分頁在資料庫端完成，不先 `ToListAsync()`。
- 排序欄位用白名單，不接受前端任意欄位名稱。
- 分頁沿用 `PageNumber`、`PageSize`、`SortColumn`、`SortDirection`，回傳 `{ items, pageNumber, pageSize, totalCount }`。
- **座標**：一律 SRID 4326；NetTopologySuite 的 `Point` 是 `(經度, 緯度)`，前端 Leaflet 是 `[緯度, 經度]`，邊界處要換。
- **距離**：geometry 以「度」計算；要公尺用 `geography`。最近 N 站用兩段式（KNN 取 3 倍候選，再以公尺距離重排），SQL 參考 `sql/02_youbike_queries.sql`。
- EF Core 表達不了的（KNN `<->`）用參數化的原生 SQL（`FromSqlInterpolated`），**禁止字串拼接 SQL**。

## 7. 設定、機密與記錄

- 連線字串、外部 API 位址放 `appsettings.Development.json`（已 gitignore）與 Options 類別；repo 只放 `appsettings.Development.example.json`。
- 不把密碼、Token、連線字串寫進程式碼、設定範例或 Log。
- 用 `ILogger<T>` 結構化訊息：`_logger.LogError(ex, "更新失敗 {Count}", count)`，不用字串插值。
- 外部 HTTP（YouBike）用注入的 `HttpClient`（`AddHttpClient`），位址放 Options。
- 定時更新用 `BackgroundService`；在迴圈內以 `IServiceScopeFactory` 建 scope 取得 Scoped 服務；單次失敗要記錄並繼續下一輪。

## 8. 完成前檢查與驗證

- 以 Grep 確認 Controller 沒有注入 `DbContext`、Service 沒有回傳裸型別、沒有字串拼接 SQL。
- 以 Grep 確認 Controller／Service 沒有 expression-bodied 方法（`^\s+=> `），且 VM 的每個屬性都有 `[Display(Name = ...)]`。
- 確認錯誤沒有被吞掉（catch 後要記錄或回傳 `ResultModel.Error`），`ErrorCodeType` 新數值沒有重複。
- **改完執行 `dotnet build`，涉及查詢或 API 行為的功能要實際呼叫 API 確認結果**（與 ERP 的「不編譯」規則相反，本專案以能跑為準）。需要資料庫密碼時請使用者輸入，不要自行取得。
- 若需改動 `Program.cs` 全域設定、Middleware 或 `ErrorCodeType` 既有數值，先向使用者確認。

## 9. 刻意不採用（相對於 ERP 規範）

- 模組編號命名與 6 個專案分層
- 簽核、驗證碼、SFTP、Aspose／QuestPDF、`[PermissionAuthorize]`、操作紀錄 `[Log]`
- 反射自動註冊 DI、`SearchModel`／`[SearchField]` 框架
- 「不編譯、不測試」的規則

之後需要登入或權限時，再回頭參考 ERP 規範加入。
