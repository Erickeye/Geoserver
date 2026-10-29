import http from '@/api/http'

export const stationApi = {
  index: params => http.get('/Station/Index', { params }),
  get: sno => http.get('/Station/Get', { params: { sno } }),
  nearest: params => http.get('/Station/Nearest', { params }),
  districts: () => http.get('/Station/Districts'),
  map: () => http.get('/Station/Map')
}
