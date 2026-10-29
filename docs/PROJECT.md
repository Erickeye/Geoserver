# 結業專案：台灣便民地圖

用 PostGIS + GeoServer + Leaflet 做一張 YouBike 站點地圖，把階段 1–5 學到的東西串起來。
學習進度請看 [PLAN.md](PLAN.md)。

## 目標

- 地圖上顯示 YouBike 站點，點選可看詳情（站名、可借車數、可還空位）
- 依行政區篩選
- 顯示「離我最近的 5 個站」

## 資料來源

臺北市 YouBike 2.0 即時資訊（政府資料開放授權條款第 1 版，免費）：
[data.gov.tw 資料集 137993](https://data.gov.tw/en/datasets/137993)

| 項目 | 內容 |
|---|---|
| 檔案 | `youbike_immediate.json` |
| 位址 | tcgbusfs.blob.core.windows.net 的 `youbike/v2/` 路徑（以資料集頁面列出的為準） |
| 更新頻率 | 平臺標示每 1 分鐘 |
| 原始欄位 | `sno`、`sna`（站名，含 `YouBike2.0_` 前綴）、`sarea`（行政區）、`ar`（地址）、`Quantity`（總車位）、`available_rent_bikes`（可借）、`available_return_bikes`（可還）、`latitude`、`longitude`、`act`（1 營運 / 0 停用）、`updateTime` |
| 存放 | `data/youbike/`（被 `.gitignore` 排除，不進版控） |

實測結果（2026-10-29 下載，約 0.95 MB，**不需金鑰**）：1823 站、13 個行政區、座標無缺漏、站碼不重複、26 站停用。

匯入時欄位改成簡短小寫名稱（`scripts/youbike_to_geojson.py`）：
`sno`、`name`（去掉前綴）、`name_en`、`district`、`address`、`total`、`bikes`、`docks`、`active`、`updated`，外加 `id`（主鍵）與 `geom`（Point, 4326）。

注意：

- 只涵蓋**臺北市**，其他縣市是不同資料來源。
- 匯入的是**當下快照**，第一版不做自動更新；要更新就重跑 `import-youbike.ps1 -Refresh`。

## 架構

```
YouBike JSON ──匯入──▶ PostGIS (taiwan.public.youbike_stations)
                           │
                           ▼
                      GeoServer (workspace: taiwan)
                      WMS / WFS 發佈圖層
                           │
                           ▼
                  Vue + Leaflet 前端（src/Geo.Vue）
```

資料庫沿用 `taiwan`，行政區邊界沿用 `towns`，可用空間查詢把站點對應到鄉鎮。

## 專案結構

```
src/        .NET 後端（Geo.API、Geo.Service）與 Vue 前端（Geo.Vue；Vite proxy 取代原本的 serve.py）
sql/        建表、索引、查詢 SQL
scripts/    匯入 YouBike、之後的 GeoServer 設定腳本
docs/       文件
```

## 實作步驟

| 步驟 | 內容 | 學到的概念 |
|---|---|---|
| 1 | 建 `youbike_stations` 表並匯入 JSON | 點資料、`geometry(Point,4326)`、GiST 空間索引 |
| 2 | GeoServer 發佈 `taiwan:youbike` 圖層與樣式 | 點樣式，依可借車數上色 |
| 3 | 前端顯示站點、點選顯示詳情 | WFS 或 GetFeatureInfo |
| 4 | 依行政區篩選 | `CQL_FILTER`、與 `towns` 做空間關聯 |
| 5 | 離我最近的 5 個站 | KNN 運算子 `<->`、`ST_Distance`、`::geography`、SQL View 參數 |

每一步先說明概念，再實作。

## 待辦清單

- [x] 下載 `youbike_immediate.json`，確認欄位
- [x] 步驟 1：建表與匯入（`scripts/import-youbike.ps1`）
- [x] 步驟 2：GeoServer 發佈圖層與樣式（`scripts/setup-geoserver.ps1` 與 `styles/youbike-bikes.sld`）
- [x] 步驟 3：前端顯示站點與詳情（原為 `app/index.html`，現為 `src/Geo.Vue`）
- [x] 步驟 4：行政區篩選（同上）
- [x] 步驟 5：離我最近的 5 個站（SQL View `taiwan:youbike_nearest`，同上）

## 執行順序

```
pwsh -File scripts\import-youbike.ps1        # 輸入 postgres 密碼：建表並匯入 1823 站
pwsh -File scripts\setup-geoserver.ps1       # 用 GeoServer 預設帳密 admin/geoserver：建樣式與兩個圖層
dotnet run --project src\Geo.API --urls http://localhost:5286   # 後端（含定時更新）
cd src\Geo.Vue; npm run dev                                      # 開啟 http://localhost:5173/
```

## 設計備忘

- **座標順序**：PostGIS `ST_MakePoint(經度, 緯度)`，Leaflet 是 `[緯度, 經度]`。
- **距離單位**：4326 直接算是「度」，要公尺用 `::geography`。
- **欄位名稱**：建表時一律小寫，避免需要加雙引號。
- **Identifier**：GeoServer SQL View 的主鍵要選 `id`，不能選幾何欄位。
- **空間索引**：`geom::geography` 轉型後用不到 `geom` 的 GiST 索引；資料量大時考慮建 geography 欄位或函式索引。
- **密碼**：連線密碼不寫進檔案，用環境變數或執行時輸入。
- **GeoServer 設定不在專案內**：Store 連線參數、SQL View 的 SQL 與參數都只存在 GeoServer 資料目錄，之後要補成文件或 REST 腳本，才能重建環境。

## 之後可擴充

- 定時重新匯入，讓可借車數接近即時（.NET 後端與 Vue 前端的擴充計畫見 [DOTNET_PLAN.md](DOTNET_PLAN.md)）
- 納入其他縣市的 YouBike，或公車站、避難收容處所
- 改用 Docker 部署 GeoServer + PostGIS（階段 6）
