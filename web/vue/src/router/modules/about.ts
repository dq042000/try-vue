export const constantRouterMap: AppRouteRecordRaw[] = [
  {
    name: 'about',
    path: '/about',
    component: () => import('@/views/About.vue'),
    meta: {
      title: '關於我們'
    }
  }
]
export default constantRouterMap
