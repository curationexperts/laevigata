import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import App from '../App'
import { formStore } from '../formStore'
import axios from 'axios'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  var element = document.getElementById('root')
  if (element != null) {
    let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    axios.defaults.headers.common['X-CSRF-Token'] = token

    var app = new Vue({
      el: element,
      data: formStore,
      components: { App }
    })
  }
})
