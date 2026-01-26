<script setup>
import { useRouter } from 'vue-router'
import sunetLogo from '../assets/images/sunet_logo_color.svg'
import calendarIcon from '../assets/icons/calendar.svg'

const router = useRouter()

function goToUpdateExpiry() {
  router.push('/update-expiry')
}
</script>

<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="sidebar-content">
        <img :src="sunetLogo" alt="SUNET Logo" class="logo" />
        <div class="sidebar-spacer"></div>
        <button class="expiry-btn" @click="goToUpdateExpiry" title="Update Expiry">
          <img :src="calendarIcon" alt="Update Expiry" class="expiry-icon" />
        </button>
      </div>
    </aside>
    <main class="main-content">
      <slot></slot>
    </main>
  </div>
</template>

<style scoped>
.layout {
  display: flex;
  height: 100vh;
  width: 100%;
}

.sidebar {
  width: var(--sidebar-width);
  min-width: var(--sidebar-width);
  background-color: #f5f5f5;
  border-right: 1px solid #e0e0e0;
  padding: 20px;
}

.sidebar-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  align-items: center;
}

.logo {
  width: 100%;
  max-width: 160px;
  margin-bottom: 20px;
}

.sidebar-spacer {
  flex: 1;
}

.expiry-btn {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background-color: var(--color-orange);
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s ease, transform 0.1s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.expiry-btn:hover {
  background-color: var(--color-orange-hover);
  transform: scale(1.05);
}

.expiry-btn:active {
  background-color: var(--color-orange-active);
  transform: scale(0.98);
}

.expiry-icon {
  width: 28px;
  height: 28px;
  filter: brightness(0) invert(1);
}

.main-content {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}
</style>
