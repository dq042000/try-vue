import { defineStore } from 'pinia'

export const useTest001 = defineStore('test001', {
  state: () => ({ 
    count: 0
  }),

  getters: {
    double: (state) => state.count * 2
  },

  actions: {
    increment() {
      this.count++
    }
  },
})