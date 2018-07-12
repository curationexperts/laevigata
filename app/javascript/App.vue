<template>
  <div>
    <ul class="nav navtabs">
      <li v-for="(value,index) in form.tabs" v-bind:key="value.label">
        <a href="#" data-turbolinks="false" class="tab" v-bind:class="{ disabled: value.disabled }" v-on:click="setCurrentStep(value.label)">{{ value.label }}</a>
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
            </div>
            <div v-else-if="input.label === 'Department'">
              <department></department>
            </div>
            <div v-else-if="input.label === 'subfield'">
              <subfield></subfield>
            </div>
            <div v-else-if="input.label === 'files'">
              <primary-file-uploader></primary-file-uploader>
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
            <div v-else-if="input.label === 'Committee Member'">
              <committeeMember></committeeMember>
            </div>
            <div v-else-if="input.label === 'Degree'">
              <degree></degree>
            </div>
            <div v-else-if="input.label === 'Research Field'">
              <researchField></researchField>
            </div>
            <div v-else-if="input.label === 'Embargo'">
              <embargo></embargo>
            </div>
            <div v-else-if="input.label === 'Copyright & Patents'">
              <copyrightQuestions></copyrightQuestions>
            </div>
            <div v-else-if="input.label === 'Language'">
              <language></language>
            </div>
            <div v-else>
              <label>{{ input.label }}</label>
              <input class="form-control" :ref="index" :name="etdPrefix(index)" v-model="input.value">
            </div>
          </div>
          <input name="etd[currentTab]" type="hidden" :value="value.label" />
          <input name="etd[currentStep]" type="hidden" :value="value.step" />
          <button type="submit" class="btn btn-default">Save and Continue</button>
          <section v-if="errored">
            Invalidation Errors happened:
              <p>{{ errors }}</p>
          </section>
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
import CommitteeMember from "./CommitteeMember"
import PrimaryFileUploader from './PrimaryFileUploader.vue'
import CopyrightQuestions from './CopyrightQuestions'
import Embargo from './Embargo'

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
    primaryFileUploader: PrimaryFileUploader,
    copyrightQuestions: CopyrightQuestions,
    embargo: Embargo
  },
  mounted(){
    this.loadSavedData();
  },
  methods: {
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
    setCurrentStep(tab_label){
      for (var tab in this.form.tabs){
        if (this.form.tabs[tab].label == tab_label){
          this.form.tabs[tab].currentStep = true
        } else {
          this.form.tabs[tab].currentStep = false
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
      var that = this;
      axios
        .post("/in_progress_etds", this.getFormData(), {
          config: { headers: { "Content-Type": "multipart/form-data" } }
        })
        .then(response => {
          that.errored = false
          that.errors = []
          that.nextStepIsCurrent(response.data.lastCompletedStep)
          that.setComplete(response.data.tab_name)
          that.enableTabs()
        })
        .catch(error => {
          that.errored = true
          that.errors = []
          that.errors.push(error.response.data.errors)
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
</style>
