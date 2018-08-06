import axios from 'axios'
import _ from 'lodash'
import SaveAndSubmit from './SaveAndSubmit'
import MemberList from './lib/MemberList'
import ChairList from './lib/ChairList'
import KeywordList from './lib/KeywordList'
import PartneringAgencyList from './lib/PartneringAgencyList'

// Configuration imports
import copyrightQuestions from './config/copyrightQuestions.json'
import subfieldEndpoints from './config/subfieldEndpoints.json'
import embargoContents from './config/embargoContents.json'
import embargoLengths from './config/embargoLengths.json'
import schools from './config/schools.json'
import helpText from './config/helpText.json'
export var formStore = {
  tabs: {
    about_me: {
      label: 'About Me',
      help_text: helpText.aboutMe,
      disabled: false,
      valid: '',
      completed: false,
      currentStep: true,
      step: 0,
      inputs: {
        creator: { label: 'Student Name', value: [] },
        school: { label: 'School', value: [] },
        graduation_date: { label: 'Graduation Date', value: [] },
        post_graduation_email: { label: 'Post-Graduation Email', value: [] }
      }
    },
    my_program: {
      label: 'My Program',
      help_text: helpText.myProgram,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 1,
      inputs: {
        department: { label: 'Department', value: [] },
        partnering_agency: { label: 'Partnering Agency', value: [] },
        subfield: { label: 'subfield', value: [] },
        degree: { label: 'Degree', value: [] },
        submitting_type: { label: 'Submitting Type', value: [] }
      }
    },
    my_advisor: {
      label: 'My Advisor',
      help_text: helpText.myAdvisor,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 2,
      inputs: {
        committee_member: { label: 'Committee Member', value: [] }

      }
    },
    my_etd: {
      label: 'My Etd',
      help_text: helpText.myEtd,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 3,
      inputs: {
        title: { label: 'Title', value: [] },
        language: { label: 'Language', value: [] },
        abstract: { label: 'Abstract', value: '' },
        table_of_contents: { label: 'Table of Contents', value: '' }
      }
    },
    keywords: {
      label: 'Keywords',
      help_text: helpText.keywords,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 4,
      inputs: {
        research_field: { label: 'Research Field', value: [] },
        keyword: { label: 'Keyword', value: [] },
        copyrights: { label: 'Copyright & Patents' }
      }
    },
    my_files: {
      label: 'My Files',
      help_text: helpText.myFiles,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 5,
      inputs: {
        files: { label: 'files', value: [] }
      }
    },
    embargo: {
      label: 'Embargo',
      help_text: helpText.embargo,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 6,
      inputs: {
        embargo: { label: 'Embargo', value: [] }
      }
    },
    submit: {
      label: 'Submit',
      help_text: helpText.submit,
      disabled: true,
      valid: '',
      completed: false,
      currentStep: false,
      step: 7,
      inputs: {
        submit: { label: 'Submit', value: [] }
      }
    }
  },
  token: undefined,
  // The ID of the InProgressEtd record that we are editing (relational database ID).
  // This will help us build the URL for the form submit.
  ipeId: '',
  setIpeId (id) {
    this.ipeId = id
  },
  // The fedora ID of the Etd record that this InProgressEtd represents.
  etdId: '',
  setEtdId (fedoraId) {
    this.etdId = fedoraId
  },
  // If student is editing an ETD that has already been persisted to fedora,
  // don't allow student to save record on individual tabs.  This is because
  // we want to save to the Etd, not the InProgressEtd.
  // TODO: This method is duplicated in App.vue.  Do we need it in both places?
  allowTabSave () {
    if (this.etdId) {
      return false
    } else {
      return true
    }
  },
  getUpdateRoute () {
    if (this.etdId) {
      return `/concern/etds/${this.etdId}`
    } else {
      return `/in_progress_etds/${this.ipeId}`
    }
  },
  copyrightQuestions: copyrightQuestions,
  committeeChairs: new ChairList(),
  committeeMembers: new MemberList(),
  agreement: false,
  submitted: false,
  files: [],
  supplementalFiles: [],
  departments: [],
  selectedDepartment: '',
  selectedSubfield: '',
  subfields: [],
  keywords: new KeywordList(),
  partneringAgencies: new PartneringAgencyList(),
  partneringAgencyChoices: {},
  errors: [],
  errored: false,
  languages: [{ 'value': '', 'active': true, 'label': 'Select a Language', 'disabled': 'disabled', 'selected': 'selected' }],
  languagesEndpoint: '/authorities/terms/local/languages_list',
  subfieldEndpoints: subfieldEndpoints,
  schools: schools,
  embargoContents: embargoContents,
  embargoLengths: embargoLengths,
  isValid (tab) {
    return this.tabs[`${tab}`].valid
  },
  setValid (tab, validity, otherTabs) {
    _.forEach(this.tabs, (t) => {
      // passing in the object or the label is ok
      if (t === tab || t.label === tab) {
        t.valid = validity
      }
    })
    // this is for the case where a change in an input renders other tabs invalid. those inputs call this function with an array of tab labels that should be marked invalid now.
    if (otherTabs) {
      _.forEach(otherTabs, (othertab) => {
        this.setValid(othertab, false)
      })
    }
  },
  getSchoolText (schoolKey) {
    var school = _.find(this.schools.options, (school) => { return school.value === schoolKey })
    return school.text
  },
  getNextStep () {
    return parseInt(this.savedData['currentStep']) + 1
  },
  loadTabs () {
    // first time form has ever been loaded, start at the beginning
    if (this.savedData['currentStep'] === undefined) {
      this.tabs.about_me.currentStep = true
      this.tabs.about_me.valid = true
    } else {
      // we want to display the next tab the student has not completed, which will be the tab's step index in the saved currentStep property, plus 1.
      for (var tab in this.tabs) {
        if (this.tabs[tab].step === this.getNextStep()) {
          this.tabs[tab].currentStep = true
          this.tabs[tab].valid = true
        } else {
          this.tabs[tab].currentStep = false
        }
        if (this.tabs[tab].step <= this.getNextStep()) {
          this.tabs[tab].disabled = false
          this.tabs[tab].valid = true
        } else {
          this.tabs[tab].disabled = true
          this.tabs[tab].valid = false
        }
      }
    }
  },
  setComplete (tabName) {
    for (var tab in this.tabs) {
      if (this.tabs[tab].label === tabName) {
        this.tabs[tab].complete = true
      }
    }
  },
  // tabs that have been validated and the current tab are enabled
  enableTabs () {
    for (var tab in this.tabs) {
      if (this.tabs[tab].complete === true || this.tabs[tab].currentStep === true) {
        this.tabs[tab].disabled = false
      } else {
        this.tabs[tab].disabled = true
      }
    }
  },
  // nextStepIsCurrent (lastCompletedStep) {
  //   for (var tab in this.tabs) {
  //     if (this.tabs[tab].step === parseInt(lastCompletedStep) + 1) {
  //       this.tabs[tab].currentStep = true
  //     } else {
  //       this.tabs[tab].currentStep = false
  //     }
  //   }
  // },
  hasError (inputKey) {
    var hasError = false
    _.forEach(this.errors, function (error) {
      _.forEach(error, function (value, key) {
        if (inputKey === key) {
          hasError = true
        }
      })
    })
    return hasError
  },
  etdPrefix (index) {
    return 'etd[' + index + ']'
  },

  addCommitteeMember (affiliation, name) {
    this.committeeChairs.push({ affiliation: [affiliation], name: name })
  },

  /* Getters & Setters */

  /* Schools, Departments & Subfields */
  // our 'messy state' flag
  // from here, you should be able to save the new school selection
  // but your program and embargo tabs are now invalid. you can navigate to the program tab, but maybe you get an error message next to departments (and embargoes) and it tells you to save your school.
  savedAndSelectedSchoolsMatch () {
    return this.schools.selected === this.savedData['school']
  },

  getSelectedSchool () {
    return this.schools.selected
  },

  getSavedOrSelectedSchool () {
    if (this.selectedSchool === undefined) {
      this.selectedSchool = ''
    }
    return this.selectedSchool.length === 0
      ? this.savedData['school'] : this.schools.selected
  },
  getSavedSchool () {
    return this.savedData['school']
  },
  setSelectedSchool (school) {
    this.schools.selected = school
  },
  getSelectedDepartment () {
    return this.selectedDepartment
  },
  getSavedOrSelectedDepartment () {
    return this.selectedDepartment.length === 0 ? this.savedData['department'] : this.selectedDepartment
  },
  getSavedDepartment () {
    return this.savedData['department']
  },
  setSelectedDepartment (department) {
    this.selectedDepartment = department
  },
  clearDepartment () {
    this.selectedDepartment = ''
    this.savedData['department'] = ''
  },
  getDepartments (selectedSchool) {
    axios.get(selectedSchool).then(response => {
      this.departments = response.data
    })
  },
  loadDepartments () {
    if (this.savedData['department'] !== undefined) {
      var schoolEndpoint = '/authorities/terms/local/' + this.savedData['school'] + '_programs'
      this.getDepartments(schoolEndpoint)
    }
  },
  getSelectedSubfield () {
    if (this.selectedSubfield === undefined) {
      this.selectedSubfield = ''
    }
    return this.selectedSubfield.length === 0 ? this.savedData['subfield'] : this.selectedSubfield
  },
  setSelectedSubfield (subfield) {
    this.selectedSubfield = subfield
  },
  getSubfields () {
    if (this.subfieldEndpoints[this.selectedDepartment]) {
      axios.get().then((response) => {
        this.subfields = response.data
      })
    }
  },
  clearSubfields () {
    this.subfields = []
  },

  /* End of Schools, Departments & Subfields */

  getFiles () {
    var filesInfo = _.map(this.files, function (f) {
      var file = {}
      file['name'] = `${f[0].name}`
      file['id'] = `${f[0].id}`
      return file
    })
    return filesInfo
  },

  getGraduationDate () {
    return this.savedData['graduation_date']
  },
  getSavedDegree () {
    return this.savedData['degree']
  },
  getSavedLanguage () {
    return this.savedData['language']
  },
  getSubmittingType () {
    return this.savedData['submitting_type']
  },
  getSavedResearchFields () {
    return this.savedData['research_field'] === undefined ? ['', '', ''] : this.savedData['research_field']
  },
  getSavedResearchField (index) {
    if (this.savedData['research_field'] !== undefined) {
      return this.savedData['research_field'][index] === undefined ? '' : this.savedData['research_field'][index]
    }
  },
  getEmbargoLengths () {
    return this.embargoLengths[this.schools.selected]
  },
  getEmbargoContents () {
    return this.embargoContents
  },
  setUserAgreement () {
    this.agreement = !this.agreement
  },
  getUserAgreement () {
    return this.agreement
  },
  getPartneringChoices () {
    axios.get('/authorities/terms/local/partnering_agencies')
      .then((response) => {
        this.partneringAgencyChoices = response.data
      }).catch((err) => {
        console.log(err)
      })
  },
  /* end Getters & Setters */

  savedData: {},
  formData: undefined,
  setFormData (formElement) {
    var formData = new FormData(formElement)
    // these needs to be whatever is current
    formData.append(this.etdPrefix('school'), this.getSelectedSchool())
    formData.append(this.etdPrefix('department'), this.getSelectedDepartment())

    formData.append(this.etdPrefix('files[]'), this.getFiles())

    this.formData = formData
  },
  loadSavedData () {
    var el = document.getElementById('saved_data')
    if (el && el.hasAttribute('data-in-progress-etd')) {
      this.savedData = JSON.parse(el.dataset.inProgressEtd)
    }
    if (Object.keys(this.savedData).length > 0) {
      this.setIpeId(this.savedData['ipe_id'])
      this.setEtdId(this.savedData['etd_id'])
      for (var tab in this.tabs) {
        var inputKeys = Object.keys(this.tabs[tab].inputs)
        inputKeys.forEach(function (el) {
          this.tabs[tab].inputs[el].value = this.savedData[el]
        }, this)
      }
    }
  },
  showSavedData (data) {
    this.tabs.submit.fields = JSON.parse(data['in_progress_etd'])
  },
  submit () {
    var saveAndSubmit = new SaveAndSubmit({
      token: this.token,
      formData: this.formData
    })
    if (this.allowTabSave()) {
      saveAndSubmit.submitEtd()
    } else {
      this.submitted = true
      saveAndSubmit.updateEtd()
    }
  }
}
