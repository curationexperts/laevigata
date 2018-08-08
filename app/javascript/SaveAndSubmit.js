import axios from 'axios'
import { formStore } from './formStore'

export default class SaveAndSubmit {
  constructor (options) {
    this.token = options.token
    this.formData = options.formData
    this.formStore = formStore
  }

  saveTab () {
    // files are special
    this.formData.append("etd[files]", this.formStore.getPrimaryFile())
    this.formData.append("etd[supplemental_files]", this.formStore.getSupplementalFiles())

    // the client sends a param the server uses to track whether an old school matches a new school
    this.formData.append('etd[schoolHasChanged]', this.formStore.savedData['schoolHasChanged'])
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
  reviewTabs () {
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
        console.log('an error', error)
      })
  }
  submitEtd () {
    // we want the latest data from the server loaded into the form only when ready to submit for publication
    this.formStore.loadSavedData()
    // submit as form data
    this.formStore.savedData['school'] = this.formStore.getSchoolText(this.formStore.savedData['school'])

    var uploadedFilesIds = []
    uploadedFilesIds.push(`${this.formStore.files[0][0].id}`)
    _.forEach(this.formStore.supplementalFiles, (sf) => {
      uploadedFilesIds.push(`${sf.id}`)
    })
    axios.defaults.headers.common['X-CSRF-Token'] = this.formStore.token
    var savedDataToSubmit = { 'etd': this.formStore.savedData, 'uploaded_files': uploadedFilesIds }
    axios.post('/concern/etds', savedDataToSubmit)
      .then(response => {
        window.location = response.request.responseURL
      })
      .catch(e => {
        this.errors.push(e)
        console.log('an error', e)
      })
  }
  updateEtd () {
    axios.defaults.headers.common['X-CSRF-Token'] = this.formStore.token
    var form = document.getElementById('vue_form')
    var formData = new FormData(form)

    axios.patch(`/concern/etds/${this.formStore.etdId}`, formData)
      .then(response => {
        window.location = response.data.redirectPath
      })
      .catch(e => {
        // this.errors.push(e)
        console.log('an error', e)
      })
  }
}
