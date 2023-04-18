<template>
  <el-config-provider :locale="zhTw">
    <div class="wrapper">
      <router-view />
    </div>
  </el-config-provider>
</template>
<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import zhTw from 'element-plus/lib/locale/lang/zh-tw'
</script>
