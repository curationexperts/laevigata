import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VueAxios from 'vue-axios'
import App from '../app.vue'


Vue.use(TurbolinksAdapter, VueAxios, axios)

document.addEventListener('turbolinks:load', function () {
    // mount the root Vue instance
    new Vue({
        el: '#school-vue',
        created: function() {
            this.fetchData();
        },
        data: {
            schools: {
                'candler': 'http://localhost:3000/authorities/terms/local/candler_programs',
                'emory': 'http://localhost:3000/authorities/terms/local/emory_programs',
                'laney': 'http://localhost:3000/authorities/terms/local/laney_programs',
                'rollins': 'http://localhost:3000/authorities/terms/local/rollins_programs'
            },
            departments: [],
            selected_department: [],
            selected: 'candler',
            options: [
                { text: 'Candler School of Theology', value: 'candler' },
                { text: 'Emory College', value: 'emory' },
                { text: 'Laney Graduate School', value: 'laney' },
                { text: 'Rollins School of Public Health', value: 'rollins' }
            ]
        },
        methods: {
            fetchData: function()  {
                var my_school = this.schools[this.selected]
                axios.get(my_school).then((response) => {
                  this.departments = response.data
                })
            }
        },
        watch: {
            selected: function() {
                this.fetchData()
            }
        }
    })
})
