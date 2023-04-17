import { fileURLToPath, URL } from 'node:url'

import { defineConfig, splitVendorChunkPlugin } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import liveReload from 'vite-plugin-live-reload'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import dynamicImport from 'vite-plugin-dynamic-import'
import * as path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  // 插件配置
  plugins: [
    vue(),  // vue插件
    vueJsx(), // vue jsx插件
    liveReload([  // 熱重載插件
      // edit live reload paths according to your source code
      // for example:
      // __dirname + '/../api/(module|config)/**/*.php',
      // __dirname + '/../api/(module|config)/**/*.twig',
      // using this for our example:
      // __dirname + '/../api/public/*.php'
    ]),
    dynamicImport(),  // 動態導入插件
    splitVendorChunkPlugin(), // 分離第三方包
    AutoImport({  // 自動導入插件
      include: [  // 自動導入的文件
        /\.[tj]sx?$/, // .ts, .tsx, .js, .jsx
        /\.vue$/,
        /\.vue\?vue/, // .vue
        /\.md$/ // .md
      ],
      dts: './auto-imports.d.ts', // 自動導入的類型聲明文件
      imports: ['vue', 'vue-router', 'pinia'],  // 自動導入的包
      resolvers: [ElementPlusResolver()]  // 自動導入的包的解析器
    }),
    Components({  // 自動導入插件
      dts: true,
      include: [/\.vue$/, /\.vue\?vue/, /\.md$/]
    })
  ],

  // 服務器配置
  base: process.env.APP_ENV === 'development' ? '/' : '/dist/',

  // 打包配置
  build: {
    outDir: '../api/public/dist', // 打包後的文件目錄
    emptyOutDir: true,  // 清空打包後的文件目錄
    manifest: true, // 生成 manifest.json 文件
    rollupOptions: {  // rollup配置
      input: {  // 入口文件
        main: path.resolve(__dirname, 'src/main.ts')  // 主入口文件
      }
    }
  },

  // 服務器配置
  server: {
    cors: true, // 允許跨域
    strictPort: true, // 端口被佔用時報錯
    host: '0.0.0.0',  // 監聽地址
    port: 3000  // 監聽端口
  },

  // 路徑解析
  resolve: {
    alias: {  // 路徑別名
      '@': path.resolve(__dirname, './src') // src目錄
    }
  }
})
