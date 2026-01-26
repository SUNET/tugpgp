<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { open } from '@tauri-apps/plugin-dialog'
import { invoke } from '@tauri-apps/api/core'
import TButton from '../components/TButton.vue'
import DatePicker from '../components/DatePicker.vue'

const router = useRouter()
const store = useAppStore()

const keyPath = ref('')
const newDate = ref('')
const errorMessage = ref('')

// Set minimum date to tomorrow
const today = new Date()
today.setDate(today.getDate() + 1)
const minDate = today.toISOString().split('T')[0]

async function selectFile() {
  try {
    const file = await open({
      title: 'Select public key file',
      filters: [{ name: 'Public Key', extensions: ['pub', 'asc'] }]
    })
    if (file) {
      keyPath.value = file
    }
  } catch (error) {
    errorMessage.value = 'Error selecting file'
  }
}

async function goNext() {
  errorMessage.value = ''

  if (!keyPath.value) {
    errorMessage.value = 'Please select a public key file'
    return
  }

  if (!newDate.value) {
    errorMessage.value = 'Please enter a new expiry date'
    return
  }

  // Date picker already provides YYYY-MM-DD format

  try {
    const parsedData = await invoke('parse_public_key', {
      filePath: keyPath.value
    })
    store.setExpiryData(keyPath.value, newDate.value, parsedData)
    router.push('/expiry-pin')
  } catch (error) {
    errorMessage.value = `Error parsing key: ${error}`
  }
}
</script>

<template>
  <div class="update-expiry-view">
    <h1>Update Key Expiry</h1>

    <div class="form-group">
      <label>Public Key File</label>
      <div class="file-selector">
        <input
          type="text"
          :value="keyPath"
          readonly
          placeholder="No file selected"
          class="file-input"
        />
        <TButton text="Browse" @click="selectFile" />
      </div>
    </div>

    <div class="form-group">
      <label>New Expiry Date</label>
      <DatePicker v-model="newDate" :min-date="minDate" />
      <span class="hint">Select the new expiry date</span>
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton text="Next" @click="goNext" />
    </div>
  </div>
</template>

<style scoped>
.update-expiry-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

h1 {
  font-size: var(--font-size-large);
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  font-weight: 500;
  margin-bottom: 8px;
  font-size: var(--font-size-small);
}

.file-selector {
  display: flex;
  gap: 12px;
  align-items: center;
}

.file-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: var(--input-radius);
  font-size: var(--font-size-normal);
  background-color: #f5f5f5;
}

.hint {
  display: block;
  font-size: var(--font-size-small);
  color: var(--color-text-light);
  margin-top: 4px;
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
