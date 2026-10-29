<script setup>
import { onMounted, onUnmounted, ref, shallowRef, watch } from 'vue'
import L from 'leaflet'
import { escapeHtml } from '@/utils/html'

const props = defineProps({
  district: { type: String, default: '' },
  origin: { type: Object, default: null },
  nearest: { type: Array, default: () => [] },
  detail: { type: Object, default: null },
  fitPoints: { type: Array, default: () => [] },
  focus: { type: Object, default: null }
})

const emit = defineEmits(['map-click'])

const GEOSERVER_URL = import.meta.env.VITE_GEOSERVER_URL
const WORKSPACE = 'taiwan'
const STATIONS_LAYER = 'taiwan:youbike'
const CLICK_TOLERANCE_PX = 12

const mapEl = ref(null)
// Leaflet 物件不能放進 reactive／ref（Vue 會深層代理而嚴重變慢）
const map = shallowRef(null)
const wms = shallowRef(null)
const resultLayer = shallowRef(null)
const markers = new Map()

// 後端與 GeoJSON 是 [經度, 緯度]，Leaflet 是 [緯度, 經度]；站點座標在這裡統一轉換
function toLatLng(item) {
  return L.latLng(item.lat, item.lon)
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

function applyWmsFilter() {
  const params = wms.value.wmsParams
  delete params.CQL_FILTER

  if (props.district) {
    params.CQL_FILTER = `district='${props.district.replace(/'/g, "''")}'`
  }

  wms.value.redraw()
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
      fillOpacity: 1
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

  emit('map-click', {
    lat: latlng.lat,
    lon: latlng.lng,
    toleranceM: map.value.distance(event.latlng, edge)
  })
}

watch(() => props.district, applyWmsFilter)
watch(() => [props.origin, props.nearest], renderResults)
watch(() => props.detail, showDetail)
watch(() => props.fitPoints, fitToPoints)
watch(() => props.focus, focusMarker)

onMounted(() => {
  map.value = L.map(mapEl.value, { zoomControl: false }).setView([25.04, 121.54], 12)
  L.control.zoom({ position: 'bottomright' }).addTo(map.value)

  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> · YouBike 資料：臺北市政府（政府資料開放授權條款第 1 版）'
  }).addTo(map.value)

  // 站點圖層由 GeoServer 以 SLD（youbike-bikes）繪製
  wms.value = L.tileLayer.wms(`${GEOSERVER_URL}/${WORKSPACE}/wms`, {
    layers: STATIONS_LAYER,
    format: 'image/png',
    transparent: true,
    version: '1.1.1'
  }).addTo(map.value)

  resultLayer.value = L.layerGroup().addTo(map.value)
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
