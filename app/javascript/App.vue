<template>
  <div>
    <ul class="nav navtabs">
      <li v-for="(value,index) in form.tabs" v-bind:key="value.label">
        <a href="#" data-turbolinks="false" class="tab" v-bind:class="{ disabled: value.disabled }" v-on:click="setCurrentStep(value.label, $event)">{{ value.label }}</a>
      </li>
    </ul>
    <form role="form" id="vue_form" action="/concern/etds/new" method="post" @submit.prevent="onSubmit">
      <div v-for="value in form.tabs" v-bind:key="value.label">
        <div class="tab-content form-group" v-if="value.currentStep">
          <h1> {{ value.label }} </h1>
          <p>
            {{ value.help_text }}
          </p>
          <div v-for="(input, index) in value.inputs" v-bind:key="index">
            <div v-if="input.label === 'School'">
              <school></school>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Department'">
              <department></department>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'subfield'">
              <subfield></subfield>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'files'">
              <files></files>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Table of Contents'">
              <label>{{ input.label }}</label>
               <quill-editor ref="myTextEditor"
                v-model="input.value[0]">
               </quill-editor>
               <input class="quill-hidden-field" :name="etdPrefix(index)" v-model="input.value" />
               <section class='errorMessage' v-if="displayError(index)">
                   <p>{{ input.label }} is required</p>
               </section>
            </div>
            <div v-else-if="input.label === 'Abstract'">
               <label>{{ input.label }}</label>
               <quill-editor ref="myTextEditor"
                v-model="input.value[0]">
               </quill-editor>
               <input class="quill-hidden-field" :name="etdPrefix(index)" v-model="input.value" />
               <section class='errorMessage' v-if="displayError(index)">
                   <p>{{ input.label }} is required</p>
               </section>
            </div>
             <div v-else-if="input.label === 'Graduation Date'">
              <graduationDate></graduationDate>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Submitting Type'">
              <submittingType></submittingType>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Committee Member'">
              <committeeMember></committeeMember>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Degree'">
              <degree></degree>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Research Field'">
              <researchField></researchField>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Embargo'">
              <embargo></embargo>
            </div>
            <div v-else-if="input.label === 'Keyword'">
              <keywords></keywords>
            </div>
            <div v-else-if="input.label === 'Copyright & Patents'">
              <copyrightQuestions></copyrightQuestions>
            </div>
            <div v-else-if="input.label === 'Language'">
              <language></language>
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else>
              <label>{{ input.label }}</label>
              <input class="form-control" :ref="index" :name="etdPrefix(index)" v-model="input.value">
              <section class='errorMessage' v-if="displayError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
          </div>
          <input name="etd[currentTab]" type="hidden" :value="value.label" />
          <input name="etd[currentStep]" type="hidden" :value="value.step" />
          <button type="submit" class="btn btn-default">Save and Continue</button>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import axios from "axios"
import VueAxios from "vue-axios"
import _ from "lodash"
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
import CommitteeMember from "./CommitteeMember"
import Files from './Files.vue'
import CopyrightQuestions from './CopyrightQuestions'
import Embargo from './Embargo'
import Keywords from './Keywords'

let token = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute("content")
axios.defaults.headers.common["X-CSRF-Token"] = token

export default {
  data() {
    return {
      form: formStore,
      tabInputs: [],
      files: [],
      deleteableFiles: [],
      editorOptions: {
      },
      errored: false,
      errors: [],
      lastCompletedStep: 0
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
    subfield: Subfield,
    committeeMember: CommitteeMember,
    files: Files,
    copyrightQuestions: CopyrightQuestions,
    embargo: Embargo,
    keywords: Keywords
  },
  mounted(){
    this.loadSavedData();
  },
  methods: {
    displayError(input_key){
      var isError = false;
      _.forEach(this.errors, function(error) {
        _.forEach(error, function(value, key){
          if (input_key == key){
            isError = true;
          }
        })
      });
      return isError;
    },
    loadSavedData(){
      var el = document.getElementById('saved_data');
      // when the load this form the first time, there will not be
      // any data in the data- attribute, therefore, pass empty
      // hash rather than undefined.
      var savedData = {}
      if (el && el.hasAttribute("data-in-progress-etd")){
        savedData = JSON.parse(el.dataset.inProgressEtd);
      }
      this.form.loadSavedData(savedData);
    },
    // tabs that have been validated and the current tab are enabled
    enableTabs(){
      for (var tab in this.form.tabs){
        if (this.form.tabs[tab].complete == true || this.form.tabs[tab].currentStep == true){
          this.form.tabs[tab].disabled = false
        } else {
          this.form.tabs[tab].disabled = true
        }
      }
    },
    setComplete(tab_name){
      for (var tab in this.form.tabs){
        if (this.form.tabs[tab].label == tab_name){
          this.form.tabs[tab].complete = true
        }
      }
    },
    setCurrentStep(tab_label, event){
      // display current tab unless click comes from disabled tab
      if (!event.target.classList.contains("disabled")){
        for (var tab in this.form.tabs){
          if (this.form.tabs[tab].label == tab_label){
            this.form.tabs[tab].currentStep = true
          } else {
            this.form.tabs[tab].currentStep = false
          }
        }
      }
    },
    nextStepIsCurrent(lastCompletedStep){
      for (var tab in this.form.tabs){
        if (this.form.tabs[tab].step == parseInt(lastCompletedStep) + 1) {
          this.form.tabs[tab].currentStep = true
        } else {
          this.form.tabs[tab].currentStep = false
        }
      }
    },
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
        .then(response => {
          this.errored = false
          this.errors = []
          this.nextStepIsCurrent(response.data.lastCompletedStep)
          this.setComplete(response.data.tab_name)
          this.enableTabs()
        })
        .catch(error => {
          this.errored = true
          this.errors = []
          this.errors.push(error.response.data.errors)
        })
    }
  }
}
</script>

<style scoped>
ul {
     margin-bottom: 2em;
     border-bottom: 1px solid #00000029;
     box-shadow: 0px 2px 6px whitesmoke;
     width: 100%;
}
 li {
     margin: 0;
     display: block;
     float: left;
     list-style: none;
     position: relative;
     margin-bottom: 0;
     min-width:100px;
     text-align: center
}
 ul li a {
     display: block;
     line-height: 1.3em;
     font-family: "PT Sans", sans;
     border: 1px solid rgba(0,0,0,0.15);
     border-bottom: 0;
     box-shadow: 1px 1px .5px rgba(0,0,0,0.06);
     border-top-left-radius: 5px;
     border-top-right-radius: 5px;
     padding: 1em;
     margin-right: 0.5em;
}

 .disabled {
     color: #cdcdcd;
     cursor: not-allowed !important;
 }

 .tab-content > * {
     margin-right: 2em;
     margin-bottom: 1em;
}
 .tab-content > h1 {
     padding-left: 0;
     margin-bottom:0.4em;
}
 .tab-content > button {
     margin-bottom:1.5em;
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

.errorMessage{
  color: red;
}
</style>
