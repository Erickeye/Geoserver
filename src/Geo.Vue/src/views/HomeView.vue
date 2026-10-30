<script setup>
import { computed, onMounted, onUnmounted, ref, shallowRef, watch } from 'vue'
import { stationApi } from '@/api/stationApi'
import { getApiErrorMessage, isSuccess, unwrap } from '@/utils/api'
import { formatTime, normalizeStation } from '@/utils/station'
import MapView from '@/components/MapView.vue'
import HistoryChart from '@/components/HistoryChart.vue'

const NEAREST_N = 5
// 來源資料約每分鐘更新一次，前端同步一次即可
const REFRESH_MS = 60000
const SEARCH_PAGE_SIZE = 20

const districts = ref([])
const district = ref('')
// 全部站點（約 1800 筆）不需要深層響應，用 shallowRef 避免多餘的代理成本
const stations = shallowRef([])
const renderMode = ref('canvas')
const origin = ref(null)
const nearest = ref([])
const detail = ref(null)
const fitPoints = ref([])
const focus = ref(null)
const loading = ref(false)
const loadingStations = ref(false)
const error = ref('')
const message = ref('')
const dataUpdatedAt = ref('')
const syncError = ref('')
const keyword = ref('')
const onlyAvailable = ref(false)
const searchResults = ref([])
const searchTotal = ref(0)
const searching = ref(false)
const history = ref([])
const historyHours = ref(24)
const loadingHistory = ref(false)

let refreshTimer = null

const totalCount = computed(() => districts.value.reduce((sum, d) => sum + d.stationCount, 0))

const statusText = computed(() => {
  const firstLoad = loadingStations.value && stations.value.length === 0
  return loading.value || firstLoad ? '載入中…' : message.value
})

function clearResults() {
  origin.value = null
  nearest.value = []
  detail.value = null
}

async function loadDistricts() {
  loading.value = true
  error.value = ''
  try {
    const response = await stationApi.districts()
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '載入行政區失敗')
      return
    }
    districts.value = unwrap(response)
    message.value = `共 ${totalCount.value} 站`
  } catch (e) {
    error.value = getApiErrorMessage(e, '載入行政區失敗')
  } finally {
    loading.value = false
  }
}

async function loadStations() {
  loadingStations.value = true
  try {
    const response = await stationApi.map()
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '載入站點失敗')
      return
    }
    stations.value = unwrap(response).filter(s => s.lat != null && s.lon != null)
  } catch (e) {
    error.value = getApiErrorMessage(e, '載入站點失敗')
  } finally {
    loadingStations.value = false
  }
}

async function loadStatus() {
  try {
    const response = await stationApi.status()
    if (!isSuccess(response)) {
      return
    }
    const status = unwrap(response)
    dataUpdatedAt.value = formatTime(status.dataUpdatedAt)
    syncError.value = status.lastError ?? ''
  } catch {
    // 狀態只是輔助資訊，失敗時保留上一次的顯示，不打斷主要流程
  }
}

async function refreshData() {
  await Promise.all([loadStations(), loadStatus()])
}

async function loadHistory() {
  if (!detail.value) {
    history.value = []
    return
  }

  loadingHistory.value = true
  try {
    const response = await stationApi.history({ sno: detail.value.sno, hours: historyHours.value })
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '載入歷史失敗')
      return
    }
    history.value = unwrap(response)
  } catch (e) {
    error.value = getApiErrorMessage(e, '載入歷史失敗')
  } finally {
    loadingHistory.value = false
  }
}

async function runSearch() {
  const text = keyword.value.trim()
  if (!text) {
    searchResults.value = []
    searchTotal.value = 0
    return
  }

  searching.value = true
  error.value = ''
  try {
    const response = await stationApi.index({
      keyword: text,
      district: district.value || undefined,
      onlyAvailable: onlyAvailable.value,
      pageSize: SEARCH_PAGE_SIZE,
      sortColumn: 'Name'
    })
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '搜尋失敗')
      return
    }

    const page = unwrap(response)
    searchResults.value = page.items.map(normalizeStation)
    searchTotal.value = page.totalCount
  } catch (e) {
    error.value = getApiErrorMessage(e, '搜尋失敗')
  } finally {
    searching.value = false
  }
}

async function selectSearchResult(station) {
  fitPoints.value = [station]
  await loadDetail(station.sno)
}

