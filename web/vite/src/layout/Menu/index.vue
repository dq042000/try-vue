<template>
    <div class="menu">
        選單區域
        <div>{{ title }}</div>
        <div>{{ data }}</div>
        <div>
            <button @click="clickTap">派發</button>
        </div>
    </div>
</template>

<script setup lang="ts">
import { reactive } from "vue";
const list = reactive<number[]>([6, 6, 6]);
type Props = {
    title: string;
    data: number[];
};
defineProps<Props>();

const emit = defineEmits(["on-click"]);
const clickTap = () => {
    emit("on-click", list);
};
</script>

<style lang="less" scoped>
.menu {
    width: 200px;
    border-right: 1px solid #ccc;
}
</style>
