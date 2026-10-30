# .NET 後端 + Vue 前端擴充計畫

在已完成的 YouBike 地圖（見 [PROJECT.md](PROJECT.md)）之上，加入 .NET 10 後端與 Vue 3 前端，練習 ASP.NET Core 與空間資料的結合。
撰寫規範見 `.claude/skills/backend-coding-style` 與 `.claude/skills/vue-coding-style`（優先於 ERP 專案規範）。

## 目標

- 後端 API 取代前端直打 GeoServer WFS：站點列表與篩選、單站詳情、最近 N 站
- 定時更新 YouBike 資料（取代手動 `import-youbike.ps1 -Refresh`）
- 記錄歷史快照，提供簡單統計
- 前端改為 Vue 3 + Leaflet；地圖底圖與站點上色仍由 GeoServer WMS 負責

## 現況（起點）

| 項目 | 狀態 |
|---|---|
| PostgreSQL 18 + PostGIS 3.6.2 | `localhost:5432`，資料庫 `taiwan`，使用者 `postgres`（密碼由使用者自行輸入，AI 不處理） |
| 資料表 `public.youbike_stations` | 1823 站；欄位 `id`(PK)、`sno`(UNIQUE)、`name`、`name_en`、`district`、`address`、`total`、`bikes`、`docks`、`active`(1/0)、`updated`、`geom`(Point, 4326)；`geom` 有 GiST 索引、`district` 有索引 |
| GeoServer | `http://localhost:8080/geoserver`，預設帳密 `admin`/`geoserver`；workspace `taiwan`、Store `taiwan_postgis`；圖層 `taiwan:youbike`（SLD `youbike-bikes`）、SQL View `taiwan:youbike_nearest` |
| 原前端（已移除） | `app/index.html` 與 `app/serve.py`（port 5600）已由 `src/Geo.Vue` 取代，可從 git 歷史取回 |
| 工具 | .NET SDK 10.0.402、Node 24、npm 11、PowerShell 7（`pwsh`） |
| 參考 SQL | `sql/02_youbike_queries.sql`（兩段式 KNN） |

`updated` 的實際欄位型別（text 或 timestamp）尚未確認，開工時先用 `\d youbike_stations` 看。

## 架構

```
YouBike JSON ──(BackgroundService 定時更新)──▶ PostGIS ◀── GeoServer（WMS 圖磚）
                                                  ▲                    │
                                                  │                    ▼
                                  Geo.Service ◀─ Geo.API (REST)   Vue + Leaflet
                                                           ▲              │
                                                           └──────────────┘ /api
```

```
Geo.sln
src/Geo.API/    Controller、Program.cs、Filter、Middleware、BackgroundService
src/Geo.Service/   Service、Entity／DbContext、VM、ResultModel、Enum
src/Geo.Vue/       Vue 3 + Vite + Leaflet
tests/Geo.Tests/   之後再建
```

## 已定案的決策

- 後端兩個專案，不加編號前綴；Controller 薄、Service 回傳 `ResultModel<T>`，HTTP 一律 200 加 `isSuccess`。
- EF Core + Npgsql + NetTopologySuite；KNN 用參數化原生 SQL，不拼字串。
- Entity 用 DB-first scaffold（沿用 ERP 習慣），不手改產出。
- 資料表仍由 `import-youbike.ps1` 建立（GeoServer 圖層依賴它）；後端只負責 upsert，不負責建表。
- 前端 Vue 3 + Leaflet，不強制 Element Plus；開發用 Vite `server.proxy` 取代 `serve.py`。
- 驗證規則：改完 `dotnet build`／`npm run build`，並實際呼叫 API 或開頁面確認。

## API 設計

| 路徑 | 說明 |
|---|---|
| `GET api/Station/Index` | 查詢條件 `District`、`Keyword`、`OnlyAvailable`（有車可借）＋ `PageNumber`、`PageSize`、`SortColumn`、`SortDirection`；回傳分頁 `StationVM` |
| `GET api/Station/Get?sno=` | 單站詳情；找不到回 `NotFoundData` |
| `GET api/Station/Nearest?lat=&lon=&n=5` | 最近 N 個營運中站點，含 `distM`（公尺）；驗證 lat 21–26、lon 119–123、n 1–20 |
| `GET api/Station/Districts` | 行政區與站數（下拉選單用） |
| `GET api/Station/Map` | 地圖用的全部站點（精簡欄位：sno、行政區、車輛數、是否營運、座標），前端以 Canvas 繪製 |
| `GET api/Station/History?sno=&hours=24` | 階段 4：單站最近 N 小時的車輛數變化 |
| `GET api/Station/Status` | 來源資料更新時間、最近同步時間與錯誤 |
| `GET /health` | 健康檢查：資料庫連線，且最近成功同步不超過 3 個間隔 |

