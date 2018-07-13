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
            </div>
            <div v-else-if="input.label === 'Department'">
              <department></department>
            </div>
            <div v-else-if="input.label === 'subfield'">
              <subfield></subfield>
            </div>
            <div v-else-if="input.label === 'files'">
              <files></files>
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

          <div v-for="(value, key) in value.fields">
            <label>{{ key }}</label>
            <span>{{ value }}</span>
          </div>

          <input name="etd[currentTab]" type="hidden" :value="value.label" />
          <input name="etd[currentStep]" type="hidden" :value="value.step" />
          <save-and-submit></save-and-submit>
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
import Files from './Files.vue'
import CopyrightQuestions from './CopyrightQuestions'
import Embargo from './Embargo'
import SaveAndSubmit from './SaveAndSubmit'

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
  provide: function () {
    return {
      getErrors: this.errors,
      getErrored: this.errored
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
    saveAndSubmit: SaveAndSubmit
  },
  mounted(){
    this.loadSavedData();
  },
  methods: {
    loadSavedData(){
      var el = document.getElementById('saved_data');
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
    isComplete(tab) {
      return tab;
    },
    allTabsComplete(){
      var complete = [];
      for (var tab in this.form.tabs){
        complete.push(this.form.tabs[tab].completed)
      }
      return true //complete.every(this.isComplete);
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
    submitTab(){
        var saveAndSubmit = new SaveAndSubmit({
          formStore: this.sharedState,
          token: token,
          event: e,
          formData: this.getFormData(),
          navigator: ""
        })
        saveAndSubmit.submitTab()

    },
    readyForReview(){
      // probably will not need this, save will go from embargo tab to review tab naturally
      // all tabs are complete but user has not checked agreement
      return true //this.allTabsComplete() && this.form.agreement == false
    },
    displayDataForReview(){
      var that = this;
      axios.get('/in_progress_etds/4', { config: { headers: { "Content-Type": "application/json" } } })
      .then(response => {
        that.form.showSavedData(response.data)
        // for now fake that user got here naturally
        that.nextStepIsCurrent(6)
        that.setComplete('embargo')
        that.enableTabs()
      })
      .catch(error => {
        console.log('an error', error)
      })
    },
    getEtdData: function(){
      var formData = this.getFormData()
      //TODO: may need to remove other params
      formData.delete('etd[currentTab]')

      return formData
    },
    readyForSubmission(){
      return this.allTabsComplete() && this.form.agreement == true
    },
    submitForPublication(){
      // clean this that this up
      var that = this;
      // TODO: change text of submit button to say submit for publication
      // get the data
      axios.get('/in_progress_etds/4', { config: { headers: { "Content-Type": "application/json" } } })
      .then(response => {
        document.getElementById('saved_data').dataset.in_progress_etd = response.data
        // populate form in order to use its inputs
        that.loadSavedData()
        // submit as form data
        axios.post('/concern/etds', this.getEtdData()
        )
        .then(response => {})
        .catch(e => {
          this.errors.push(e)
        })
      })
      .catch(error => {
        console.log('an error', error)
      })
    },
    onSubmit() {
      var that = this;
      if (this.readyForReview()){
        console.log('ready for review')
        this.displayDataForReview()
      } else if (this.readyForSubmission()){
        console.log('ready for submission')
        this.submitForPublication()
      } else {
        console.log('regular submit')
        this.submitTab()
      }
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
