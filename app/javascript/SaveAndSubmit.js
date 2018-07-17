import axios from "axios"

export default class SaveAndSubmit {
  constructor (options) {
    this.token = options.token
    this.formStore = options.formStore
    this.navigator = options.navigator
    this.app = options.app
  }

  deleteFile () {
    var xhr = new XMLHttpRequest()
    xhr.open('DELETE', this.deleteUrl, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.send(null)
    const filteredFiles = this.formStore.files.filter(
      file => file[0].deleteUrl !== this.deleteUrl
    )
    this.formStore.files = filteredFiles
  }
  submitTab(){
    axios
      .post("/in_progress_etds", this.getFormData(), {
        config: { headers: { "Content-Type": "multipart/form-data" } }
      })
      .then(response => {
        this.errored = false
        this.errors = []
    //    this.navigator.nextStepIsCurrent(response.data.lastCompletedStep)
      //  this.navigator.setComplete(response.data.tab_name)
      //  this.navigator.enableTabs()
      })
      .catch(error => {
        this.formStore.errored = true
        this.formStore.errors = []
        this.formStore.errors.push(error.response.data.errors)
      })
  }
}
