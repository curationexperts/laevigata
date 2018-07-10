import Axios from 'axios'

export var formStore = {
  tabs: {
    about_me: {
      label: 'About Me',
      help_text: `It's time to submit your thesis or dissertation! Let's begin with some basic information.`,
      enabled: true,
      selected: true,
      completed: false,
      step: 1,
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
      enabled: false,
      selected: false,
      completed: false,
      step: 2,
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
      enabled: false,
      selected: false,
      completed: false,
      step: 3,
      inputs: {
        committee_member: { label: 'Committee Member', value: [], required: true }

      }
    },
    my_etd: {
      label: 'My Etd',
      help_text: 'Please describe your primary submission document.',
      enabled: false,
      selected: false,
      completed: false,
      step: 4,
      inputs: {
        title: { label: 'Title', value: [], required: true },
        language: { label: 'Language', value: [], required: true },
        abstract: { label: 'Abstract', value: [], required: true, rich_text: true },
        table_of_contents: { label: 'Table of Contents', value: [], required: true, rich_text: true }
      }
    },
    keywords: {
      label: 'Keywords',
      help_text: 'Please provide some additional information about your submission.',
      enabled: false,
      selected: false,
      completed: false,
      step: 5,
      inputs: {
        research_field: { label: 'Research Field', value: [], required: true },
        keyword: { label: 'Keyword', value: [], required: true },
        copyrights: { label: 'Copyright & Patents' }
      }
    },
    my_files: {
      label: 'My Files',
      help_text: `Upload the version of your thesis or dissertation approved by your advisor or committee. 
      You can only upload one file. This file should not contain any signatures or other personally identifying 
      information. PDF/A is a better version for preservation and for that reason we recommend you upload a PDF/A file, but it is not required. 
      For help converting your manuscript to PDF/A, please contact Student Digital Life`,
      enabled: false,
      selected: false,
      completed: false,
      step: 6,
      inputs: {
        files: { label: 'files', value: [] }
      }
    },
    embargo: {
      label: 'Embargo',
      help_text: 'You have the option to restrict access to your thesis or dissertation for a limited time. First, select whether you would like to apply an embargo and how long you would like it to apply. Then select which parts of your record to include in the embargo. If you are unsure whether to embargo your ETD, consult with your thesis advisor or committee chair.',
      enabled: false,
      selected: false,
      completed: false,
      step: 7,
      inputs: {
        embargo_length: { label: 'embargo_length', value: [], required: true },
        files_embargoed: { label: 'files_embargoed', value: [], required: true },
        abstract_embargoed: { label: 'abstract_embargoed', value: [], required: true },
        toc_embargoed: { label: 'toc_embargoed', value: [], required: true }
      }
    },
    submit: {
      label: 'Submit',
      help_text: `Please take a moment to review all your answers before submitting your document(s) to your department or school for approval.
       Afer you submit your document(s), your school will be notified and staff will review your submission for acceptance.`,
      enabled: false,
      selected: false,
      completed: false,
      step: 8
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
  committeeChairs: [],
  deletablePrimaryFiles: [],
  departments: [],
  selectedDepartment: '',
  subfields: [],
  languages: [{ 'value': '', 'active': true, 'label': 'Select a Language', 'disabled': 'disabled', 'selected': 'selected' }],
  languagesEndpoint: '/authorities/terms/local/languages_list',
  subfieldEndpoints: {
    'Biological and Biomedical Sciences': '/authorities/terms/local/biological_programs',
    'Biostatistics': '/authorities/terms/local/biostatistics_programs',
    'Business': '/authorities/terms/local/business_programs',
    'Environmental Sciences': '/authorities/terms/local/environmental_programs',
    'Epidemiology': '/authorities/terms/local/epidemiology_programs',
    'Psychology': '/authorities/terms/local/psychology_programs',
    'Executive Masters of Public Health - MPH': '/authorities/terms/local/executive_programs'
  },
  clearSubfields () {
    this.subfields = []
  },
  addCommitteeMember (affilation, name) {
    this.committeeChairs.push({ affilation: affilation, name: name })
  },
  setSelectedDepartment (department) {
    this.selectedDepartment = department
  },
  getSelectedDepartment () {
    return this.selectedDepartment
  },
  getDepartments (selectedSchool) {
    Axios.get(selectedSchool).then(response => {
      this.departments = response.data
    })
  },
  getSubfields () {
    Axios.get(this.subfieldEndpoints[this.selectedDepartment]).then(response => {
      this.subfields = response.data
    })
  },
  toggleSelected (index) {
    this.tabs[index].selected = !this.tabs[index].selected
  }
}
