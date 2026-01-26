<script setup>
import { useRouter } from 'vue-router'
import TButton from '../components/TButton.vue'
import successIcon from '../assets/icons/upload_success.svg'

const router = useRouter()

function goNext() {
  router.push('/save-public')
}
</script>

<template>
  <div class="upload-success-view">
    <div class="success-content">
      <img :src="successIcon" alt="Success" class="success-icon" />
      <p class="message">Upload successful. Click next to continue.</p>
    </div>

    <div class="actions">
      <TButton text="Next" @click="goNext" />
    </div>
  </div>
</template>

<style scoped>
.upload-success-view {
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

.success-icon {
  width: 64px;
  height: 64px;
}

.message {
  font-size: var(--font-size-normal);
}

.actions {
  margin-top: auto;
  display: flex;
  justify-content: flex-end;
}
</style>
