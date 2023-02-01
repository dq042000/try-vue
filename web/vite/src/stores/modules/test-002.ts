import { computed, ref } from 'vue'
import { defineStore } from 'pinia'

export const useTest002 = defineStore('test002', () => {
  const count = ref(0)

  const double = computed(() => {
    return count.value * 2
  })

  function increment() {
    count.value++
  }

  return { count, double, increment }
})