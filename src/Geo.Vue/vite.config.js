import { fileURLToPath, URL } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

// 開發時以 proxy 取代 app/serve.py：/api 轉到 .NET、/geoserver 轉到 GeoServer，不需設定 CORS
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    },
    server: {
      proxy: {
        '/api': {
          target: env.VITE_API_TARGET,
          changeOrigin: true
        },
        '/geoserver': {
          target: env.VITE_GEOSERVER_TARGET,
          changeOrigin: true
        }
      }
    }
  }
})
