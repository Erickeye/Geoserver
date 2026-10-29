<script setup>
import { onMounted, onUnmounted, ref, shallowRef, watch } from 'vue'
import L from 'leaflet'
import { escapeHtml } from '@/utils/html'

const props = defineProps({
  stations: { type: Array, default: () => [] },
  renderMode: { type: String, default: 'canvas' },
  district: { type: String, default: '' },
  origin: { type: Object, default: null },
  nearest: { type: Array, default: () => [] },
  detail: { type: Object, default: null },
  fitPoints: { type: Array, default: () => [] },
  focus: { type: Object, default: null }
})

const emit = defineEmits(['map-click', 'station-click'])

const GEOSERVER_URL = import.meta.env.VITE_GEOSERVER_URL
const WORKSPACE = 'taiwan'
const STATIONS_LAYER = 'taiwan:youbike'
const CLICK_TOLERANCE_PX = 12
const STATION_RADIUS_PX = 6

// 顏色規則與 GeoServer 的 SLD（youbike-bikes）一致
const COLOR_INACTIVE = '#9e9e9e'
const COLOR_NONE = '#d32f2f'
const COLOR_LOW = '#f57c00'
const COLOR_HIGH = '#2e7d32'

const mapEl = ref(null)
// Leaflet 物件不能放進 reactive／ref（Vue 會深層代理而嚴重變慢）
const map = shallowRef(null)
const wms = shallowRef(null)
const stationLayer = shallowRef(null)
const resultLayer = shallowRef(null)
const markers = new Map()
const stationMarkers = new Map()

// 後端與 GeoJSON 是 [經度, 緯度]，Leaflet 是 [緯度, 經度]；站點座標在這裡統一轉換
function toLatLng(item) {
  return L.latLng(item.lat, item.lon)
}

function colorOf(station) {
  if (!station.isActive) {
    return COLOR_INACTIVE
  }
  if (station.bikes === 0) {
    return COLOR_NONE
  }
  return station.bikes < 5 ? COLOR_LOW : COLOR_HIGH
}

function popupHtml(station) {
  const state = station.isActive ? '營運中' : '停用'
  const distance = station.distM != null
    ? `<tr><td>距離</td><td>${escapeHtml(station.distM)} 公尺</td></tr>`
    : ''

  return `<div class="popup"><b>${escapeHtml(station.name)}</b><br>${escapeHtml(station.district)} · ${escapeHtml(station.address)}
    <table>
      <tr><td>可借車輛</td><td><b>${escapeHtml(station.bikes)}</b></td></tr>
      <tr><td>可還空位</td><td><b>${escapeHtml(station.docks)}</b></td></tr>
      <tr><td>總車位</td><td>${escapeHtml(station.total)}</td></tr>
      <tr><td>狀態</td><td>${state}</td></tr>
      ${distance}
      <tr><td>更新</td><td>${escapeHtml(station.updated)}</td></tr>
    </table></div>`
}

// ---- WMS 模式 ----
function applyWmsFilter() {
  const params = wms.value.wmsParams
  delete params.CQL_FILTER

  if (props.district) {
    params.CQL_FILTER = `district='${props.district.replace(/'/g, "''")}'`
  }

  wms.value.redraw()
}

// ---- Canvas 模式：站點由前端直接畫 ----
function createStationMarker(station) {
  const marker = L.circleMarker(toLatLng(station), {
    radius: STATION_RADIUS_PX,
    fillColor: colorOf(station),
    fillOpacity: 1,
    color: '#fff',
    weight: 1,
    // 不讓點擊冒泡到地圖，否則點站點會同時觸發「找最近 5 站」
    bubblingMouseEvents: false
  })
  marker.on('click', () => emit('station-click', station.sno))
  return { marker, district: station.district }
}

function applyStationFilter() {
  stationMarkers.forEach(entry => {
    const visible = !props.district || entry.district === props.district
    const shown = stationLayer.value.hasLayer(entry.marker)

    if (visible && !shown) {
      stationLayer.value.addLayer(entry.marker)
    } else if (!visible && shown) {
      stationLayer.value.removeLayer(entry.marker)
    }
  })
}

// 第一次建立標記；之後每次更新只改顏色，不整層重畫
function syncStations() {
  const seen = new Set()

  props.stations.forEach(station => {
    seen.add(station.sno)
    const entry = stationMarkers.get(station.sno)

    if (entry) {
      entry.marker.setStyle({ fillColor: colorOf(station) })
    } else {
      stationMarkers.set(station.sno, createStationMarker(station))
    }
  })

  stationMarkers.forEach((entry, sno) => {
    if (!seen.has(sno)) {
      stationLayer.value.removeLayer(entry.marker)
      stationMarkers.delete(sno)
    }
  })

  applyStationFilter()

  if (props.renderMode === 'wms') {
    wms.value.redraw()
  }
}

function applyRenderMode() {
  if (props.renderMode === 'canvas') {
    map.value.removeLayer(wms.value)
    map.value.addLayer(stationLayer.value)
  } else {
    map.value.removeLayer(stationLayer.value)
    map.value.addLayer(wms.value)
    applyWmsFilter()
  }
}

