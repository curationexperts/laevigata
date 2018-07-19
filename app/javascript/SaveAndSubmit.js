import axios from "axios"
import { formStore } from './formStore'

export default class SaveAndSubmit {
  constructor (options) {
    this.token = options.token
    this.formData = options.formData
    this.formStore = formStore
  }
  saveTab(){
    axios
      .patch(this.formStore.getUpdateRoute(), this.formData, {
        config: { headers: { "Content-Type": "multipart/form-data" } }
      })
      .then(response => {
        this.formStore.errored = false
        this.formStore.errors = []
        // get saved data for populating tabs.
        document.getElementById('saved_data').dataset.inProgressEtd = response.data.in_progress_etd

        // populate form in order to use its inputs
        this.formStore.loadSavedData()

        this.formStore.nextStepIsCurrent(response.data.lastCompletedStep)
        this.formStore.setComplete(response.data.tab_name)
        this.formStore.enableTabs()
      })
      .catch(error => {
        this.formStore.errored = true
        this.formStore.errors = []
        this.formStore.errors.push(error.response.data.errors)
      })
  }
  reviewTabs(){
    axios.get(this.formStore.getUpdateRoute(), { config: { headers: { "Content-Type": "application/json" } } })
    .then(response => {
      //TODO: confirm this is correct: response.data.in_progress_etd
      this.formStore.showSavedData(response.data)
      // for now fake that user got here naturally
      this.formStore.nextStepIsCurrent(6)
      this.formStore.setComplete('embargo')
      this.formStore.enableTabs()
    })
    .catch(error => {
      console.log('an error', error)
    })
  }
  submitEtd(){
    // TODO: change text of submit button to say submit for publication
    axios.get(this.formStore.getUpdateRoute(), { config: { headers: { "Content-Type": "application/json" } } })
    .then(response => {
      //TODO: confirm this is correct: response.data.in_progress_etd
      document.getElementById('saved_data').dataset.inProgressEtd = response.data
      // populate form in order to use its inputs
      this.formStore.loadSavedData()
      // submit as form data
      axios.post('/concern/etds', this.getEtdData()
      )
      .then(response => {
        // TODO: clear out any errors in formStore.errors?
      })
      .catch(e => {
        this.errors.push(e)
        console.log('an error', error)
      })
    })
    .catch(error => {
      console.log('an error', error)
    })
  }
  getEtdData(){
    //TODO: might need to remove other params
    this.formData.delete('etd[currentTab]')
    return this.formData
  }
}
