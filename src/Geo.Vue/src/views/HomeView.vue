<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { stationApi } from '@/api/stationApi'
import { getApiErrorMessage, isSuccess, unwrap } from '@/utils/api'
import { normalizeStation } from '@/utils/station'
import MapView from '@/components/MapView.vue'

const NEAREST_N = 5
const PAGE_SIZE = 100
const MAX_PAGES = 20

const districts = ref([])
const district = ref('')
const origin = ref(null)
const nearest = ref([])
const detail = ref(null)
const fitPoints = ref([])
const focus = ref(null)
const loading = ref(false)
const error = ref('')
const message = ref('')

const totalCount = computed(() => districts.value.reduce((sum, d) => sum + d.stationCount, 0))

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

// 行政區站數可能超過單頁上限，逐頁取完才能算出縮放範圍
async function loadDistrictPoints(name) {
  const points = []
  for (let pageNumber = 1; pageNumber <= MAX_PAGES; pageNumber++) {
    const response = await stationApi.index({ District: name, PageNumber: pageNumber, PageSize: PAGE_SIZE })
    if (!isSuccess(response)) {
      throw new Error(getApiErrorMessage(response, '載入行政區站點失敗'))
    }
    const page = unwrap(response)
    points.push(...page.items.map(normalizeStation))
    if (points.length >= page.totalCount || page.items.length === 0) {
      break
    }
  }
  return points
}

async function onDistrictChange() {
  clearResults()
  error.value = ''

  if (!district.value) {
    fitPoints.value = []
    message.value = `共 ${totalCount.value} 站`
    return
  }

  loading.value = true
  try {
    const points = await loadDistrictPoints(district.value)
    fitPoints.value = points
    message.value = `${district.value}：${points.length} 站`
  } catch (e) {
    error.value = getApiErrorMessage(e, '載入行政區站點失敗')
  } finally {
    loading.value = false
  }
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

// 點到站點看詳情，否則以該處為起點顯示最近 5 站
async function loadNearest(lat, lon, toleranceM) {
  loading.value = true
  error.value = ''
  try {
    const response = await stationApi.nearest({ lat, lon, n: NEAREST_N })
    if (!isSuccess(response)) {
      error.value = getApiErrorMessage(response, '查詢最近站點失敗')
      return
    }

    const stations = unwrap(response).map(normalizeStation)
    if (stations.length > 0 && stations[0].distM <= toleranceM) {
      await showDetail(stations[0].sno)
      return
    }

    detail.value = null
    origin.value = { lat, lon }
    nearest.value = stations
    fitPoints.value = [{ lat, lon }, ...stations]
    message.value = stations.length > 0 ? `最近的 ${stations.length} 個站（僅營運中）` : '附近沒有站點資料'
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
    position => loadNearest(position.coords.latitude, position.coords.longitude, 0),
    failure => {
      error.value = `定位失敗：${failure.message}。可改為直接點地圖設定起點`
    },
    { enableHighAccuracy: true, timeout: 10000 }
  )
}

function clearAll() {
  clearResults()
  fitPoints.value = []
  error.value = ''
  message.value = '已清除'
}

function focusStation(sno) {
  focus.value = { sno, seq: Date.now() }
}

watch(district, onDistrictChange)

onMounted(loadDistricts)
</script>

<template>
  <div class="home">
    <MapView
      :district="district"
      :origin="origin"
      :nearest="nearest"
      :detail="detail"
      :fit-points="fitPoints"
      :focus="focus"
      @map-click="onMapClick"
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

      <div class="row">
        <button type="button" :disabled="loading" @click="locateMe">定位我的位置</button>
        <button type="button" @click="clearAll">清除</button>
      </div>

      <p class="hint">點站點看詳情；點空白處則以該處為起點，找最近的 5 個站。</p>

      <div v-if="error" class="status error">{{ error }}</div>
      <div v-else class="status">{{ loading ? '載入中…' : message }}</div>

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

.row select,
.row button {
  flex: 1;
  padding: 6px;
  font: inherit;
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
