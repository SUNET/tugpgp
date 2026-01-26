import { defineStore } from 'pinia'

export const useAppStore = defineStore('app', {
  state: () => ({
    // User input from form
    fullName: '',
    emails: [],
    password: '',

    // Generated key data (from Rust backend)
    keyData: {
      publicKey: '',
      secretKey: '',
      fingerprint: '',
      sshPublicKey: '',
      subkeys: []
    },

    // PIN values
    userPin: '',
    adminPin: '',

    // Application flags
    allowSecretSave: false,
    isBackupMode: false,

    // Error state
    errorMessage: '',

    // Expiry update flow
    expiry: {
      keyPath: '',
      newDate: '',
      parsedData: null,
      updatedFilePath: ''
    }
  }),

  actions: {
    setUserDetails(name, emails, password) {
      this.fullName = name
      this.emails = emails
      this.password = password
    },

    setKeyData(data) {
      this.keyData = data
    },

    setUserPin(pin) {
      this.userPin = pin
    },

    setAdminPin(pin) {
      this.adminPin = pin
    },

    setError(message) {
      this.errorMessage = message
    },

    clearError() {
      this.errorMessage = ''
    },

    enableBackupMode() {
      this.isBackupMode = true
      this.keyData = {
        publicKey: '',
        secretKey: '',
        fingerprint: '',
        sshPublicKey: '',
        subkeys: []
      }
      this.userPin = ''
      this.adminPin = ''
    },

    setExpiryData(path, date, parsed) {
      this.expiry.keyPath = path
      this.expiry.newDate = date
      this.expiry.parsedData = parsed
    },

    setUpdatedFilePath(path) {
      this.expiry.updatedFilePath = path
    },

    reset() {
      this.fullName = ''
      this.emails = []
      this.password = ''
      this.keyData = {
        publicKey: '',
        secretKey: '',
        fingerprint: '',
        sshPublicKey: '',
        subkeys: []
      }
      this.userPin = ''
      this.adminPin = ''
      this.allowSecretSave = false
      this.isBackupMode = false
      this.errorMessage = ''
      this.expiry = {
        keyPath: '',
        newDate: '',
        parsedData: null,
        updatedFilePath: ''
      }
    }
  }
})
