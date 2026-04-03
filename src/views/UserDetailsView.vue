<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import TButton from '../components/TButton.vue'
import PinEntry from '../components/PinEntry.vue'

const router = useRouter()
const store = useAppStore()

const fullName = ref('')
const emailsText = ref('')
const password = ref('')
const errorMessage = ref('')

function goNext() {
  errorMessage.value = ''

  if (!fullName.value.trim()) {
    errorMessage.value = 'Please enter your full name'
    return
  }

  const emails = emailsText.value
    .split('\n')
    .map(e => e.trim())
    .filter(e => e.length > 0)

  if (emails.length === 0) {
    errorMessage.value = 'Please enter at least one email address'
    return
  }

  if (!password.value) {
    errorMessage.value = 'Please enter a password for your secret key'
    return
  }

  store.setUserDetails(fullName.value.trim(), emails, password.value)
  router.push('/generating')
}
</script>

<template>
  <div class="user-details-view">
    <h1>User Details</h1>

    <div class="form-group">
      <label for="fullName">Full Name</label>
      <input
        id="fullName"
        v-model="fullName"
        type="text"
        placeholder="Enter your full name"
        class="text-input"
        autofocus
      />
    </div>

    <div class="form-group">
      <label for="emails">Email Addresses</label>
      <textarea
        id="emails"
        v-model="emailsText"
        placeholder="Enter email addresses (one per line)"
        class="textarea-input"
        rows="3"
      ></textarea>
      <span class="hint">Enter one email address per line</span>
    </div>

    <div class="form-group">
      <label for="password">Password for Secret Key</label>
      <PinEntry
        v-model="password"
        placeholder="Enter password"
        name="secret-key-password"
      />
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton text="Next" @click="goNext" />
    </div>
  </div>
</template>

<style scoped>
.user-details-view {
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

.text-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: var(--input-radius);
  font-size: var(--font-size-normal);
}

.text-input:focus {
  border-color: var(--color-primary);
}

.textarea-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: var(--input-radius);
  font-size: var(--font-size-normal);
  resize: vertical;
  min-height: 80px;
}

.textarea-input:focus {
  border-color: var(--color-primary);
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
