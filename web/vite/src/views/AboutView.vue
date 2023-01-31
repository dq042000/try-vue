<template>
  <div class="about">
    <h1>This is an about page</h1>
    <div>
      <span class="text-9xl font-semibold text-sky-600">{{
        counterStore.count
      }}</span>
    </div>
    <div>
      <span class="text-9xl font-semibold text-sky-600">{{
        counterStore.doubleCount
      }}</span>
    </div>
    <div>
      <button @click="counterStore.increment">增加</button>
    </div>
    <div>
      <button @click="counterStore.decrement">減少</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useCounterStore } from '../stores/modules/counter'
const counterStore = useCounterStore()
</script>

<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
