<script setup>
import { useRouter } from 'vue-router'
import TButton from '../components/TButton.vue'

const router = useRouter()

function goNext() {
  router.push('/user-details')
}
</script>

<template>
  <div class="start-view" data-testid="start-view">
    <div class="content">
      <p class="welcome-text" data-testid="start-heading">Welcome to Tugpgp.</p>
      <p class="welcome-text" data-testid="start-message">Click next to begin the process.</p>
    </div>
    <div class="actions">
      <TButton text="Next" @click="goNext" data-testid="btn-start-next" />
    </div>
  </div>
</template>

<style scoped>
.start-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  width: 100%;
}

.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding-left: 100px;
}

.welcome-text {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin: 0;
  line-height: 1.6;
}

.actions {
  display: flex;
  justify-content: flex-end;
  padding: 20px;
  padding-right: 40px;
}
</style>