// 行政區或「只顯示有車」改變：地圖由 MapView 過濾；這裡處理縮放範圍、訊息與搜尋結果
function onFilterChange() {
  clearResults()
  error.value = ''

  if (keyword.value.trim()) {
    runSearch()
  }

  const points = stations.value.filter(s =>
    (!district.value || s.district === district.value) &&
    (!onlyAvailable.value || (s.isActive && s.bikes > 0)))
  const suffix = onlyAvailable.value ? '（僅有車）' : ''

  // 全部站點已在記憶體，直接過濾即可算出縮放範圍
  if (!district.value) {
    fitPoints.value = []
    message.value = onlyAvailable.value ? `全部行政區：${points.length} 站有車` : `共 ${totalCount.value} 站`
    return
  }

  fitPoints.value = points
  message.value = `${district.value}：${points.length} 站${suffix}`
}

async function showDetail(sno) {
  const response = await stationApi.get(sno)
  if (!isSuccess(response)) {
    error.value = getApiErrorMessage(response, '載入站點詳情失敗')
    return
  }
  origin.value = null
  nearest.value = []
  detail.value = normalizeStation(unwrap(response))
  message.value = detail.value.name
}

async function loadDetail(sno) {
  loading.value = true
  error.value = ''
  try {
    await showDetail(sno)
  } catch (e) {
    error.value = getApiErrorMessage(e, '載入站點詳情失敗')
  } finally {
    loading.value = false
  }
}

// 點到站點看詳情（WMS 模式），否則以該處為起點顯示最近 5 站
async function loadNearest(lat, lon, toleranceM) {
  loading.value = true
  error.value = ''
  try {
    const response = await stationApi.nearest({ lat, lon, n: NEAREST_N })
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '查詢最近站點失敗')
      return
    }

    const list = unwrap(response).map(normalizeStation)
    if (list.length > 0 && list[0].distM <= toleranceM) {
      await showDetail(list[0].sno)
      return
    }

    detail.value = null
    origin.value = { lat, lon }
    nearest.value = list
    fitPoints.value = [{ lat, lon }, ...list]
    message.value = list.length > 0 ? `最近的 ${list.length} 個站（僅營運中）` : '附近沒有站點資料'
  } catch (e) {
    error.value = getApiErrorMessage(e, '查詢最近站點失敗')
  } finally {
    loading.value = false
  }
}

function onMapClick({ lat, lon, toleranceM }) {
  loadNearest(lat, lon, toleranceM)
}

function locateMe() {
  if (!navigator.geolocation) {
    error.value = '此瀏覽器不支援定位'
    return
  }

  message.value = '定位中…'
  navigator.geolocation.getCurrentPosition(
    position => loadNearest(position.coords.latitude, position.coords.longitude, -1),
    failure => {
      error.value = `定位失敗：${failure.message}。可改為直接點地圖設定起點`
    },
    { enableHighAccuracy: true, timeout: 10000 }
  )
}

function clearAll() {
  clearResults()
  keyword.value = ''
  searchResults.value = []
  searchTotal.value = 0
  fitPoints.value = []
  error.value = ''
  message.value = '已清除'
}

function focusStation(sno) {
  focus.value = { sno, seq: Date.now() }
}

watch([district, onlyAvailable], onFilterChange)
watch([() => detail.value?.sno, historyHours], loadHistory)

onMounted(() => {
  loadDistricts()
  refreshData()
  refreshTimer = setInterval(refreshData, REFRESH_MS)
})

onUnmounted(() => {
  clearInterval(refreshTimer)
})
</script>

