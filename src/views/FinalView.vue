<script setup>
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { getCurrentWindow } from '@tauri-apps/api/window'
import TButton from '../components/TButton.vue'
import checkIcon from '../assets/icons/check-big.svg'

const router = useRouter()
const store = useAppStore()

function createBackupKey() {
  store.enableBackupMode()
  router.push('/yubikey')
}

async function done() {
  const window = getCurrentWindow()
  await window.destroy()
}
</script>

<template>
  <div class="final-view">
    <div class="success-content">
      <img :src="checkIcon" alt="Success" class="check-icon" />
      <h1>Your Yubikey is now ready.</h1>
    </div>

    <p class="description">
      Your OpenPGP keys have been generated and uploaded to your Yubikey.
      You can now use your Yubikey for encryption, signing, and authentication.
    </p>

    <div class="actions">
      <TButton text="Create Backup Key" variant="orange" @click="createBackupKey" />
      <TButton text="Done" @click="done" />
    </div>
  </div>
</template>

<style scoped>
.final-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

.success-content {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 32px;
}

.check-icon {
  width: 64px;
  height: 64px;
}

h1 {
  font-size: var(--font-size-large);
}

.description {
  font-size: var(--font-size-normal);
  color: var(--color-text);
  margin-bottom: 32px;
}

.actions {
  display: flex;
  gap: 16px;
  margin-top: auto;
  justify-content: flex-end;
}
</style>
