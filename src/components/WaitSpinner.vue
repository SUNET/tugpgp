<script setup>
import hourglassIcon from '../assets/icons/hour-glass.svg'

defineProps({
  message: {
    type: String,
    default: 'Please wait...'
  }
})
</script>

<template>
  <div class="wait-spinner">
    <img :src="hourglassIcon" alt="Loading" class="hourglass" />
    <p class="message">{{ message }}</p>
  </div>
</template>

<style scoped>
.wait-spinner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 400px;
}

.hourglass {
  width: 80px;
  height: 80px;
  animation: spin 2s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.message {
  margin-top: 24px;
  font-size: var(--font-size-large);
  color: var(--color-text);
}
</style>
