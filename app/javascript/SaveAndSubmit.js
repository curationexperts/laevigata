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
      .post("/in_progress_etds", this.formData, {
        config: { headers: { "Content-Type": "multipart/form-data" } }
      })
      .then(response => {
        this.formStore.errored = false
        this.formStore.errors = []
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
    //TODO: will this always be 1? confirm
    axios.get('/in_progress_etds/7', { config: { headers: { "Content-Type": "application/json" } } })
    .then(response => {
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
    // TODO: use real in_progress_etds/id: 1? confirm
    axios.get('/in_progress_etds/7', { config: { headers: { "Content-Type": "application/json" } } })
    .then(response => {
      document.getElementById('saved_data').dataset.in_progress_etd = response.data
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
