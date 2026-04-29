<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import TButton from '../components/TButton.vue'

const router = useRouter()
const store = useAppStore()

const fullName = ref('')
const emailsText = ref('')
const keyType = ref('rsa4k')
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

  store.setUserDetails(fullName.value.trim(), emails, keyType.value)
  router.push('/generating')
}
</script>

<template>
  <div class="user-details-view" data-testid="user-details-view">
    <h1 data-testid="user-details-heading">User Details</h1>

    <div class="form-group">
      <label for="fullName">Full Name</label>
      <input
        id="fullName"
        v-model="fullName"
        type="text"
        placeholder="Enter your full name"
        class="text-input"
        autofocus
        data-testid="input-fullname"
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
        data-testid="input-emails"
      ></textarea>
      <span class="hint">Enter one email address per line</span>
    </div>

    <div class="form-group">
      <span id="key-type-label" class="group-label">Key Type</span>
      <div
        class="radio-group"
        role="radiogroup"
        aria-labelledby="key-type-label"
        data-testid="radiogroup-key-type"
      >
        <label class="radio-option" for="key-type-rsa4k">
          <input
            id="key-type-rsa4k"
            type="radio"
            name="keyType"
            value="rsa4k"
            v-model="keyType"
            data-testid="radio-key-type-rsa4k"
          />
          <span>RSA 4096</span>
        </label>
        <label class="radio-option" for="key-type-cv25519">
          <input
            id="key-type-cv25519"
            type="radio"
            name="keyType"
            value="cv25519"
            v-model="keyType"
            data-testid="radio-key-type-cv25519"
          />
          <span>Curve25519</span>
        </label>
      </div>
    </div>

    <p v-if="errorMessage" class="error-message" data-testid="user-details-error">{{ errorMessage }}</p>

    <div class="actions">
      <TButton text="Next" @click="goNext" data-testid="btn-user-details-next" />
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

.group-label {
  display: block;
  font-weight: 500;
  margin-bottom: 8px;
  font-size: var(--font-size-small);
}

.radio-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label.radio-option {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--font-size-normal);
  font-weight: 400;
  margin-bottom: 0;
  cursor: pointer;
}

.radio-option input[type="radio"] {
  accent-color: var(--color-primary);
  width: 16px;
  height: 16px;
  cursor: pointer;
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
