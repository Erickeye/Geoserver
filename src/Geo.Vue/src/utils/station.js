export function formatTime(value) {
  if (!value) {
    return ''
  }

  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return ''
  }

  return date.toLocaleString('zh-TW', { timeZone: 'Asia/Taipei', hour12: false })
}

// 後端 camelCase 欄位轉成畫面用的站點物件；座標維持 { lat, lon }，只有進 Leaflet 時才組成 [緯度, 經度]
export function normalizeStation(raw) {
  return {
    sno: raw.sno ?? '',
    name: raw.name ?? '',
    district: raw.district ?? '',
    address: raw.address ?? '',
    total: raw.total ?? 0,
    bikes: raw.bikes ?? 0,
    docks: raw.docks ?? 0,
    isActive: raw.isActive === true,
    updated: formatTime(raw.updated),
    lat: raw.lat,
    lon: raw.lon,
    distM: raw.distM ?? null
  }
}
