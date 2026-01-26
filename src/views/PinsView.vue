<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/appStore'
import { invoke } from '@tauri-apps/api/core'
import TButton from '../components/TButton.vue'
import PinEntry from '../components/PinEntry.vue'
import checkIcon from '../assets/icons/check-big.svg'

const props = defineProps({
  pinType: {
    type: String,
    required: true,
    validator: (value) => ['user', 'admin'].includes(value)
  }
})

const router = useRouter()
const store = useAppStore()

const pin = ref('')
const repeatPin = ref('')
const errorMessage = ref('')

const isUserPin = computed(() => props.pinType === 'user')
const title = computed(() => isUserPin.value ? 'Set User PIN' : 'Set Admin PIN')
const minLength = computed(() => isUserPin.value ? 6 : 8)
const hint = computed(() => `Minimum ${minLength.value} characters`)

// Live PIN matching validation
const pinLengthOk = computed(() => pin.value.length >= minLength.value)
const pinsMatch = computed(() => pin.value.length > 0 && repeatPin.value.length > 0 && pin.value === repeatPin.value)
const canSubmit = computed(() => pinLengthOk.value && pinsMatch.value)

async function setPin() {
  errorMessage.value = ''

  if (pin.value.length < minLength.value) {
    errorMessage.value = `PIN must be at least ${minLength.value} characters`
    return
  }

  if (pin.value !== repeatPin.value) {
    errorMessage.value = 'PINs do not match'
    return
  }

  try {
    if (isUserPin.value) {
      await invoke('set_user_pin', { pin: pin.value })
      store.setUserPin(pin.value)
      router.push('/pins/admin')
    } else {
      await invoke('set_admin_pin', { pin: pin.value })
      store.setAdminPin(pin.value)
      router.push('/final')
    }
  } catch (error) {
    errorMessage.value = error.toString()
  }
}
</script>

<template>
  <div class="pins-view">
    <h1>{{ title }}</h1>

    <div class="form-group">
      <label>{{ isUserPin ? 'User PIN' : 'Admin PIN' }}</label>
      <div class="input-with-indicator">
        <PinEntry v-model="pin" :placeholder="`Enter ${pinType} PIN`" :name="`${pinType}-pin-entry`" />
        <span v-if="pinLengthOk" class="check-indicator">
          <img :src="checkIcon" alt="OK" />
        </span>
      </div>
      <span class="hint">{{ hint }}</span>
    </div>

    <div class="form-group">
      <label>Repeat PIN</label>
      <div class="input-with-indicator">
        <PinEntry v-model="repeatPin" placeholder="Repeat PIN" :name="`${pinType}-pin-repeat`" />
        <span v-if="pinsMatch" class="check-indicator match">
          <img :src="checkIcon" alt="Match" />
        </span>
      </div>
      <span v-if="repeatPin.length > 0 && !pinsMatch" class="mismatch-hint">PINs do not match</span>
    </div>

    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div class="actions">
      <TButton text="Next" @click="setPin" :disabled="!canSubmit" />
    </div>
  </div>
</template>

<style scoped>
.pins-view {
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

.input-with-indicator {
  display: flex;
  align-items: center;
  gap: 12px;
}

.check-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  flex-shrink: 0;
}

.check-indicator img {
  width: 24px;
  height: 24px;
  filter: invert(48%) sepia(79%) saturate(2476%) hue-rotate(86deg) brightness(95%) contrast(92%);
}

.check-indicator.match img {
  filter: invert(48%) sepia(79%) saturate(2476%) hue-rotate(86deg) brightness(95%) contrast(92%);
}

.hint {
  display: block;
  font-size: var(--font-size-small);
  color: var(--color-text-light);
  margin-top: 4px;
}

.mismatch-hint {
  display: block;
  font-size: var(--font-size-small);
  color: var(--color-error);
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