function onDistrictChange() {
  applyWmsFilter()
  applyStationFilter()
}

function renderResults() {
  resultLayer.value.clearLayers()
  markers.clear()

  if (props.origin) {
    L.circleMarker(toLatLng(props.origin), {
      radius: 9,
      color: '#fff',
      weight: 3,
      fillColor: '#1565C0',
      fillOpacity: 1,
      bubblingMouseEvents: false
    }).bindTooltip('起點').addTo(resultLayer.value)
  }

  props.nearest.forEach((station, index) => {
    const marker = L.marker(toLatLng(station), {
      icon: L.divIcon({
        className: '',
        html: `<div class="num">${index + 1}</div>`,
        iconSize: [22, 22],
        iconAnchor: [11, 11]
      })
    }).bindPopup(popupHtml(station)).addTo(resultLayer.value)

    markers.set(station.sno, marker)
  })
}

function showDetail() {
  if (!props.detail) {
    map.value.closePopup()
    return
  }

  L.popup().setLatLng(toLatLng(props.detail)).setContent(popupHtml(props.detail)).openOn(map.value)
}

function fitToPoints() {
  if (props.fitPoints.length === 0) {
    return
  }

  const bounds = L.latLngBounds(props.fitPoints.map(toLatLng))
  map.value.fitBounds(bounds, { padding: [60, 60], maxZoom: 17 })
}

function focusMarker() {
  const marker = props.focus ? markers.get(props.focus.sno) : null
  if (!marker) {
    return
  }

  map.value.panTo(marker.getLatLng())
  marker.openPopup()
}

function onClick(event) {
  const latlng = event.latlng.wrap()
  const point = map.value.latLngToContainerPoint(event.latlng)
  const edge = map.value.containerPointToLatLng([point.x + CLICK_TOLERANCE_PX, point.y])

  // Canvas 模式的站點自己能點，點到地圖就一定是空白處（容許距離 -1 表示不當成點到站點）
  const toleranceM = props.renderMode === 'canvas' ? -1 : map.value.distance(event.latlng, edge)

  emit('map-click', { lat: latlng.lat, lon: latlng.lng, toleranceM })
}

watch(() => props.stations, syncStations)
watch(() => props.renderMode, applyRenderMode)
watch(() => props.district, onDistrictChange)
watch(() => [props.origin, props.nearest], renderResults)
watch(() => props.detail, showDetail)
watch(() => props.fitPoints, fitToPoints)
watch(() => props.focus, focusMarker)

onMounted(() => {
  // preferCanvas：向量圖形（站點圓點）畫在同一張 <canvas>，不是一個點一個 DOM 元素
  map.value = L.map(mapEl.value, { zoomControl: false, preferCanvas: true }).setView([25.04, 121.54], 12)
  L.control.zoom({ position: 'bottomright' }).addTo(map.value)

  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> · YouBike 資料：臺北市政府（政府資料開放授權條款第 1 版）'
  }).addTo(map.value)

  // WMS 模式：站點圖層由 GeoServer 以 SLD（youbike-bikes）繪製；先建立，由 applyRenderMode 決定顯示哪一個
  wms.value = L.tileLayer.wms(`${GEOSERVER_URL}/${WORKSPACE}/wms`, {
    layers: STATIONS_LAYER,
    format: 'image/png',
    transparent: true,
    version: '1.1.1',
    // 512px 圖磚：同一畫面的請求數約少 4 倍
    tileSize: 512,
    zoomOffset: -1
  })

  stationLayer.value = L.layerGroup()
  resultLayer.value = L.layerGroup().addTo(map.value)

  applyRenderMode()
  syncStations()
  map.value.on('click', onClick)
})

onUnmounted(() => {
  map.value?.remove()
  map.value = null
})
</script>

<template>
  <div class="map-view">
    <div ref="mapEl" class="map"></div>

    <div class="legend">
      <div><span class="dot dot-high"></span>5 輛以上</div>
      <div><span class="dot dot-low"></span>1–4 輛</div>
      <div><span class="dot dot-none"></span>無車可借</div>
      <div><span class="dot dot-inactive"></span>停用</div>
    </div>
  </div>
</template>

<style scoped>
.map-view {
  position: relative;
  height: 100%;
}

.map {
  height: 100%;
}

.legend {
  position: absolute;
  z-index: 1000;
  left: 10px;
  bottom: 24px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  padding: 8px 10px;
  font-size: 12px;
  line-height: 1.7;
}

.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 6px;
}

.dot-high {
  background: #2e7d32;
}

.dot-low {
  background: #f57c00;
}

.dot-none {
  background: #d32f2f;
}

.dot-inactive {
  background: #9e9e9e;
}

.map-view :deep(.num) {
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

.map-view :deep(.popup b) {
  font-size: 15px;
}

.map-view :deep(.popup table) {
  border-collapse: collapse;
  margin-top: 4px;
}

.map-view :deep(.popup td) {
  padding: 1px 8px 1px 0;
}
</style>
