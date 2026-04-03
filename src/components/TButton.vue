<script setup>
defineProps({
  text: {
    type: String,
    required: true
  },
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'orange'].includes(value)
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

defineEmits(['click'])
</script>

<template>
  <button
    class="t-button"
    :class="[`t-button--${variant}`, { 't-button--disabled': disabled }]"
    :disabled="disabled"
    @click="$emit('click')"
  >
    {{ text }}
  </button>
</template>

<style scoped>
.t-button {
  width: var(--button-width);
  height: var(--button-height);
  border: none;
  border-radius: var(--button-radius);
  font-size: var(--font-size-button);
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.t-button--primary {
  background-color: var(--color-primary);
}

.t-button--primary:hover:not(:disabled) {
  background-color: var(--color-primary-hover);
}

.t-button--primary:active:not(:disabled) {
  background-color: var(--color-primary-active);
}

.t-button--orange {
  background-color: var(--color-orange);
}

.t-button--orange:hover:not(:disabled) {
  background-color: var(--color-orange-hover);
}

.t-button--orange:active:not(:disabled) {
  background-color: var(--color-orange-active);
}

.t-button--disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
