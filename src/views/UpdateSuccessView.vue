<script setup>
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import TButton from '../components/TButton.vue'
import checkIcon from '../assets/icons/check-big.svg'

const router = useRouter()
const store = useAppStore()

function goHome() {
  router.push('/')
}
</script>

<template>
  <div class="update-success-view">
    <div class="success-content">
      <img :src="checkIcon" alt="Success" class="check-icon" />
      <div class="success-text">
        <h1>Expiry Updated Successfully</h1>
        <p class="message">Updated public key saved to:</p>
        <p class="file-path">{{ store.expiry.updatedFilePath }}</p>
      </div>
    </div>

    <div class="actions">
      <TButton text="Done" @click="goHome" />
    </div>
  </div>
</template>

<style scoped>
.update-success-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

.success-content {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  margin-bottom: 32px;
}

.check-icon {
  width: 64px;
  height: 64px;
  flex-shrink: 0;
}

.success-text h1 {
  font-size: var(--font-size-large);
  margin-bottom: 16px;
}

.message {
  font-size: var(--font-size-normal);
  color: var(--color-text);
}

.file-path {
  font-family: monospace;
  font-size: var(--font-size-small);
  background-color: #f5f5f5;
  padding: 12px;
  border-radius: 4px;
  margin-top: 8px;
  word-break: break-all;
}

.actions {
  margin-top: auto;
  display: flex;
  justify-content: flex-end;
}
</style>
