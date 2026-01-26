<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { invoke } from '@tauri-apps/api/core'
import TButton from '../components/TButton.vue'
import PinEntry from '../components/PinEntry.vue'

const router = useRouter()
const store = useAppStore()

const pin = ref('')
const errorMessage = ref('')
const isUpdating = ref(false)

const keyData = computed(() => store.expiry.parsedData)

// Format date as YYYY/MM/DD for display
const formattedNewDate = computed(() => {
  if (!store.expiry.newDate) return ''
  return store.expiry.newDate.replace(/-/g, '/')
})

async function updateExpiry() {
  errorMessage.value = ''

  if (!pin.value) {
    errorMessage.value = 'Please enter your Yubikey PIN'
    return
  }

  isUpdating.value = true

  try {
    const updatedPath = await invoke('update_key_expiry', {
      keyPath: store.expiry.keyPath,
      newDate: store.expiry.newDate,
      pin: pin.value
    })
    store.setUpdatedFilePath(updatedPath)
    router.push('/update-success')
  } catch (error) {
    errorMessage.value = error.toString()
  } finally {
    isUpdating.value = false
  }
}
</script>

<template>
  <div class="expiry-pin-view">
    <h1>Confirm Expiry Update</h1>

    <div v-if="keyData" class="key-info">
      <h2>Key Information</h2>

      <table class="info-table">
        <tbody>
          <tr>
            <th>User ID</th>
            <td>{{ keyData.userId }}</td>
          </tr>
          <tr>
            <th>Fingerprint</th>
            <td class="monospace">{{ keyData.fingerprint }}</td>
          </tr>
          <tr>
            <th>Current Expiry</th>
            <td>{{ keyData.expiry }}</td>
          </tr>
          <tr>
            <th>New Expiry</th>
            <td>{{ formattedNewDate }}</td>
          </tr>
        </tbody>
      </table>

      <h3>Subkeys</h3>
      <table class="subkeys-table">
        <thead>
          <tr>
            <th>Type</th>
            <th>Fingerprint</th>
            <th>Expiry</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="subkey in keyData.subkeys" :key="subkey.fingerprint">
            <td>{{ subkey.keyType }}</td>
            <td class="monospace">{{ subkey.fingerprint }}</td>
            <td>{{ subkey.expiry }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="form-group">
      <label>Yubikey PIN</label>
      <PinEntry v-model="pin" placeholder="Enter Yubikey PIN" />
      <span class="hint">Touch the Yubikey when it starts flashing</span>
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton
        text="Update"
        @click="updateExpiry"
        :disabled="isUpdating"
      />
    </div>
  </div>
</template>

<style scoped>
.expiry-pin-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 40px 40px 20px 100px;
}

h1 {
  font-size: var(--font-size-large);
  margin-bottom: 24px;
}

h2 {
  font-size: var(--font-size-normal);
  margin-bottom: 16px;
}

h3 {
  font-size: var(--font-size-small);
  margin-top: 24px;
  margin-bottom: 12px;
}

.key-info {
  background-color: #f5f5f5;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 24px;
}

.info-table {
  width: 100%;
  border-collapse: collapse;
}

.info-table th {
  text-align: left;
  padding: 8px 12px 8px 0;
  font-weight: 500;
  width: 120px;
  font-size: var(--font-size-small);
}

.info-table td {
  padding: 8px 0;
  font-size: var(--font-size-small);
}

.subkeys-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-size-small);
}

.subkeys-table th,
.subkeys-table td {
  text-align: left;
  padding: 8px 12px 8px 0;
}

.subkeys-table th {
  font-weight: 500;
  border-bottom: 1px solid #ddd;
}

.monospace {
  font-family: monospace;
  font-size: 12px;
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
