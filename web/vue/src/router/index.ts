import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

// const modules = import.meta.globEager('./modules/**/*.ts')  // 匹配所有模塊文件

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue')
    }
  ]
})

export default router
