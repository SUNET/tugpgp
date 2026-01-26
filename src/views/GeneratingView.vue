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
    const keyData = await invoke('generate_key', {
      name: store.fullName,
      emails: store.emails,
      password: store.password
    })
    store.setKeyData(keyData)
    router.push('/yubikey')
  } catch (error) {
    store.setError(error.toString())
    router.push('/error')
  }
})
</script>

<template>
  <WaitSpinner message="Generating keys..." />
</template>
