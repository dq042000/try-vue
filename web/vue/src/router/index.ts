import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import NProgress from 'nprogress'

const modules = import.meta.globEager('./modules/**/*.ts')  // 匹配所有模塊文件
export const constantRouterMap: AppRouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: {}
  }
]

const routeModuleList: RouteRecordRaw[] = []  // 路由模塊列表
Object.keys(modules).forEach((key) => {
  const moduleRoutes = modules[key].default || {}
  if (Array.isArray(moduleRoutes)) {
    constantRouterMap.push(...moduleRoutes)
  }
  // const modList = Array.isArray(mod) ? [...mod] : [mod]
  // routeModuleList.push(...modList)
})

// export const constantRouter: any[] = [constantRouterMap, routeModuleList]
const router = createRouter({
  history: createWebHistory(),
  routes: constantRouterMap as RouteRecordRaw[]
  // routes: routeModuleList
})

router.beforeEach(async (to, from, next) => {
  NProgress.start()
  next()
})

router.afterEach((to, from) => {
  NProgress.done()
})

export default router
