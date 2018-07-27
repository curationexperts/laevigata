import axios from 'axios'
import _ from 'lodash'
import SaveAndSubmit from './SaveAndSubmit'

export var formStore = {
  tabs: {
    about_me: {
      label: 'About Me',
      help_text: `It's time to submit your thesis or dissertation! Let's begin with some basic information.`,
      disabled: false,
      selected: true,
      completed: false,
      currentStep: true,
      step: 0,
      inputs: {
        creator: { label: 'Student Name', value: [], required: true },
        school: { label: 'School', value: [] },
        graduation_date: { label: 'Graduation Date', value: [], required: true },
        post_graduation_email: { label: 'Post-Graduation Email', value: [], required: true }
      }
    },
    my_program: {
      label: 'My Program',
      help_text: 'Tell us a little bit more about the specifics of your program.',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 1,
      inputs: {
        department: { label: 'Department', value: [] },
        partnering_agency: { label: 'Partnering Agency', value: [], required: true },
        subfield: { label: 'subfield', value: [], required: true },
        degree: { label: 'Degree', value: [], required: true },
        submitting_type: { label: 'Submitting Type', value: [], required: true }
      }
    },
    my_advisor: {
      label: 'My Advisor',
      help_text: `Please provide some details about the people who supervised your submission.
      If your committee chair, thesis advisor, or committee members
      are not affiliated with Emory, select 'Non-Emory' and enter their organization.`,
      description: '',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 2,
      inputs: {
        committee_member: { label: 'Committee Member', value: [], required: true }

      }
    },
    my_etd: {
      label: 'My Etd',
      help_text: 'Please describe your primary submission document.',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 3,
      inputs: {
        title: { label: 'Title', value: [], required: true },
        language: { label: 'Language', value: [], required: true },
        abstract: { label: 'Abstract', value: '', required: true, rich_text: true },
        table_of_contents: { label: 'Table of Contents', value: '', required: true, rich_text: true }
      }
    },
    keywords: {
      label: 'Keywords',
      help_text: 'Please provide some additional information about your submission.',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 4,
      inputs: {
        research_field: { label: 'Research Field', value: [], required: true },
        keyword: { label: 'Keyword', value: [], required: true },
        copyrights: { label: 'Copyright & Patents' }
      }
    },
    my_files: {
      label: 'My Files',
      help_text: '',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 5,
      inputs: {
        files: { label: 'files', value: [] }
      }
    },
    embargo: {
      label: 'Embargo',
      help_text: 'You have the option to restrict access to your thesis or dissertation for a limited time. First, select whether you would like to apply an embargo and how long you would like it to apply. Then select which parts of your record to include in the embargo. If you are unsure whether to embargo your ETD, consult with your thesis advisor or committee chair.',
      disabled: true,
      selected: false,
      completed: false,
      currentStep: false,
      step: 6,
      inputs: {
        embargo: { label: 'Embargo', value: [] }
      }
    },
    submit: {
      label: 'Submit',
      help_text: `Please take a moment to review all your answers before submitting your document(s) to your department or school for approval.
       Afer you submit your document(s), your school will be notified and staff will review your submission for acceptance.`,
      disabled: true,
      selected: false,
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
  setEtdId (fedora_id) {
    this.etdId = fedora_id
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
  copyrightQuestions: [{
    'label': 'Fair Use',
    'text': `Does your thesis or dissertation contain any thirdy-party text, audiovisual content or other material which is beyond a fair use and would require permission?`,
    'choice': 'no',
    'name': 'etd[requires_permissions]'
  }, {
    'label': 'Copyright',
    'text': `Does your thesis or dissertation contain content, such as a previously published article, for which you no longer own copyright? If you have quiestions about your use of copyrighted material, contact the Scholarly Communications Office at scholcom@listserv.cc.emory.edu`,
    'choice': 'no',
    'name': 'etd[additional_copyrights]'
  },
  {
    'label': 'Patents',
    'text': `Does your thesis or dissertation disclose or described any inventions or discoveries that could potentially have commerical application and therefore may be patended? If so please contact the Office of Technology Transfer (OTT) at (404) 727-2211.`,
    'choice': 'no',
    'name': 'etd[patents]'
  }],
  partneringAgencies: [],
  committeeChairs: [],
  committeeMembers: [],
  files: [],
  supplementalFiles: [],
  departments: [],
  selectedDepartment: '',
  selectedSubfield: '',
  subfields: [],
  keywords: [],
  errors: [],
  errored: false,
  languages: [{ 'value': '', 'active': true, 'label': 'Select a Language', 'disabled': 'disabled', 'selected': 'selected' }],
  languagesEndpoint: '/authorities/terms/local/languages_list',
  getSavedLanguage () {
    return this.savedData['language']
  },
  subfieldEndpoints: {
    'Biological and Biomedical Sciences': '/authorities/terms/local/biological_programs',
    'Biostatistics': '/authorities/terms/local/biostatistics_programs',
    'Business': '/authorities/terms/local/business_programs',
    'Environmental Sciences': '/authorities/terms/local/environmental_programs',
    'Epidemiology': '/authorities/terms/local/epidemiology_programs',
    'Psychology': '/authorities/terms/local/psychology_programs',
    'Executive Masters of Public Health - MPH': '/authorities/terms/local/executive_programs'
  },
  schools: {
    candler:
      '/authorities/terms/local/candler_programs',
    emory: '/authorities/terms/local/emory_programs',
    laney: '/authorities/terms/local/laney_programs',
    rollins:
      '/authorities/terms/local/rollins_programs',
    selected: '',
    options: [
      { text: 'Select a School', value: '', disabled: 'disabled', selected: 'selected' },
      { text: 'Candler School of Theology', value: 'candler' },
      { text: 'Emory College', value: 'emory' },
      { text: 'Laney Graduate School', value: 'laney' },
      { text: 'Rollins School of Public Health', value: 'rollins' }
    ]
  },
  embargoContents: [{ text: 'Files',
    value: 'files_embargoed',
    disabled: false
  },
  { text: 'Files and Table of Contents',
    value: 'files_embargoed, toc_embargoed',
    disabled: false
  },
  { text: 'Files and Table of Contents and Abstract',
    value: 'files_embargoed, toc_embargoed, abstract_embargoed',
    disabled: false
  }],
  embargoLengths: {
    emory: [{value: 'None - open access immediately', selected: 'selected'},
      {value: '6 Months'}, {value: '1 Year'}, {value: '2 Years'}],
    candler: [{value: 'None - open access immediately', selected: 'selected'},
      {value: '6 Months'}, {value: '1 Year'}, {value: '2 Years'}],
    laney: [{value: 'None - open access immediately', selected: 'selected'}, {value: '6 Months'},
      {value: '1 Year'}, {value: '2 Years'}, {value: '6 Years'}],
    rollins: [{value: 'None - open access immediately', selected: 'selected'},
      {value: '6 Months'}, {value: '1 Year'}, {value: '2 Years'}]
  },
  getSchoolText (schoolKey) {
    var school = _.find(this.schools.options, (school) => { return school.value === schoolKey })
    return school.text
  },
  keywordIndex: 0,
  newKeyword: '',
  addKeyword (keyword) {
    this.keywords.unshift({ index: this.keywords.length, value: keyword })
  },
  removeKeyword (index) {
    this.keywords.splice(this.keywords.indexOf(index, 1))
  },
  // will be in the etd data soon
  agreement: false,
  addSavedKeywords (savedKeywords) {
    if (savedKeywords !== undefined) {
    this.keywords = savedKeywords
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
  nextStepIsCurrent (lastCompletedStep) {
    for (var tab in this.tabs) {
      if (this.tabs[tab].step === parseInt(lastCompletedStep) + 1) {
        this.tabs[tab].currentStep = true
      } else {
        this.tabs[tab].currentStep = false
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
  getSchoolOptionValue () {
    return this.savedData['school']
  },
  setSelectedSchool (school) {
    this.schools.selected = school
  },

  getSelectedDepartment () {
    return this.selectedDepartment.length === 0 ? this.savedData['department'] : this.selectedDepartment
  },

  getSavedDepartment () {
    return this.savedData['department']
  },

  setSelectedDepartment (department) {
    this.selectedDepartment = department
  },
  clearDepartment(){
    this.selectedDepartment = ''
    this.savedData['department'] = ''
  },
  getDepartments (selectedSchool) {
    axios.get(selectedSchool).then(response => {
      this.departments = response.data
    })
  },
  getSelectedSubfield(){
    return this.selectedSubfield.length === 0 ? this.savedData['subfield'] : this.selectedSubfield
  },
  setSelectedSubfield (subfield) {
    this.selectedSubfield = subfield
  },
  getSubfields () {
    axios.get(this.subfieldEndpoints[this.selectedDepartment]).then((response) => {
      this.subfields = response.data
    })
  },
  clearSubfields () {
    this.subfields = []
  },

  /* End of Schools, Departments & Subfields */

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
    if (this.savedData['research_field'] !== undefined){
      return this.savedData['research_field'][index] === undefined ? '' : this.savedData['research_field'][index]
    }
  },
  getEmbargoLengths () {
    return this.embargoLengths[this.schools.selected]
  },
  getEmbargoContents () {
    return this.embargoContents
  },
  getPartneringAgenciesOptionValue () {
    return this.savedData['partnering_agency']
  },
  getPartneringAgencies () {
    axios.get('/authorities/terms/local/partnering_agencies').then((response) => {
      this.partneringAgencies = response.data
    })
  },
  setUserAgreement () {
    this.agreement = !this.agreement
  },
  getUserAgreement () {
    return this.agreement
  },

  /* end Getters & Setters */

  savedData: {},
  formData: undefined,
  setFormData (formElement) {
    var formData = new FormData(formElement)
    formData.append(this.etdPrefix('school'), this.getSelectedSchool())
    formData.append(this.etdPrefix('department'), this.getSelectedDepartment())
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
            // components load after this function runs, so need to use their mounted and nextTick lifecycle hooks to get data.
            if (el === 'keyword' && this.savedData[el] !== undefined){
              this.addSavedKeywords(this.savedData[el])
            }
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
      saveAndSubmit.updateEtd()
    }
  }
}
