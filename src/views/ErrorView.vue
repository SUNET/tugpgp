<script setup>
import { useAppStore } from '../stores/appStore'
import { getCurrentWindow } from '@tauri-apps/api/window'
import TButton from '../components/TButton.vue'
import errorIcon from '../assets/icons/errors.svg'

const store = useAppStore()

async function closeApp() {
  const window = getCurrentWindow()
  await window.close()
}
</script>

<template>
  <div class="error-view">
    <div class="error-content">
      <img :src="errorIcon" alt="Error" class="error-icon" />
      <div class="error-text">
        <h1>An Error Occurred</h1>
        <p class="message">{{ store.errorMessage || 'There was an unexpected error. Please try again.' }}</p>
      </div>
    </div>

    <div class="actions">
      <TButton text="Close" @click="closeApp" />
    </div>
  </div>
</template>

<style scoped>
.error-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

.error-content {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  margin-bottom: 32px;
}

.error-icon {
  width: 64px;
  height: 64px;
  flex-shrink: 0;
}

.error-text h1 {
  font-size: var(--font-size-large);
  margin-bottom: 12px;
}

.message {
  font-size: var(--font-size-normal);
  color: var(--color-text);
}

.actions {
  margin-top: auto;
  display: flex;
  justify-content: flex-end;
}
</style>
