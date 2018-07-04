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
            <div v-else-if="input.label === 'Department'">
              <department></department>
            </div>
            <div v-else-if="input.label === 'subfield'">
              <subfield></subfield>
            </div>
            <div v-else-if="input.label === 'Table of Contents'">
              <label>{{ input.label }}</label>
               <quill-editor ref="myTextEditor"
                v-model="input.value[0]">
               </quill-editor>
               <input class="quill-hidden-field" :name="etdPrefix(index)" v-model="input.value" />   
            </div>
            <div v-else-if="input.label === 'Abstract'">
               <label>{{ input.label }}</label>
               <quill-editor ref="myTextEditor"
                v-model="input.value[0]">
               </quill-editor> 
               <input class="quill-hidden-field" :name="etdPrefix(index)" v-model="input.value" /> 
            </div>
             <div v-else-if="input.label === 'Graduation Date'">
              <graduationDate></graduationDate>
            </div>
            <div v-else-if="input.label === 'Submitting Type'">
              <submittingType></submittingType>
            </div>
            <div v-else-if="input.label === 'Degree'">
              <degree></degree>
            </div>
            <div v-else-if="input.label === 'Research Field'">
              <researchField></researchField>
            </div>
            <div v-else-if="input.label === 'Language'">
              <language></language>
            </div>
            <div v-else>
              <label>{{ input.label }}</label>
              <input class="form-control" :name="etdPrefix(index)" v-model="input.value">
            </div>
          </div>
          <!--  TODO: add tab label as hidden input, for validation -->
          <button type="submit" class="btn btn-default">Submit</button>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import axios from "axios"
import VueAxios from "vue-axios"
import { formStore } from "./formStore"
import School from "./School"
import Department from './Department'
import { quillEditor } from 'vue-quill-editor'
import 'quill/dist/quill.core.css'
import 'quill/dist/quill.snow.css'
import 'quill/dist/quill.bubble.css'
import SubmittingType from './SubmittingType'
import Degree from "./Degree"
import ResearchField from "./ResearchField"
import GraduationDate from "./GraduationDate"
import Language from "./Language"
import Subfield from "./Subfield"
let token = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute("content")
axios.defaults.headers.common["X-CSRF-Token"] = token

export default {
  data() {
    return {
      form: formStore,
      tabInputs: [],
      editorOptions: {
      },
    }
  },
  components: {
    school: School,
    quillEditor: quillEditor,
    submittingType: SubmittingType,
    degree: Degree,
    researchField: ResearchField,
    graduationDate: GraduationDate,
    language: Language,
    department: Department,
    subfield: Subfield
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

.quill-hidden-field {
  display: none;
}

.quill-editor {
  height: 10em;
  margin-bottom:7em;
}
</style>
