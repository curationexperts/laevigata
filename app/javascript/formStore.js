import axios from 'axios'
import _ from 'lodash'
import SaveAndSubmit from './SaveAndSubmit'
import MemberList from './lib/MemberList'
import ChairList from './lib/ChairList'
import KeywordList from './lib/KeywordList'
import PartneringAgencyList from './lib/PartneringAgencyList'
import BoxFilePickerMode from './lib/BoxFilePickerMode'

// Configuration imports
import copyrightQuestions from './config/copyrightQuestions.json'
import subfieldEndpoints from './config/subfieldEndpoints.json'
import embargoContents from './config/embargoContents.json'
import embargoLengths from './config/embargoLengths.json'
import schools from './config/schools.json'
import helpText from './config/helpText.json'
import PartneringAgency from './lib/PartneringAgency';

export const formStore = {
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
        creator: { label: 'Student Name', value: [], placeholder: 'Last Name, First Name' },
        school: { label: 'School', value: [] },
        graduation_date: { label: 'Graduation Date', value: [] },
        post_graduation_email: { label: 'Post-Graduation Email', value: [], placeholder: 'name@example.com', type: 'email' }
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
      displayName: 'My ETD',
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
  failedSubmission: false,
  allowPrimaryBoxUpload: false,
  showStartOver: false,
  other_copyrights: 'false',
  requires_permissions: 'false',
  patents: 'false',
  copyrightQuestions: copyrightQuestions,
  committeeChairs: new ChairList(),
  committeeMembers: new MemberList(),
  boxFilePickerMode: new BoxFilePickerMode(),
  agreement: false,
  submitted: false,
  selectedEmbargo: 'None - open access immediately',
  selectedEmbargoContents: '',
  files: [],
  supplementalFiles: [],
  supplementalFilesMetadata: [],
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

  getSavedLanguage () {
    return this.savedData['language']
  },
  getSchoolKeyFromName (name) {
    return this.schools.options.filter((option) => { return option.text === name })[0].value
  },
  getSchoolHasChanged () {
    return this.savedData['schoolHasChanged']
  },

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
    if (schoolKey) {
      var school = _.find(this.schools.options, (school) => { return school.value === schoolKey })
      return school.text
    }
  },

  getSchoolValue (schoolKey) {
    var school = _.find(this.schools.options, (school) => { return school.text === schoolKey })

    return school.value
  },

  getNextStep () {
    return parseInt(this.savedData['currentStep']) + 1
  },
  loadTabs () {
    // first time form has ever been loaded, start at the beginning
    if (this.savedData['currentStep'] === undefined) {
      this.tabs.about_me.currentStep = true
    } else {
      // we want to display the next tab the student has not completed, which will be the tab's step index in the saved currentStep property, plus 1.
      for (var tab in this.tabs) {
        if (this.tabs[tab].step <= this.getNextStep()) {
          this.tabs[tab].disabled = false
          this.tabs[tab].valid = true
        } else {
          this.tabs[tab].disabled = true
          this.tabs[tab].valid = false
        }
        // rather than complicate condition above, just adjust my program if it is invalid
        if (this.savedData['schoolHasChanged'] === true) {
          this.tabs.my_program.valid = false
        }

        if (this.tabs[tab].step === this.getNextStep()) {
          this.tabs[tab].currentStep = true
          this.tabs[tab].valid = false
        } else {
          this.tabs[tab].currentStep = false
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

  getErrorMessage(key){
    var error = _.find(this.errors, key)
    if (_.isObject(error)) {
      return error
    }
  },

  etdPrefix (index) {
    return 'etd[' + index + ']'
  },

  addCommitteeMember (affiliation, name) {
    this.committeeChairs.push({ affiliation: [affiliation], name: name })
  },

  /* Getters & Setters */

  /* Schools, Departments & Subfields */
  getSelectedSchool () {
    return this.schools.selected
  },
  getSavedOrSelectedSchool () {
    if (this.enableTabs() && localStorage.getItem('school')) {
      return localStorage.getItem('school')
    }

    if (this.enableTabs() && this.savedData['school']) {
      return  this.savedData['school']
    }

    if (!this.enableTabs()) {
      return this.savedData['school']
    }
  },
  setSelectedEmbargo (embargo) {
    this.selectedEmbargo = embargo
  },
  setSelectedEmbargoContents (contents) {
    this.selectedEmbargoContents = contents
  },
  getSelectedEmbargo () {
    if (this.savedData['embargo_length']) {
      return this.savedData['embargo_length']
    } else {
      return this.selectedEmbargo
    }
  },
  getSelectedEmbargoContents () {
    if (this.selectedEmbargoContents) {
      return this.selectedEmbargoContents
    } else if (this.savedData['embargo_type']) {
      return this.savedData['embargo_type']
    } else {
      return 'files_embargoed'
    }
  },
  getSavedSchool () {
    return this.savedData['school']
  },
  setSelectedSchool (school) {
    this.schools.selected = school
    localStorage.setItem('school', school)
  },
  getSelectedDepartment () {
    return this.selectedDepartment
  },

  getSavedOrSelectedDepartment () {
    var savedDepartment = ""
    if (_.isArray(this.savedData['department'])){
      savedDepartment = this.savedData['department'][0]
    } else {
      savedDepartment = this.savedData['department']
    }
    return this.selectedDepartment.length === 0 ? savedDepartment : this.selectedDepartment
  },

  getSavedDepartment () {
    return this.savedData['department']
  },
  setSelectedDepartment (department) {
    this.selectedDepartment = department
  },

  getDepartments (selectedSchool) {
    if (!this.allowTabSave()) {
      var savedValue = { "value": this.getSavedDepartment()[0], "active": true, "label": this.getSavedDepartment()[0], "selected": "selected" }
      axios.get(selectedSchool).then(response => {
        this.departments = response.data
        if (!this.allowTabSave()) {
          this.departments.unshift(savedValue)
        }
      })
      return savedValue
    } else {
      axios.get(selectedSchool).then(response => {
        this.departments = response.data
        this.departments.unshift({ "value": 1, "active": true, "label": "Select a Department", "disabled":"disabled" ,"selected": "selected"})
      })
    }
  },
  loadDepartments () {
    var schoolEndpoint = this.schools[this.getSavedOrSelectedSchool()]
    this.getDepartments(schoolEndpoint)
  },
  getDepartmentLabelFromId (id) {
    if(this.departments.length > 0){
      return this.departments.filter((department) => { return department.id === id })[0].label
    }
  },
  getSelectedSubfield () {
    if (this.selectedSubfield === undefined) {
      this.selectedSubfield = ''
    }
    return this.selectedSubfield.length === 0 ? this.subfields[this.savedData['subfield']] : this.selectedSubfield
  },
  setSelectedSubfield (subfield) {
    this.selectedSubfield = subfield
  },
  getSubfields () {
    const dept = this.getSavedOrSelectedDepartment()
    const endpoints = this.subfieldEndpoints
    const endpoint = endpoints[dept]
    if (endpoints[dept] || formStore.subfieldsEdit) {
      if (!this.allowTabSave()) {
        axios.get(endpoint).then((response) => {
          this.clearSubfields()
          this.subfields = response.data
          this.subfields.unshift({ 'id': this.savedData['subfield'], 'active': true, 'label': this.savedData['subfield'], 'selected': 'selected' })
        })
        return true
      } else {
        axios.get(endpoint).then((response) => {
          this.clearSubfields()
          this.subfields = response.data
        })
      }
    }
  },
  clearSubfields () {
    this.subfields = []
  },
  getSubfieldLabelFromId (id) {
    if (this.subfields.length > 0){
      return this.subfields.filter((subfield) => { return subfield.id === id })[0].label
    }
  },
  /* End of Schools, Departments & Subfields */

  getPrimaryFile () {
    if (this.files[0] === undefined) return
    return JSON.stringify(this.files[0][0])
  },

  getSupplementalFiles () {
    if (this.supplementalFiles === undefined || this.supplementalFiles.length === 0) return
    return JSON.stringify(this.supplementalFiles)
  },
  getGraduationDate () {
    return this.savedData['graduation_date']
  },
  getSavedDegree () {
    return this.savedData['degree']
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
    return this.embargoLengths[this.getSavedOrSelectedSchool()]
  },
  getEmbargoContents () {
    return this.embargoContents
  },
  getDegreeAwarded () {
    return this.savedData['degree_awarded']
  },
  setUserAgreement () {
    this.agreement = !this.agreement
  },
  getUserAgreement () {
    if (!this.allowTabSave()) {
      return true
    } else {
      return this.agreement
    }
  },
  getPartneringChoices () {
    axios.get('/authorities/terms/local/partnering_agencies')
      .then((response) => {
        this.partneringAgencyChoices = response.data
      })
  },
  preventBoxSupplementalUpload: false,
  disableBoxForSupplementalFiles () {
    this.preventBoxSupplementalUpload = true
  },

  enableBoxForSupplementalFiles () {
    this.preventBoxSupplementalUpload = false
  },

  setSupplementalFileMetadata (key, field, newValue) {
    this.supplementalFilesMetadata[key][field] = newValue
  },

  addSupplementalFileMetadata () {
    if (this.savedData['supplemental_file_metadata']) {
      // check for duplicates
      _.forEach(this.savedData['supplemental_file_metadata'], (sfm) => {
        var file = _.find(this.supplementalFilesMetadata, function (o) { return o.filename === sfm.filename })
        // add only if it isn't there
        if (!(_.isObject(file))) {
          this.supplementalFilesMetadata.push({ filename: sfm.filename, title: sfm.title, description: sfm.description, file_type: sfm.file_type })
        }
      })
    }
  },
  addSupplementalFiles () {
    if (this.savedData['supplemental_files']) {
      var parsedFiles = this.tryParseJSON(this.savedData['supplemental_files'])
      // we have a legit parsed file array of objects
      if (!(_.isError(parsedFiles))) {
        // check for duplicates
        _.forEach(parsedFiles, (psf) => {
          var file = _.find(this.supplementalFiles, function (sf) {
            return sf.deleteUrl === psf.deleteUrl
          })
          // add only if it isn't there
          if (!(_.isObject(file))) {
            this.supplementalFiles.push(psf)
          }
        })
      }
    }
  },
  addFileData () {
    if (_.has(this.savedData, 'files') && this.savedData['files'] !== 'undefined') {
      var parsedFiles = this.tryParseJSON(this.savedData['files'])
      // we have a legit parsed file object
      if (!(_.isError(parsedFiles))) {
        // if there's nothing in the the files array, just go ahead
        if (this.files.length === 0) {
          this.files.push([parsedFiles])
          this.savedData['files'] = [parsedFiles]
        // make sure we don't add a duplicate
        } else {
          _.forEach(this.files[0], (f) => {
            if (f.id !== parsedFiles.id) {
              // TODO:
              // might not be the place to put the data into an array.
              // we might need each parsed object to be an array
              this.files.push([parsedFiles])
              this.savedData['files'] = [parsedFiles]
            }
          })
        }
      }
    }
  },
  tryParseJSON (str) {
    return _.attempt(JSON.parse.bind(null, str))
  },
  removeSavedFile (deleteUrl) {
    // TODO: this assumes files contains only one object, and returns it
    // TODO: rename files primaryFile
    var file = this.tryParseJSON(this.savedData['files'])
    if (file['deleteUrl'] === deleteUrl) {
      delete this.savedData.files
    }
  },
  removeSavedSupplementalFile (deleteUrl) {
    var files = this.savedData['supplementalFiles']
    var supplementalFile = _.find(files, (f) => {
      return f.deleteUrl === deleteUrl
    })

    if (_.isObject(supplementalFile)) {
      var filteredFiles = _.filter(this.savedData['supplementalFiles'], (f) => {
        return f.deleteUrl !== deleteUrl
      })
      this.savedData['supplementalFiles'] = filteredFiles
    }
  },

  removeSavedSupplementalFileMetadata (id) {
    var metadata = this.savedData['supplementalFilesMetadata']
    var supplementalMetadata = _.find(metadata, (f) => {
      return f.id === id
    })
    if (_.isObject(supplementalMetadata)) {
      var filteredFiles = _.filter(this.savedData['supplementalFilesMetadata'], (f) => {
        return f.id !== id
      })
    }
    this.savedData['supplementalFilesMetadata'] = filteredFiles
  },

  savedData: {},
  formData: undefined,
  setFormData (formElement) {
    var formData = new FormData(formElement)
    this.formData = formData
  },
  loadSavedData () {
    var el = document.getElementById('saved_data')
    if (el && el.hasAttribute('data-in-progress-etd')) {
      this.savedData = JSON.parse(el.dataset.inProgressEtd)
    }
    this.addFileData()
    this.addSupplementalFiles()
    this.addSupplementalFileMetadata()
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
      this.submitted = true
      saveAndSubmit.submitEtd()
    } else {
      this.submitted = true
      saveAndSubmit.updateEtd()
    }
  }
}
