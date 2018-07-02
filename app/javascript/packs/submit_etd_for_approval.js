import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(TurbolinksAdapter, VueAxios, axios)

document.addEventListener('turbolinks:load', function () {
  let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  axios.defaults.headers.common['X-CSRF-Token'] = token
  axios.defaults.headers.common['Content-Type'] = 'multipart/form-data'

  Vue.component('submit-for-approval', {
    data: function () {
      return {
      }
    },
    methods: {
      getEtdData: function(){
        var form = document.getElementById("etd_form")
        var formData = new FormData(form)
        return formData
      },
      submitEtd: function(){
        axios.post('/concern/etds', this.getEtdData()
        )
        .then(response => {})
        .catch(e => {
          this.errors.push(e)
        })
      }
    },
    template: '<button v-on:click="submitEtd">Submit Etd For Approval</button>'
  })

  new Vue({
    el: '#submit-etd'})
})
