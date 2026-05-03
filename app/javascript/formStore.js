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
import {labelFor, showInactive} from "./lib/formHelpers";

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
        post_graduation_email: { label: 'Post-Graduation Email', value: [], placeholder: 'name@example.com', type: 'email', help_text: `<span class="glyphicon glyphicon-info-sign"></span> Please provide a post-graduation email address so that we can communicate with you about embargo information. This email address will be shared with your school in periodic automatic reports. If you do not want your email shared in these reports, please contact <a href="mailto:scholcomm@listserv.cc.emory.edu">scholcomm@listserv.cc.emory.edu</a>.` }
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
      const school = _.find(this.schools.options, (school) => { return school.value === schoolKey })
      return school.text
    }
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
      for (let tab in this.tabs) {
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
    for (let tab in this.tabs) {
      if (this.tabs[tab].label === tabName) {
        this.tabs[tab].complete = true
      }
    }
  },
  hasError (inputKey) {
    let hasError = false
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
    const error = _.find(this.errors, key)
    if (_.isObject(error)) {
      return error
    }
  },

  etdPrefix (index) {
    return 'etd[' + index + ']'
  },

  /* Getters & Setters */

  /* Schools, Departments & Subfields */
  getSelectedSchool () {
    return this.schools.selected ?? ''
  },
  getSavedOrSelectedSchool () {
    if (this.savedData['school']) {
      return this.savedData['school']
    } else {
      return this.getSelectedSchool()
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
      return 'files_restricted'
    }
  },
  getSavedSchool () {
    return this.savedData['school']
  },
  setSelectedSchool (school) {
    this.schools.selected = school

  },

  getDepartment () {
    return this.selectedDepartment || this.savedData['department'] || ''
  },

  setDepartment (department) {
    this.selectedDepartment = department
  },

  loadDepartments () {
    // The deparment list depends on the current school
    const departmentsEndpoint = this.schools[this.getSavedOrSelectedSchool()]
    axios.get(departmentsEndpoint).then(response => {
      this.setupDepartmentOptions(response.data)
    }).catch(e => {
      console.log(e)
    })
  },

  setupDepartmentOptions (authority_data) {
    // Add a placeholder option at the top of the options list
    authority_data.unshift({ "id": "", "label": `Select a ${this.getDepartmentHeading()}`,"active": true, "disabled":"disabled" })

    // If a previously saved option exists, ensure it's active
    // If no match is found, use the placeholder option (i.e. set index to 0)
    this.selectedDepartment = this.getDepartment()
    const selected_index = Math.max(authority_data.findIndex((option) => option.id === this.selectedDepartment),0)
    authority_data[selected_index].active = true

    // Flag inactive department labels
    authority_data.forEach((dept_option) => {
      dept_option.label = labelFor(dept_option.label, dept_option.active)
    })

    // Filter out inactive options when appropriate
    this.departments = showInactive() ? authority_data : authority_data.filter((option) => option.active)
  },

  getDepartmentLabelFromId (id) {
    if(this.departments.length > 0){
      return this.departments.filter((department) => { return department.id === id })[0].label
    }
  },

  getDepartmentHeading () {
    // The nursing school uses "Specialty"
    // All other schools use "Department"
    if ( this.savedData['school'] === 'Nell Hodgson Woodruff School of Nursing') {
      return 'Specialty'
    } else {
      return 'Department'
    }
  },
  getSubfield () {
    return this.selectedSubfield || this.savedData['subfield'] || ''
  },
  setSubfield (subfield) {
    this.selectedSubfield = subfield
  },
  getSubfields () {
    const endpoint = this.subfieldEndpoints[this.getDepartment()]
    if (endpoint) {
      axios.get(endpoint).then((response) => {
        this.subfields = this.filterInactiveSubfields(response.data)
      })
    } else {
      this.subfields = []
    }
  },
  filterInactiveSubfields(optionList) {
    // Add a placeholder option at the top of the options list
    optionList.unshift({ "id": "", "label": "Select a Subfield","active": true, "disabled":"disabled" })

    // Make sure the selected option is active
    const selected = this.getSubfield()
    const selected_index = Math.max(optionList.findIndex((option) => option.id === selected),0)
    optionList[selected_index].active = true

    // Flag inactive department labels
    optionList.forEach((option) => {
      option.label = labelFor(option.label, option.active)
    })

    // Filter out inactive options when appropriate
    if (showInactive()) {
      return optionList
    } else {
      return optionList.filter((option) => option.active)
    }

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
        const file = _.find(this.supplementalFilesMetadata, function (o) { return o.filename === sfm.filename })
        // add only if it isn't there
        if (!(_.isObject(file))) {
          this.supplementalFilesMetadata.push({ filename: sfm.filename, title: sfm.title, description: sfm.description, file_type: sfm.file_type })
        }
      })
    }
  },
  addSupplementalFiles () {
    if (this.savedData['supplemental_files']) {
      const parsedFiles = this.tryParseJSON(this.savedData['supplemental_files'])
      // we have a legit parsed file array of objects
      if (!(_.isError(parsedFiles))) {
        // check for duplicates
        _.forEach(parsedFiles, (psf) => {
          const file = _.find(this.supplementalFiles, function (sf) {
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
      const parsedFiles = this.tryParseJSON(this.savedData['files'])
      // we have a legit parsed file object
      if (!(_.isError(parsedFiles))) {
        // if there's nothing in the files array, just go ahead
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
    const file = this.tryParseJSON(this.savedData['files'])
    if (file['deleteUrl'] === deleteUrl) {
      delete this.savedData.files
    }
  },
  removeSavedSupplementalFile (deleteUrl) {
    const files = this.savedData['supplementalFiles']
    const supplementalFile = _.find(files, (f) => {
      return f.deleteUrl === deleteUrl
    })

    if (_.isObject(supplementalFile)) {
      this.savedData['supplementalFiles'] = _.filter(this.savedData['supplementalFiles'], (f) => {
        return f.deleteUrl !== deleteUrl
      })
    }
  },

  removeSavedSupplementalFileMetadata (id) {
    const metadata = this.savedData['supplementalFilesMetadata']
    const supplementalMetadata = _.find(metadata, (f) => {
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
    const formData = new FormData(formElement)
    this.formData = formData
  },
  loadSavedData () {
    const el = document.getElementById('saved_data')
    if (el && el.hasAttribute('data-in-progress-etd')) {
      this.savedData = JSON.parse(el.dataset.inProgressEtd)
    }
    this.addFileData()
    this.addSupplementalFiles()
    this.addSupplementalFileMetadata()
    if (Object.keys(this.savedData).length > 0) {
      this.setIpeId(this.savedData['ipe_id'])
      this.setEtdId(this.savedData['etd_id'])
      for (let tab in this.tabs) {
        const inputKeys = Object.keys(this.tabs[tab].inputs)
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
    const saveAndSubmit = new SaveAndSubmit({
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
