import axios from 'axios'
import { formStore } from './formStore'
import { formDataNoBlankFiles } from './lib/formDataNoBlankFiles'
import { isSafari11 } from './lib/isSafari11'

export default class SaveAndSubmit {
  constructor(options) {
    this.token = options.token
    this.formData = options.formData
    this.formStore = formStore
  }

  saveTab() {
    // files are special

    if (this.formStore.getPrimaryFile()) {
      this.formData.append('etd[files]', this.formStore.getPrimaryFile())
    } else {
      if (isSafari11()) {
        this.formData.delete('primary_files[]')
      }
    }

    if (this.formStore.getSupplementalFiles()) {
      this.formData.append('etd[supplemental_files]', this.formStore.getSupplementalFiles())
    } else {
      if (isSafari11()) {
        this.formData.delete('supplemental_files[]')
      }
    }

    axios
      .patch(this.formStore.getUpdateRoute(), this.formData, {
        config: { headers: { 'Content-Type': 'multipart/form-data' } }
      })
      .then(response => {
        this.formStore.errored = false
        this.formStore.errors = []
        // get saved data for populating tabs.
        document.getElementById('saved_data').dataset.inProgressEtd = response.data.in_progress_etd

        // populate form in order to use its inputs
        this.formStore.loadSavedData()
        // upon any successful tab save, this flag becomes true
        this.formStore.enableBoxForSupplementalFiles()

        this.formStore.setValid(response.data.tab_name, true)
        this.formStore.setComplete(response.data.tab_name)
        this.formStore.loadTabs()
      })
      .catch(error => {
        this.formStore.errored = true
        this.formStore.errors = []
        this.formStore.errors.push(error.response.data.errors)
        this.formStore.setValid(response.data.tab_name, false)
      })
  }
  reviewTabs() {
    axios.get(this.formStore.getUpdateRoute(), { config: { headers: { 'Content-Type': 'application/json' } } })
      .then(response => {
        // TODO: confirm this is correct: response.data.in_progress_etd
        this.formStore.showSavedData(response.data)
        // for now fake that user got here naturally
        this.formStore.nextStepIsCurrent(6)
        this.formStore.setComplete('embargo')
        this.formStore.loadTabs()
      })
      .catch(error => {
        console.log(error)
      })
  }
  submitEtd() {
    try {
      // we want the latest data from the server loaded into the form only when ready to submit for publication
      this.formStore.loadSavedData()
      // submit as form data

      var uploadedFilesIds = []
      uploadedFilesIds.push(`${this.formStore.files[0][0].id}`)
      _.forEach(this.formStore.supplementalFiles, (sf) => {
        uploadedFilesIds.push(`${sf.id}`)
      })
      axios.defaults.headers.common['X-CSRF-Token'] = this.formStore.token
      var savedDataToSubmit = { 'etd': this.formStore.savedData, 'uploaded_files': uploadedFilesIds }

      axios.post('/concern/etds', savedDataToSubmit)
        .then(response => {
          localStorage.clear()
          window.location = response.request.responseURL
        })
        .catch(e => {
          this.formStore.submitEtd = true
          this.formStore.failedSubmission = true
          this.errors.push(e)
        })

    } catch (error) {
      this.formStore.failedSubmission = true
      this.formStore.submitEtd = true
    }
  }
  updateEtd() {
    axios.defaults.headers.common['X-CSRF-Token'] = this.formStore.token
    if (isSafari11()) {
      var formData = formDataNoBlankFiles('vue_form')
    } else {
      const formElement = document.getElementById('vue_form')
      formData = new FormData(formElement)
    }

    var xhr = new XMLHttpRequest()
    xhr.open('PATCH', `/concern/etds/${this.formStore.etdId}`, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          localStorage.clear()
          window.location = JSON.parse(xhr.response).redirectPath
        } else {
          formStore.failedSubmission = true
        }
      }
    }
    xhr.send(formData)
  }
}
