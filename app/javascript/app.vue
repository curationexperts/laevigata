<template>
  <div>
    <ul>
      <li v-for="(value,index) in form.tabs" v-bind:key="value.label">
        <a href="#" data-turbolinks="false" class="tab" v-on:click="form.toggleSelected(index)">{{ value.label }}</a>
      </li>
    </ul>
    <form role="form" id="vue_form" action="/concern/etds/new" method="post" @submit.prevent="onSubmit">
      <div v-for="value in form.tabs" v-bind:key="value.label">
        <div class="tab-content form-group" v-if="value.selected">
          <h1> {{ value.label }} </h1>
          <div v-for="(input, index) in value.inputs" v-bind:key="index">
            <div v-if="input.label === 'School'">
              <school></school>
            </div>
            <div v-else>
              <label>{{ input.label }}</label>
              <input class="form-control" :name="etdPrefix(index)" v-model="input.value">
            </div>
          </div>
          <button type="submit" class="btn btn-default">Submit</button>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import axios from "axios"
import VueAxios from "vue-axios"
import { formStore } from "./form_store"
import School from "./school"

let token = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute("content")
axios.defaults.headers.common["X-CSRF-Token"] = token

export default {
  data() {
    return {
      form: formStore,
      tabInputs: []
    }
  },
  components: {
    school: School
  },
  methods: {
    etdPrefix(index) {
      return "etd[" + index + "]"
    },
    getFormData() {
      var form = document.getElementById("vue_form")
      var formData = new FormData(form)
      return formData
    },
    onSubmit() {
      axios
        .post("/in_progress_etds", this.getFormData(), {
          config: { headers: { "Content-Type": "multipart/form-data" } }
        })
        .then(response => {})
        .catch(e => {
          this.errors.push(e)
        })
    }
  }
}
</script>

<style scoped>
ul {
  clear: left;
  float: left;
  list-style: none;
  position: relative;
  margin: 0;
  padding: 0;
}
li {
  margin: 1em;
  display: block;
  float: left;
  list-style: none;
  position: relative;
}
ul li a {
  display: block;
  line-height: 1.3em;
  font-family: "PT Sans", sans;
}

.tab-content {
  clear: left;
}

input {
  margin-bottom: 1em;
}
</style>
