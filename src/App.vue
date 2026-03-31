<script setup>
import SidebarLayout from './components/SidebarLayout.vue'
</script>

<template>
  <SidebarLayout>
    <router-view :key="$route.path" />
  </SidebarLayout>
</template>
