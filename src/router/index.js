import { createRouter, createWebHistory } from 'vue-router'

import StartView from '../views/StartView.vue'
import UserDetailsView from '../views/UserDetailsView.vue'
import GeneratingView from '../views/GeneratingView.vue'
import YubikeyView from '../views/YubikeyView.vue'
import UploadingView from '../views/UploadingView.vue'
import UploadSuccessView from '../views/UploadSuccessView.vue'
import SaveDirView from '../views/SaveDirView.vue'
import PinsView from '../views/PinsView.vue'
import FinalView from '../views/FinalView.vue'
import ErrorView from '../views/ErrorView.vue'
import UpdateExpiryView from '../views/UpdateExpiryView.vue'
import ExpiryPinView from '../views/ExpiryPinView.vue'
import UpdateSuccessView from '../views/UpdateSuccessView.vue'

const routes = [
  {
    path: '/',
    name: 'start',
    component: StartView
  },
  {
    path: '/user-details',
    name: 'user-details',
    component: UserDetailsView
  },
  {
    path: '/generating',
    name: 'generating',
    component: GeneratingView
  },
  {
    path: '/yubikey',
    name: 'yubikey',
    component: YubikeyView
  },
  {
    path: '/uploading',
    name: 'uploading',
    component: UploadingView
  },
  {
    path: '/upload-success',
    name: 'upload-success',
    component: UploadSuccessView
  },
  {
    path: '/save-public',
    name: 'save-public',
    component: SaveDirView,
    props: { keyType: 'public' }
  },
  {
    path: '/save-secret',
    name: 'save-secret',
    component: SaveDirView,
    props: { keyType: 'secret' }
  },
  {
    path: '/pins/user',
    name: 'pins-user',
    component: PinsView,
    props: { pinType: 'user' }
  },
  {
    path: '/pins/admin',
    name: 'pins-admin',
    component: PinsView,
    props: { pinType: 'admin' }
  },
  {
    path: '/final',
    name: 'final',
    component: FinalView
  },
  {
    path: '/error',
    name: 'error',
    component: ErrorView
  },
  {
    path: '/update-expiry',
    name: 'update-expiry',
    component: UpdateExpiryView
  },
  {
    path: '/expiry-pin',
    name: 'expiry-pin',
    component: ExpiryPinView
  },
  {
    path: '/update-success',
    name: 'update-success',
    component: UpdateSuccessView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
