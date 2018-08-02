<template>
  <div data-turbolinks="false">
    <section aria-labelledby="form-label">
      <h1>Submit Your Thesis or Dissertation</h1>
    <ul class="nav navtabs" v-if="allowTabSave()">
      <li v-for="(value, index) in sharedState.tabs" v-bind:key="index">
        <button type="button" class="tab" v-bind:class="{ disabled: value.disabled }" v-on:click="setCurrentStep(value.label, $event)">{{ value.label }} 
          <font-awesome-icon class="check-circle" icon="check-circle" v-show="sharedState.isValid(index)">
          </font-awesome-icon>
        </button>
      </li>
    </ul>
    <form role="form" id="vue_form" :action="sharedState.getUpdateRoute()" method="patch" @submit.prevent="onSubmit">
      <div v-for="value in sharedState.tabs" v-bind:key="value.label">
        <div class="tab-content form-group" v-if="(value.currentStep && allowTabSave()) || !allowTabSave()">
          <h2> {{ value.label }} </h2>
          <section aria-live="assertive">
            {{ value.help_text }}
          </section>
          <div v-for="(input, index) in value.inputs" v-bind:key="index">
            <div v-if="input.label === 'School'">
              <school></school>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Department'">
              <department></department>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
              <section class='errorMessage' v-if="sharedState.hasError('schoolDeptMismatch')">
                  <p>You have not saved the school that is currently selected in 'About Me'. No departments are available.</p>
              </section>
            </div>
            <div v-else-if="input.label === 'subfield'">
              <subfield></subfield>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'files'">
              <files></files>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Table of Contents'">
              <label>{{ input.label }}</label>
               <quill-editor :options="editorOptions" ref="myTextEditor" v-model="input.value" v-on:change="sharedState.setValid('My Etd', false)">
               </quill-editor>
               <input class="quill-hidden-field" :name="sharedState.etdPrefix(index)" v-model="input.value" />
               <section class='errorMessage' v-if="sharedState.hasError(index)">
                   <p>{{ input.label }} is required</p>
               </section>
            </div>
            <div v-else-if="input.label === 'Abstract'">
               <label>{{ input.label }}</label>
               <quill-editor :options="editorOptions" ref="myTextEditor" v-model="input.value" v-on:change="sharedState.setValid('My Etd', false)">
               </quill-editor>
               <input class="quill-hidden-field" :name="sharedState.etdPrefix(index)" v-model="input.value" />
               <section class='errorMessage' v-if="sharedState.hasError(index)">
                   <p>{{ input.label }} is required</p>
               </section>
            </div>
             <div v-else-if="input.label === 'Graduation Date'">
              <graduationDate></graduationDate>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Submitting Type'">
              <submittingType></submittingType>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Committee Member'">
              <committeeMember></committeeMember>
              <section class='errorMessage' v-if="sharedState.hasError('committee_chair_attributes')">
                  <p>At least one Committee Chair is required</p>
              </section>
              <section class='errorMessage' v-if="sharedState.hasError('committee_members_attributes')">
                  <p>At least one Committee Member is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Degree'">
              <degree></degree>
              <section class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Research Field'">
              <researchField></researchField>
              <section role="alert" class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Embargo'">
              <embargo></embargo>
            </div>
            <div v-else-if="input.label === 'Partnering Agency'">
              <partneringAgency></partneringAgency>
            </div>
            <div v-else-if="input.label === 'Keyword'">
              <keywords></keywords>
              <section role="alert" class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Copyright & Patents'">
              <copyrightQuestions></copyrightQuestions>
            </div>
            <div v-else-if="input.label === 'Language'">
              <language></language>
              <section role="alert" class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
            <div v-else-if="input.label === 'Submit'">
              <div v-if="allowTabSave()">
                <submit></submit>
              </div>
              <div v-if="!allowTabSave()">
                <userAgreement></userAgreement>
              </div>
            </div>
            <div v-else>
              <label :for="input.label">{{ input.label }}</label>
              <input :id="input.label" class="form-control" :ref="index" :name="sharedState.etdPrefix(index)" v-model="input.value" v-on:change="sharedState.setValid(value.label, false)">
              <section role="alert" class='errorMessage' v-if="sharedState.hasError(index)">
                  <p>{{ input.label }} is required</p>
              </section>
            </div>
          </div>

          <div v-for="(value, key) in value.fields" v-bind:key="key">
            <label>{{ key }}</label>
            <span>{{ value }}</span>
          </div>

          <input name="etd[currentTab]" type="hidden" :value="value.label" />
          <input name="etd[currentStep]" type="hidden" :value="value.step" />
          <button v-if="allowTabSave() && !sharedState.tabs.submit.currentStep" type="submit" class="btn btn-default" autofocus>Save and Continue</button>
        </div>
      </div>
    </form>
    </section>
  </div>
