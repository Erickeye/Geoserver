# GeoServer 學習計畫

GeoServer 預設已載入官方範例資料（5 個 workspace、28 個 layer），可直接練習，不需先準備資料。
管理介面：http://localhost:8080/geoserver/web/

## 先懂 6 個名詞

| 名詞 | 一句話 |
|---|---|
| **向量 / 點陣 (Vector / Raster)** | 向量是點線面加屬性（例如行政區界）；點陣是影像格子（例如衛星圖、高程） |
| **座標系 (CRS / EPSG)** | 投影方式不同座標就不同。常見：`EPSG:4326`（經緯度）、`EPSG:3857`（網頁地圖）、`EPSG:3826`（台灣 TWD97） |
| **WMS** | 伺服器直接回傳「地圖圖片」 |
| **WFS** | 伺服器回傳「資料本身」（GeoJSON/GML），前端可點選、查詢 |
| **WMTS / TMS** | 預先切好的圖磚，速度快 |
| **Workspace → Store → Layer → Style** | GeoServer 管理層級：命名空間 → 資料來源 → 圖層 → 樣式 |

## 階段 1：認識現有功能（約 1 小時）

- [x] 打開 Layer Preview，用 OpenLayers 預覽 `sf:roads`、`ne:countries`
- [x] 點 WMS 1.3.0 的 GetCapabilities，看 XML 列了哪些圖層
- [x] 手寫 WMS GetMap URL 放進瀏覽器，改 `bbox`、`width`、`layers` 看圖怎麼變
- [x] 手寫 WFS 請求，用 `outputFormat=application/json` 取得 GeoJSON，並試 `maxFeatures=5`
- [x] 用 `CQL_FILTER` 篩選，例如 `CQL_FILTER=NAME='某國家'`

## 階段 2：自己的資料（約 2 小時）

- [x] 從政府資料開放平臺下載台灣鄉鎮市區界線 Shapefile
- [x] 建立自己的 workspace，例如 `taiwan`
- [x] 建立 Store（Shapefile），再 Publish Layer
- [x] 設定正確座標系（台灣資料常是 EPSG:3826）並勾選「Compute from data」
- [x] 改用 GeoPackage (`.gpkg`) 再做一次

## 階段 3：樣式 Styles（約 2 小時）

- [x] 新增 SLD 樣式：行政區半透明藍色加黑框
- [x] 加上文字標註 (Label)
- [x] 依屬性分色，例如依人口分級
- [x] 比例尺規則：縮小只顯示縣市，放大才顯示鄉鎮

## 階段 4：做成網頁（約 3 小時）

- [x] 用 Leaflet 或 OpenLayers 建 HTML 頁面，疊上 GeoServer 的 WMS 圖層
- [x] 用 WFS 抓 GeoJSON，點擊區域時彈出屬性視窗
- [ ] 處理 CORS（GeoServer 需設定才能跨網域）— 目前以 `app/serve.py` 轉送繞過（階段 4 的 `web/` 已移除，可從 git 歷史取回），尚未實際啟用 CORS
- [x] 加圖層切換與 OSM 底圖
- [ ] 進階：用 C# 呼叫 WFS 並反序列化 GeoJSON

## 階段 5：PostGIS 資料庫（約 4 小時）

- [x] 安裝 PostgreSQL + PostGIS 擴充（PostgreSQL 18、PostGIS 3.6.2，資料庫 `taiwan`）
- [x] 用 QGIS 或 `ogr2ogr` 把 Shapefile 匯入資料庫（QGIS DB Manager 已完成；`scripts/import-towns.ps1` 為 ogr2ogr 版，尚未執行驗證）
- [x] 在 GeoServer 建 PostGIS Store 並發佈（`taiwan:towns_pg`）
- [ ] 練習空間 SQL：`ST_Contains`、`ST_Distance`、`ST_Buffer`
- [x] 建 SQL View 圖層，例如「某點 500 公尺內的 POI」（暫無 POI 資料，改做 `taiwan:towns_near`：某點 N 公尺內的鄉鎮，參數 `lon`、`lat`、`dist`）

## 階段 6：進階功能

- [ ] 開啟 GeoWebCache 圖磚快取，比較 WMS 與 WMTS 速度
- [ ] 用 REST API (`/geoserver/rest`) 以程式建立 workspace 和 layer
- [ ] 設定安全性：限制某圖層只有特定使用者可存取
- [ ] 改用 Docker 部署 GeoServer + PostGIS

## 結業專案：台灣便民地圖

- 資料：臺北市 YouBike 2.0 站點（1823 站），詳見 [PROJECT.md](PROJECT.md)
- 架構：PostGIS 存資料 → GeoServer 發佈 → Leaflet 網頁顯示（`app/`）
- 功能：
  - [x] 點選站點顯示詳情
  - [x] 依行政區篩選
  - [x] 顯示「離我最近的 5 個站」（SQL View `taiwan:youbike_nearest`，KNN 兩段式）
- 已用 REST API 腳本（`scripts/setup-geoserver.ps1`）建立樣式與圖層，階段 6 的 REST 項目只差 workspace 與 Store

## 建議工具

- **QGIS**（免費桌面 GIS）：先看資料、檢查座標系，再交給 GeoServer 發佈
- **geojson.io**：快速畫點線面、貼上 GeoJSON 看結果

## 常用 URL 範本

```
# WMS GetMap
http://localhost:8080/geoserver/sf/wms?service=WMS&version=1.1.1&request=GetMap&layers=sf:roads&bbox=589434,4914006,609527,4928063&width=768&height=537&srs=EPSG:26713&format=image/png

# WFS GeoJSON
http://localhost:8080/geoserver/sf/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=sf:roads&maxFeatures=5&outputFormat=application/json
```
