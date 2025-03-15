import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  server: {
    // required to load scripts from custom host
    cors: true,

    // we need a strict port to match on PHP side
    // change freely, but update on PHP to match the same port
    strictPort: true,
    host: "0.0.0.0",
    port: 3000,

    // 允許特定的主機名稱進行存取。
    // 這樣的設定可以增加應用程式的安全性，防止未經授權的主機存取你的開發伺服器
    allowedHosts: ["try-vue.test"],
  },
})