</template>

<script>
import _ from "lodash"
import { library } from '@fortawesome/fontawesome-svg-core'
/* 'coffee' is just an example */
import { faCheckCircle } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { dom } from '@fortawesome/fontawesome-svg-core'
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
import SaveAndSubmit from './SaveAndSubmit'
import quillToolbarOptions  from './quillToolbarOptions'
import quillKeyboardBindings from './quillKeyboardBindings'
import PartneringAgency from './PartneringAgency.vue';
import Submit from './Submit'
import UserAgreement from './components/submit/UserAgreement'
import AboutMe from './components/submit/AboutMe'

var token = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute("content")

/* Font Awesome functions; dom.watch() provides the transformations to svg */
library.add(faCheckCircle)
dom.watch()

export default {
  data() {
    return {
      sharedState: formStore,
      tabInputs: [],
      files: [],
      deleteableFiles: [],
      editorOptions: {
        modules: {
        toolbar: quillToolbarOptions(),
        keyboard: {
          bindings: quillKeyboardBindings()
          }
        }
      },
      lastCompletedStep: 0
    }
  },
  components: {
    fontAwesomeIcon: FontAwesomeIcon,
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
    keywords: Keywords,
    saveAndSubmit: SaveAndSubmit,
    partneringAgency: PartneringAgency,
    submit: Submit,
    userAgreement: UserAgreement
  },
  created () {
    // this executes only the first time the page is loaded (before adding it to the dom), so we need the freshest saved data we have, and we use it to set the state of the tabs.
    this.sharedState.loadSavedData()
    this.sharedState.loadTabs()
    this.sharedState.loadDepartments()
    // load schools?
  },
  beforeMount () {
    // this is loaded every time the form changes (whenever the component changes and before the native DOM is updated)
    this.sharedState.loadSavedData()
    this.sharedState.token = token
  },
  methods: {
  // If student is editing an ETD that has already been persisted to fedora,
  // don't allow student to save record on individual tabs.  This is because
  // we want to save to the Etd, not the InProgressEtd.
  allowTabSave () {
    if (this.sharedState.etdId) {
      return false
    } else {
      return true
    }
  },
    isComplete (tab) {
      return tab;
    },
    allTabsComplete (){
      var complete = [];
      for (var tab in this.sharedState.tabs){
        complete.push(this.sharedState.tabs[tab].completed)
      }
      return complete.every(this.isComplete);
    },
    setCurrentStep (tab_label, event) {
      // display current tab unless click comes from disabled tab
      if (!event.target.classList.contains("disabled")){
        for (var tab in this.sharedState.tabs){
          if (this.sharedState.tabs[tab].label == tab_label){
            this.sharedState.tabs[tab].currentStep = true
          } else {
            this.sharedState.tabs[tab].currentStep = false
          }
        }
      }
    },
    saveTab (){
      var saveAndSubmit = new SaveAndSubmit({
        token: token,
        formData: this.sharedState.formData
      })
      saveAndSubmit.saveTab()
    },
    readyForReview (){
      // all tabs are complete but user has not checked agreement
      return this.allTabsComplete() && this.sharedState.agreement == false
    },
    reviewTabs (){
      var saveAndSubmit = new SaveAndSubmit({
        token: token,
        formData: this.sharedState.formData
      })
      saveAndSubmit.reviewTabs()
    },
    readyForSubmission (){
      return this.allTabsComplete() && this.sharedState.agreement == true
    },
    submitForPublication (){
      var saveAndSubmit = new SaveAndSubmit({
        token: token,
        formData: this.sharedState.formData
      })
      saveAndSubmit.submitEtd()
    },
    onSubmit (event) {
      this.sharedState.setFormData(event.target)
      this.sharedState.loadSavedData(event.target)
      if (this.readyForReview()){
        console.log('ready for review')
        this.reviewTabs()
      } else if (this.readyForSubmission()){
        console.log('ready for submission')
        this.submitForPublication()
      } else {
        this.saveTab()
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
  min-width: 100px;
  text-align: center;
}
ul li button {
  display: block;
  line-height: 1.3em;
  font-family: 'PT Sans', sans-serif;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-bottom: 0;
  box-shadow: 1px 1px 0.5px rgba(0, 0, 0, 0.06);
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
  padding: 1em;
  margin-right: 0.5em;
  min-width: 115px;
  background: white;
}

ul li button:hover {
  background: #cdcdcd
}

.check-circle {
  color: steelblue;
  margin-right: .2em;
  margin-left: .2em;
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
  margin-bottom: 0.4em;
}
.tab-content > button {
  margin-bottom: 1.5em;
}

input {
  margin-bottom: 1em;
}
.quill-hidden-field {
  display: none;
}
.quill-editor {
  height: 10em;
  margin-bottom: 7em;
}

.errorMessage {
  color: red;
}
</style>
