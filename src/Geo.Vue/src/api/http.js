import axios from 'axios'

// 專案內唯一使用 axios 的地方；之後需要 Token 時在這裡加 request interceptor
const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 30000
})

export default http
