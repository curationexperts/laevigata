import Axios from 'axios'

export var formStore = {
  tabs: {
    about_me: {
      label: 'About Me',
      help_text: '',
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
      help_text: '',
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
      help_text: '',
      description: '',
      enabled: false,
      selected: false,
      completed: false,
      step: 3,
      inputs: {
        committee_chair: { label: 'Committee Chair', value: [], required: true },
        committee_members: { label: 'Committee Members', value: [], required: true }
      }
    },
    my_etd: {
      label: 'My Etd',
      help_text: '',
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
      help_text: '',
      enabled: false,
      selected: false,
      completed: false,
      step: 5,
      inputs: {
        research_field: { label: 'Research Field', value: [], required: true },
        keywoord: { label: 'Keywork', value: [], required: true },
        copyright_question_one: {
          label: 'Copyright Question One',
          value: false,
          required: true
        },
        copyright_question_two: {
          label: 'Copyright Question Two',
          value: false,
          required: true
        },
        copyright_question_three: {
          label: 'Copright Question Three',
          value: false,
          required: true
        }
      }
    },
    my_files: {
      label: 'My Files',
      help_text: '',
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
      help_text: '',
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
      help_text: '',
      enabled: false,
      selected: false,
      completed: false,
      step: 8
    }
  },
  departments: [],
  getDepartments (selectedSchool) {
    Axios.get(selectedSchool).then(response => {
      this.departments = response.data
    })
  },
  toggleSelected (index) {
    this.tabs[index].selected = !this.tabs[index].selected
  }
}
