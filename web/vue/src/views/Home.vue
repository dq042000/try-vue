<template>
  <h1>This is an home page</h1>
  <nav>
    <RouterLink to="/">Home</RouterLink>
    <RouterLink to="/about">About</RouterLink>
  </nav>
  <button @click="increment">Count is：{{ count }}</button>
</template>

<script setup lang="ts">
const count = ref(0)

const increment = () => {
  count.value++
}
</script>

<style scoped>
button {
  font-weight: bold;
}
</style>