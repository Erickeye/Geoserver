# geoserver-taiwan-lab

用台灣鄉鎮市區界線學習 GeoServer 的練習專案。學習進度與清單請看 [docs/PLAN.md](docs/PLAN.md)，結業專案（YouBike 便民地圖）請看 [docs/PROJECT.md](docs/PROJECT.md)。

## 環境

| 項目 | 說明 |
|---|---|
| GeoServer | Windows 安裝版，以服務執行 (`NT AUTHORITY\NetworkService`) |
| 管理介面 | http://localhost:8080/geoserver/web/ |
| 資料目錄 | `C:\ProgramData\GeoServer` |
| QGIS | 3.44 LTR，用來檢視資料與轉檔 |

## 資料來源與取得方式

資料**不放在版控中**（`data/` 已被 `.gitignore` 排除），請自行下載：

1. 前往 [政府資料開放平臺：鄉鎮市區界線](https://data.gov.tw/dataset/32157)（內政部國土測繪中心，政府資料開放授權條款第 1 版）
2. 下載「鄉(鎮、市、區)界線」Shapefile（本專案使用 `TOWN_MOI_1140318`，座標系為 `GCS_TWD97[2020]`，編碼 UTF-8）
3. 解壓縮後放到 `data/taiwan/`

## GeoServer 設定重點

### 資料必須放在資料目錄底下

GeoServer 服務帳號讀不到 `C:\Users\...`，會出現 `Could not find file`。把檔案複製到：

```
C:\ProgramData\GeoServer\data\taiwan\
```

Store 的路徑使用相對於資料目錄的寫法，例如 `file:data/taiwan/towns/towns.shp`。

### 已發佈的圖層（workspace：`taiwan`）

| 圖層 | Store 類型 | 檔案 |
|---|---|---|
| `taiwan:towns` | Shapefile | `data/taiwan/towns/towns.shp` |
| `taiwan:towns_gpkg` | GeoPackage | `data/taiwan/towns.gpkg` |

### 發佈圖層時的設定

- **DBF charset**：`UTF-8`（Shapefile）
- **Declared SRS**：`EPSG:4326`，**SRS handling**：`Force declared`
  - 原始 `.prj` 沒有 EPSG 編號，GeoServer 會誤判成 `EPSG:4236`
- **Bounding Boxes**：先按 Native 的 *Compute from data*，再按 Lat/Lon 的 *Compute from native bounds*

### 轉成 GeoPackage

QGIS：圖層右鍵 → 匯出 → 另存要素為 → 格式 GeoPackage，CRS 選 `EPSG:4326`。轉換選「TWD97 to WGS 84 (1)」（準確度約 1 公尺）。

## 結業專案：台灣便民地圖（`src/`）

臺北市 YouBike 站點地圖：依可借車數上色、點站點看詳情、依行政區篩選、點空白處找最近 5 站。
資料存在 PostGIS，經 GeoServer 發佈圖磚；.NET 後端（`Geo.API`）提供查詢 API 並定時更新資料，Vue 3 + Leaflet 前端（`Geo.Vue`）顯示。前置條件：PostgreSQL + PostGIS、資料庫 `taiwan`、GeoServer 的 workspace `taiwan` 與 Store `taiwan_postgis`，需要 PowerShell 7 (`pwsh`)、.NET SDK 10、Node 24。

```
pwsh -File scripts\import-youbike.ps1      # 下載資料、轉 GeoJSON、匯入 PostGIS（輸入 postgres 密碼）；-Refresh 重新下載
pwsh -File scripts\setup-geoserver.ps1     # 用 REST API 建樣式與圖層（預設帳密 admin/geoserver）
```

後端連線字串放 `src/Geo.API/appsettings.Development.json`（已 gitignore，格式見 `appsettings.Development.example.json`）：

```
dotnet run --project src\Geo.API --urls http://localhost:5286   # 後端與定時更新
cd src\Geo.Vue; npm install; npm run dev                         # 開啟 http://localhost:5173/
```

| 位置 | 內容 |
|---|---|
| `scripts/` | 匯入與 GeoServer 設定腳本，`youbike_to_geojson.py` 負責轉檔 |
| `sql/` | `01` 匯入後補索引（腳本自動執行）、`02` 練習用空間查詢、`03` 歷史快照表（需手動執行一次） |
| `styles/youbike-bikes.sld` | 依可借車輛上色的樣式 |
| `src/Geo.API`、`src/Geo.Service` | .NET 10 後端：Station API、定時更新 |
| `src/Geo.Vue` | Vue 3 + Vite + Leaflet 前端（`server.proxy` 轉送 `/api`、`/geoserver`） |

GeoServer 設定不在專案內，所以用 `setup-geoserver.ps1` 重建；`import-towns.ps1` 則匯入行政區邊界 `towns`。

## 樣式（`styles/`）

SLD 檔放在 `styles/`，複製到 `C:\ProgramData\GeoServer\workspaces\taiwan\styles\` 並附同名 `.xml` 登錄。
SLD 含中文，**不要在 GeoServer 網頁編輯器按 Save**（編輯器以系統預設編碼讀檔，會把中文存成亂碼）。

## 欄位（`towns`）

`TOWNID`、`TOWNCODE`、`COUNTYNAME`、`TOWNNAME`、`TOWNENG`、`COUNTYID`、`COUNTYCODE`

註：縣市名稱使用「臺」而非「台」，例如 `COUNTYNAME='臺東縣'`。

## 常用請求

```
# WMS GetMap
http://localhost:8080/geoserver/taiwan/wms?service=WMS&version=1.1.1&request=GetMap&layers=taiwan:towns_gpkg&bbox=114,21,123,26&width=900&height=500&srs=EPSG:4326&format=image/png

# WFS GeoJSON（篩選臺東縣）
http://localhost:8080/geoserver/taiwan/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=taiwan:towns_gpkg&outputFormat=application/json&CQL_FILTER=COUNTYNAME='臺東縣'
```
