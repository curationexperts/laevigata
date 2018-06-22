import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VueAxios from 'vue-axios'
import App from '../app.vue'


Vue.use(TurbolinksAdapter, VueAxios, axios)

document.addEventListener('turbolinks:load', function () {

  Vue.component('submit-for-approval', {
    data: function () {
      return {
        postBody: ''
      }
    },
    methods: {
      submitEtd: function(){
        axios.post(`/concern/etds`, {
          body: document.getElementById('postBody').value
        })
        .then(response => {})
        .catch(e => {
          this.errors.push(e)
        })
      }
    },
    template: '<button v-on:click="submitEtd">Submit Etd For Approval</button>'
  })

  new Vue({ el: '#submit-etd' })
})
