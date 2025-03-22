<script setup lang="ts">
import { ref } from 'vue'

const fruits = ref<string[]>(['apple', 'banana', 'cherry'])

function reorder() {
  fruits.value = [fruits.value[2], fruits.value[0], fruits.value[1]]
}
</script>

<template>
  <div class="wrapper">
    <div @click="reorder" class="button">重新排序</div>
    <div v-for="name in fruits" :key="name" class="fruits">
      <span>{{ name }}</span>
      <input type="number">
    </div>
  </div>
</template>

<style scoped>
</style>
