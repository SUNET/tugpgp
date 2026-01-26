<script setup>
import { ref } from 'vue'
import eyeVisible from '../assets/icons/eye_visible.svg'
import eyeHidden from '../assets/icons/eye_hidden.svg'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  name: {
    type: String,
    default: () => `pin-${Math.random().toString(36).slice(2)}`
  }
})

const emit = defineEmits(['update:modelValue'])

const isVisible = ref(false)

function toggleVisibility() {
  isVisible.value = !isVisible.value
}

function onBlur() {
  isVisible.value = false
}

function onInput(event) {
  emit('update:modelValue', event.target.value)
}
</script>

<template>
  <div class="pin-entry">
    <input
      :type="isVisible ? 'text' : 'password'"
      :value="modelValue"
      :placeholder="placeholder"
      :name="props.name"
      @input="onInput"
      @blur="onBlur"
      class="pin-input"
      autocomplete="off"
      data-form-type="other"
      data-lpignore="true"
      autocorrect="off"
      autocapitalize="off"
      spellcheck="false"
    />
    <button
      type="button"
      class="toggle-btn"
      @click="toggleVisibility"
      tabindex="-1"
    >
      <img :src="isVisible ? eyeVisible : eyeHidden" alt="Toggle visibility" />
    </button>
  </div>
</template>

<style scoped>
.pin-entry {
  position: relative;
  width: var(--field-width);
}

.pin-input {
  width: 100%;
  padding: 12px 50px 12px 16px;
  border: 2px solid var(--color-border);
  border-radius: var(--input-radius);
  font-size: var(--font-size-normal);
  background-color: white;
}

.pin-input:focus {
  border-color: var(--color-primary);
}

.toggle-btn {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.toggle-btn img {
  width: 24px;
  height: 24px;
}
</style>