## 實作階段

每階段完成後都要 build 並實際驗證，再進下一階段。

### 階段 1：後端骨架與唯讀 API

- [x] 建 `Geo.sln`、`Geo.API`、`Geo.Service`，設定專案參考與 `Nullable`
- [x] 安裝套件：Npgsql.EntityFrameworkCore.PostgreSQL、其 NetTopologySuite 擴充、Swagger（建專案時確認可用版本）
- [x] 連線字串放 `appsettings.Development.json`（gitignore），repo 放 `appsettings.Development.example.json`；密碼由使用者填
- [x] scaffold `youbike_stations` 成 Entity／DbContext（需使用者提供連線）
- [x] `ResultModel<T>`、`ErrorCodeType`、全域驗證 Filter、`ExceptionMiddleware`（要記錄例外）
- [x] `StationService`：`Index`、`Get`、`Districts`；`StationController`
- [x] 驗證：Swagger 呼叫三支 API，信義區應為 129 站

### 階段 2：最近 N 站

- [x] `Nearest`：兩段式 KNN（內層 `<->` 取 3 倍候選、外層 `geography` 公尺距離重排）
- [x] 驗證：臺北 101（lon 121.5645、lat 25.034）前 5 名應為 137、148、149、167、179 公尺，與 GeoServer SQL View 結果一致

### 階段 3：定時更新

- [x] Options 類別放 YouBike 位址與更新間隔；`AddHttpClient`
- [x] `BackgroundService`：抓 JSON → `INSERT ... ON CONFLICT (sno) DO UPDATE` 更新車輛數、狀態、時間；單次失敗記錄並繼續
- [ ] 驗證：資料表的 `updated` 隨時間推進（已驗證）；地圖（WMS）顏色跟著變（待確認）

### 階段 4：歷史快照（選做）

- [x] 新表 `youbike_snapshots`（sno、bikes、docks、recorded_at；`sql/03_youbike_snapshots.sql`），只在數量變動時寫入，主鍵 `(sno, recorded_at)` 擋重複，每次同步順便清掉超過 `YouBike:SnapshotRetentionDays`（預設 7）的舊資料
- [x] `History` API；前端以 SVG 階梯折線圖呈現（`HistoryChart.vue`）
- [x] `Status` API 與 `/health`：資料更新時間、最近同步結果；前端顯示「資料更新於」
- 設計取捨：只存變動點，量約為「每分鐘全站」的一成以下；沒變動的站在區間起點補上前一筆（或目前值）

### 階段 5：Vue 前端

- [x] Vite 建 `src/Geo.Vue`，設定 `server.proxy`（`/api` → .NET、`/geoserver` → 8080）與 `.env.*`
- [x] `http.js`、`stationApi.js`、`utils/api.js`
- [x] `MapView.vue`（`shallowRef`、WMS 圖層、座標轉換）、行政區下拉、點站點看詳情、點空白處找最近 5 站
- [x] 驗證：功能與原 `app/` 一致（點站點詳情改走 `Nearest`＋`Get`，因此停用站點點不到），已移除 `app/`（連同 `serve.py`）

### 階段 6：收尾（選做）

- [ ] 測試專案（xUnit；空間查詢需真實 PostGIS，用 Testcontainers）
- [ ] Docker Compose：.NET + PostGIS + GeoServer（對應 `PLAN.md` 階段 6）
- [ ] 更新 README；`setup-geoserver.ps1` 是否保留 `youbike_nearest` SQL View 視需要決定

## 開放問題

- `updated` 欄位型別，以及 upsert 時要不要統一轉成 `timestamptz`
- 是否要在 API 加快取（YouBike 一分鐘才更新一次）
- 之後若加登入，再回頭參考 ERP 規範（JWT、`ICurrentUserService`）

## 新 session 開場須知

1. 先讀 `CLAUDE.md`、`docs/PROJECT.md`、本檔、兩個 skill。
2. 需要資料庫或 GeoServer 密碼的步驟由使用者執行或輸入；AI 不輸入、不保存密碼。
3. git：`main` 目前有 4 個 commit 尚未 push；本檔與 `.claude/skills/`、`CLAUDE.md`、`.gitignore` 的修改尚未 commit。commit 不加 AI 署名，push 前先詢問。
4. 從階段 1 開始。
