import { createPinia as _createPinia, Pinia } from 'pinia'
import piniaPersist from 'pinia-plugin-persist'
import { useCounterStore } from './modules/counter'

let pinia: Pinia

const useStore = {
  useCounterStore
}

export const createPinia = (): Pinia => {
  pinia = _createPinia()
  pinia.use(piniaPersist)
  return pinia
}

export const usePinia = (): Pinia => pinia

export default useStore
