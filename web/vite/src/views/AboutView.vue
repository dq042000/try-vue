<template>
  <div class="about">
    <h1>This is an about page</h1>
    <div>
      {{ counterStore.count }}-{{ counterStore.doubleCount }}
      <button @click="counterStore.increment">增加</button>
      <button @click="counterStore.decrement">減少</button>
    </div>
    <div>
      <button @click="test001.increment">增加</button>
      {{ test001.count }}-{{ test001.double }}
    </div>
    <div>
      <button @click="test002.increment">增加</button>
      {{ test002.count }}-{{ test002.double }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { useCounterStore } from '../stores/modules/counter'
import { useTest001 } from '../stores/modules/test-001'
import { useTest002 } from '../stores/modules/test-002'
const counterStore = useCounterStore()
const test001 = useTest001();
const test002 = useTest002();

// const { name } = storeToRefs(testStore);
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
