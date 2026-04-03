<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { invoke } from '@tauri-apps/api/core'
import WaitSpinner from '../components/WaitSpinner.vue'

const router = useRouter()
const store = useAppStore()

onMounted(async () => {
  try {
    await invoke('upload_to_yubikey')
    router.push('/upload-success')
  } catch (error) {
    store.setError(error.toString())
    router.push('/error')
  }
})
</script>

<template>
  <WaitSpinner message="Uploading to Yubikey..." />
</template>
