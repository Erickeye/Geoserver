---
name: vue-coding-style
description: Apply the Geo project's Vue 3 + Leaflet frontend conventions when creating, modifying, reviewing, or refactoring .vue files, frontend JavaScript, API wrappers, or Leaflet map code under src/Geo.Vue. Use it for map components, GeoServer WMS layers, ResultModel handling, loading/error states, and Vite proxy setup.
---

# Vue Coding Style（Vue 3 + Vite + Leaflet）

Geo 結業專案的前端規範。承襲 ERP.Vue 的核心做法，去掉 ERP 專屬的部分。後端請見 `backend-coding-style`。

## 1. 結構

```
src/Geo.Vue/
  src/api/        http.js（唯一的 axios）、stationApi.js
  src/utils/      api.js（unwrap／isSuccess／getApiErrorMessage）
  src/views/      頁面
  src/components/ 共用元件（MapView.vue 等）
```

匯入 `src` 內檔案使用 `@/` alias，同一檔案不要混用相對與 alias。

## 2. 基本

- 一律 `<script setup>`，區塊順序 `<script setup>`、`<template>`、`<style scoped>`。
- script 內順序：Vue imports、API imports、元件 imports、狀態、computed、正規化／格式化函式、互動函式、生命週期。
- 只有 `src/api/http.js` 可以 import `axios`；baseURL 取自 `VITE_API_BASE_URL`（`.env.development`／`.env.production`）；Token 之後由 request interceptor 帶入，不在每個 wrapper 手動傳 headers。
- 不在 template 堆複雜轉換、日期格式化或 API 判斷，放 function、computed 或 `src/utils`。
- 相同流程出現第二次，先找共用邊界；兩頁規則不同就只共用穩定的 UI 或 helper，不建巨型 generic 元件。
- UI 元件庫目前不強制。需要表格、對話框、表單驗證時再引入 Element Plus，之後遵循同一套用法。
- 商業規則以後端為準，前端只做輸入整理、顯示與基本驗證。

## 3. 後端 Contract

- 開發前先確認 Controller 實際 Route 與 VM 欄位，不要猜測。Route 為 `api/[controller]/{Action}`，wrapper 路徑要一致，例如 `/Station/Index`、`/Station/Nearest`。
- 列表 `data` 形狀為 `{ items, pageNumber, pageSize, totalCount }`；驗證失敗時 `data` 為 `{ 欄位名: [錯誤訊息...] }`。
- 回傳一律 `ResultModel<T>`（camelCase）：

```json
{ "isSuccess": true, "errorCode": 0, "errorMessage": null, "data": {} }
```

- 業務錯誤都是 HTTP 200 加 `isSuccess: false`，**不能只靠 `catch` 判斷失敗**。

## 4. API 邊界

```js
// src/api/stationApi.js
import http from './http'

export const stationApi = {
  index: params => http.get('/Station/Index', { params }),
  get: sno => http.get('/Station/Get', { params: { sno } }),
  nearest: params => http.get('/Station/Nearest', { params })
}
```

共用 helper 集中在 `src/utils/api.js`：

```js
export function unwrap(response) {
  const result = response?.data ?? response
  return result?.data ?? null
}

export function isSuccess(response) {
  const result = response?.data ?? response
  return result?.isSuccess === true
}

export function getApiErrorMessage(error, fallback = '操作失敗') {
  const result = error?.response?.data ?? error?.data ?? error
  return result?.errorMessage ?? fallback
}
```

列表資料流程：呼叫 wrapper → `isSuccess` 檢查（失敗顯示錯誤並結束）→ `unwrap` → `items.map(normalizeRow)` → 寫入 `rows`。template 不寫 `response.data.data.xxx`。

## 5. Loading 與錯誤

每個非同步流程都有開始、成功、失敗、結束四種狀態，並各自的 loading state（`loading`、`saving`、`exporting`）：

```js
async function loadNearest(lat, lon) {
  loading.value = true
  error.value = ''
  try {
    const response = await stationApi.nearest({ lat, lon, n: 5 })
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '查詢失敗')
      return
    }
    nearest.value = unwrap(response).items.map(normalizeStation)
  } catch (e) {
    error.value = getApiErrorMessage(e, '查詢失敗')
  } finally {
    loading.value = false
  }
}
```

- 錯誤要放在畫面可見的位置，不可 catch 後靜默 return。
- 高風險操作（刪除等）要用確認對話框，不使用 `window.alert`／`window.confirm`。
- 不留 `console.log`，不寫死 `localhost` 或機密。

## 6. Leaflet

- **地圖實例不可放進 `reactive`／`ref`**（Vue 會深層代理而嚴重變慢），用 `shallowRef` 或 `markRaw`；標記與圖層同理。
- 在 `onMounted` 建立地圖，`onUnmounted` 呼叫 `map.remove()`。
- 座標順序：後端與 GeoJSON 是 `[經度, 緯度]`，Leaflet 是 `[緯度, 經度]`，集中在一個轉換函式。
- 站點圖層預設用 **Canvas** 由前端畫：`L.map(..., { preferCanvas: true })` 搭配 `L.circleMarker`，資料來自 `Station/Map`（全部站點、精簡欄位）；另保留 GeoServer 的 WMS（SLD 上色）作為切換選項。詳情、最近 5 站走 .NET API，不再由前端直打 WFS。
- Canvas 站點的規則：`circleMarker` 要設 `bubblingMouseEvents: false`（否則點站點會同時觸發地圖點擊）；標記放在非響應式的 `Map`（sno → marker）；資料更新時用 `setStyle` 只改顏色，不要整層重畫；上色規則要與 SLD 一致（停用灰、0 輛紅、1–4 橘、5 以上綠）。
- 動態篩選 WMS 時，刪除 `wmsParams.CQL_FILTER` 再 `redraw()`。
- 顯示外部資料（站名、地址）進 HTML 前要跳脫（`esc()`），或改用文字節點，避免 XSS。
- 開發時用 Vite 的 `server.proxy` 把 `/api` 轉到 .NET、`/geoserver` 轉到 `http://localhost:8080`，取代原本的 `serve.py` 代理，不需設定 CORS。

## 7. CSS

- 頁面樣式用 `<style scoped>` 與語意化 class（`search-bar`、`row-actions`）；覆蓋第三方樣式用 `:deep()` 並限縮在頁面根 class 下。
- 不在 template 寫大段 inline style。

## 8. 完成前檢查與驗證

- 以 Grep 確認 `.vue` 沒有直接 `import axios`、沒有 `window.confirm`／`window.alert`、沒有殘留 `console.log`、沒有寫死 `localhost`。
- 確認每個 API 呼叫都有 `isSuccess` 檢查、loading 與錯誤處理，地圖實例沒有被 Vue 代理。
- **改完執行 `npm run build`，涉及畫面的功能要啟動開發伺服器實際開頁確認**（與 ERP 的「不 build」規則相反，本專案以能跑為準）。
- 若需動到 `http.js`、Vite 設定或全域 CSS，先向使用者確認範圍。

## 9. 禁止事項

- 在頁面直接使用 axios，或寫死 baseURL、主機位址、密鑰。
- 只靠 `catch` 判斷失敗而不檢查 `isSuccess`。
- 在 template 散落深層取值；使用 `window.alert`／`confirm`；殘留 `console.log`。
- 把 Leaflet 地圖實例放進 `reactive`／`ref`。
- 把商業規則硬編碼在前端，或把前端權限控制當成安全機制。
