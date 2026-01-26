<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { invoke } from '@tauri-apps/api/core'
import TButton from '../components/TButton.vue'
import yubikeyImg from '../assets/images/yk.png'
import warningIcon from '../assets/icons/warning.svg'

const router = useRouter()
const store = useAppStore()

const showWarning = ref(false)
const errorMessage = ref('')

async function handleClick() {
  errorMessage.value = ''

  // Check if Yubikey is connected
  try {
    const connected = await invoke('is_yubikey_connected')
    if (!connected) {
      errorMessage.value = 'Yubikey not detected. Please connect your Yubikey and try again.'
      return
    }
  } catch (error) {
    errorMessage.value = 'Error checking Yubikey connection.'
    return
  }

  if (!showWarning.value) {
    // First click - show warning
    showWarning.value = true
  } else {
    // Second click - proceed with upload
    router.push('/uploading')
  }
}
</script>

<template>
  <div class="yubikey-view">
    <h1>Connect Yubikey</h1>

    <div class="yubikey-image">
      <img :src="yubikeyImg" alt="Yubikey" />
    </div>

    <p class="instruction">
      Please connect your Yubikey, and click next.
    </p>

    <div v-if="showWarning" class="warning-box">
      <img :src="warningIcon" alt="Warning" class="warning-icon" />
      <div class="warning-text">
        <strong>Warning:</strong> This will overwrite any existing keys on your Yubikey.
        Click again to confirm.
      </div>
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton :text="showWarning ? 'Confirm' : 'Next'" @click="handleClick" />
    </div>
  </div>
</template>

<style scoped>
.yubikey-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

h1 {
  font-size: var(--font-size-large);
  margin-bottom: 24px;
}

.yubikey-image {
  margin-bottom: 24px;
}

.yubikey-image img {
  max-width: 200px;
}

.instruction {
  font-size: var(--font-size-normal);
  margin-bottom: 24px;
}

.warning-box {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background-color: var(--color-warning);
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 24px;
}

.warning-icon {
  width: 32px;
  height: 32px;
  flex-shrink: 0;
}

.warning-text {
  font-size: var(--font-size-small);
  color: #333;
}

.error-message {
  color: var(--color-error);
  margin-bottom: 16px;
}

.actions {
  margin-top: auto;
  display: flex;
  justify-content: flex-end;
}
</style>
