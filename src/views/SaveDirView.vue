<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { open } from '@tauri-apps/plugin-dialog'
import { invoke } from '@tauri-apps/api/core'
import TButton from '../components/TButton.vue'

const props = defineProps({
  keyType: {
    type: String,
    required: true,
    validator: (value) => ['public', 'secret'].includes(value)
  }
})

const router = useRouter()
const store = useAppStore()

const selectedDir = ref('')
const errorMessage = ref('')
const saveSSH = ref(true)

const isPublic = computed(() => props.keyType === 'public')
const title = computed(() => isPublic.value ? 'Save Public Key' : 'Save Secret Key')
const fingerprint = computed(() => store.keyData.fingerprint.replace(/\s/g, '').slice(-8))
const filename = computed(() => isPublic.value ? `${fingerprint.value}.pub` : `${fingerprint.value}.sec`)
const sshFilename = computed(() => `${fingerprint.value}_ssh.pub`)
const hasSSHKey = computed(() => isPublic.value && store.keyData.sshPublicKey && !store.keyData.sshPublicKey.includes('not available'))

async function selectDirectory() {
  try {
    const dir = await open({
      directory: true,
      title: 'Select directory to save key'
    })
    if (dir) {
      selectedDir.value = dir
    }
  } catch (error) {
    errorMessage.value = 'Error selecting directory'
  }
}

async function saveKey() {
  errorMessage.value = ''

  if (!selectedDir.value) {
    errorMessage.value = 'Please select a directory first'
    return
  }

  try {
    const content = isPublic.value ? store.keyData.publicKey : store.keyData.secretKey
    await invoke('save_key_to_file', {
      dirPath: selectedDir.value,
      filename: filename.value,
      content: content
    })

    // Also save SSH key if checked and available
    if (isPublic.value && saveSSH.value && hasSSHKey.value) {
      await invoke('save_key_to_file', {
        dirPath: selectedDir.value,
        filename: sshFilename.value,
        content: store.keyData.sshPublicKey
      })
    }

    goNext()
  } catch (error) {
    errorMessage.value = `Error saving key: ${error}`
  }
}

function skip() {
  goNext()
}

function goNext() {
  if (isPublic.value) {
    if (store.allowSecretSave) {
      router.push('/save-secret')
    } else {
      router.push('/pins/user')
    }
  } else {
    router.push('/pins/user')
  }
}
</script>

<template>
  <div class="save-dir-view">
    <h1>{{ title }}</h1>

    <div class="form-group">
      <label>Directory</label>
      <div class="dir-selector">
        <input
          type="text"
          :value="selectedDir"
          readonly
          placeholder="No directory selected"
          class="dir-input"
        />
        <TButton text="Browse" @click="selectDirectory" />
      </div>
    </div>

    <div v-if="selectedDir" class="file-preview">
      <p>File will be saved as: <strong>{{ filename }}</strong></p>
      <div v-if="hasSSHKey" class="ssh-option">
        <label class="checkbox-label">
          <input type="checkbox" v-model="saveSSH" />
          <span>Also save SSH public key as <strong>{{ sshFilename }}</strong></span>
        </label>
      </div>
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton v-if="!isPublic" text="Skip" variant="orange" @click="skip" />
      <TButton text="Save" @click="saveKey" :disabled="!selectedDir" />
    </div>
  </div>
</template>

<style scoped>
.save-dir-view {
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

.dir-selector {
  display: flex;
  gap: 12px;
  align-items: center;
}

.dir-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: var(--input-radius);
  font-size: var(--font-size-normal);
  background-color: #f5f5f5;
}

.file-preview {
  background-color: #f5f5f5;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 24px;
}

.ssh-option {
  margin-top: 12px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: var(--font-size-small);
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.error-message {
  color: var(--color-error);
  margin-bottom: 16px;
}

.actions {
  display: flex;
  gap: 16px;
  margin-top: auto;
  justify-content: flex-end;
}
</style>