<template>
  <div class="home">
    <MapView
      :stations="stations"
      :render-mode="renderMode"
      :district="district"
      :only-available="onlyAvailable"
      :origin="origin"
      :nearest="nearest"
      :detail="detail"
      :fit-points="fitPoints"
      :focus="focus"
      @map-click="onMapClick"
      @station-click="loadDetail"
    />

    <div class="panel">
      <h1>台灣便民地圖 · YouBike</h1>

      <div class="row">
        <select v-model="district" aria-label="行政區">
          <option value="">全部行政區</option>
          <option v-for="d in districts" :key="d.district" :value="d.district">
            {{ d.district }}（{{ d.stationCount }}）
          </option>
        </select>
      </div>

      <form class="row" @submit.prevent="runSearch">
        <input v-model="keyword" type="search" maxlength="50" placeholder="搜尋站名或地址" aria-label="關鍵字">
        <button type="submit" :disabled="searching">搜尋</button>
      </form>

      <div class="row mode">
        <label><input v-model="onlyAvailable" type="checkbox"> 只顯示有車的站</label>
      </div>

      <div class="row">
        <button type="button" :disabled="loading" @click="locateMe">定位我的位置</button>
        <button type="button" @click="clearAll">清除</button>
      </div>

      <div class="row mode">
        <span>站點圖層</span>
        <label><input v-model="renderMode" type="radio" value="canvas"> Canvas</label>
        <label><input v-model="renderMode" type="radio" value="wms"> WMS</label>
      </div>

      <p class="hint">點站點看詳情；點空白處則以該處為起點，找最近的 5 個站。</p>

      <div v-if="error" class="status error">{{ error }}</div>
      <div v-else class="status">{{ statusText }}</div>
      <div v-if="dataUpdatedAt" class="status" :class="{ warn: syncError }">
        資料更新於 {{ dataUpdatedAt }}<template v-if="syncError">（最近同步失敗）</template>
      </div>

      <div v-if="detail" class="history">
        <div class="row history-head">
          <b>{{ detail.name }} · 可借車輛</b>
          <select v-model.number="historyHours" aria-label="歷史範圍">
            <option :value="6">6 小時</option>
            <option :value="24">24 小時</option>
            <option :value="72">3 天</option>
            <option :value="168">7 天</option>
          </select>
        </div>
        <div v-if="loadingHistory" class="status">載入中…</div>
        <HistoryChart v-else :points="history" :total="detail.total" :hours="historyHours" />
      </div>

      <div v-if="keyword.trim() && !searching" class="status">
        搜尋結果 {{ searchTotal }} 站<template v-if="searchTotal > searchResults.length">（顯示前 {{ searchResults.length }} 站，請加關鍵字縮小範圍）</template>
      </div>
      <ul v-if="searchResults.length" class="results">
        <li v-for="station in searchResults" :key="station.sno" @click="selectSearchResult(station)">
          <b>{{ station.name }}</b>
          <div class="meta">{{ station.district }} · 可借 {{ station.bikes }} · 可還 {{ station.docks }}<template v-if="!station.isActive"> · 停用</template></div>
        </li>
      </ul>

      <ol class="nearest">
        <li v-for="(station, index) in nearest" :key="station.sno" @click="focusStation(station.sno)">
          <span class="rank">{{ index + 1 }}</span>
          <div>
            <b>{{ station.name }}</b>
            <div class="meta">{{ station.distM }} 公尺 · 可借 {{ station.bikes }} · 可還 {{ station.docks }}</div>
          </div>
        </li>
      </ol>
    </div>
  </div>
</template>

<style scoped>
.home {
  position: relative;
  height: 100%;
}

.panel {
  position: absolute;
  z-index: 1000;
  top: 10px;
  left: 56px;
  width: min(320px, calc(100vw - 72px));
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  padding: 12px;
}

.panel h1 {
  font-size: 16px;
  margin: 0 0 8px;
}

.row {
  display: flex;
  gap: 6px;
  margin-bottom: 8px;
}

.row input[type='search'] {
  flex: 1;
  min-width: 0;
  padding: 6px;
  font: inherit;
}

.row select,
.row button {
  flex: 1;
  padding: 6px;
  font: inherit;
}

.mode {
  align-items: center;
  font-size: 12px;
  color: #444;
}

.mode label {
  display: flex;
  align-items: center;
  gap: 2px;
  cursor: pointer;
}

.hint {
  color: #666;
  font-size: 12px;
  margin: 0 0 8px;
}

.status {
  font-size: 12px;
  color: #444;
  min-height: 1.2em;
}

.status.error {
  color: #c62828;
}

.status.warn {
  color: #e65100;
}

.history {
  margin-top: 8px;
  border-top: 1px solid #eee;
  padding-top: 8px;
}

.history-head {
  align-items: center;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 13px;
}

.history-head select {
  flex: none;
  padding: 2px;
  font-size: 12px;
}

.results {
  list-style: none;
  margin: 4px 0 0;
  padding: 0;
  max-height: 180px;
  overflow-y: auto;
}

.results li {
  padding: 6px 4px;
  border-top: 1px solid #eee;
  cursor: pointer;
}

.results li:hover {
  background: #f3f7ff;
}

.nearest {
  list-style: none;
  margin: 8px 0 0;
  padding: 0;
}

.nearest li {
  display: flex;
  gap: 8px;
  align-items: center;
  padding: 6px 4px;
  border-top: 1px solid #eee;
  cursor: pointer;
}

.nearest li:hover {
  background: #f3f7ff;
}

.rank {
  flex: none;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: #1565c0;
  color: #fff;
  font-weight: bold;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.5);
  box-sizing: border-box;
}

.meta {
  color: #666;
  font-size: 12px;
}
</style>
