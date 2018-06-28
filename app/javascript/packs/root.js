import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import App from '../app.vue'
import { formStore } from '../form_store'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(TurbolinksAdapter, axios, VueAxios)

document.addEventListener('turbolinks:load', () => {
  let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  axios.defaults.headers.common['X-CSRF-Token'] = token

  const app = new Vue({
    el: '#root',
    data: formStore,
    components: { App }
  })
})
