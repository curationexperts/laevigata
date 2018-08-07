import { formStore } from '../formStore'
export default class BoxFileUploader {
  constructor (options) {
    this.boxAccessToken = options.boxAccessToken
    this.event = options.event
    this.csrfToken = options.csrfToken
    this.sharedState = options.formStore
  }

  getUrlFromBox () {
    var xhr = new XMLHttpRequest()
    xhr.open('POST', '/file/box')
    xhr.setRequestHeader('X-CSRF-Token', this.csrfToken)
    xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8')
    xhr.send(JSON.stringify({ id: this.event[0].id, token: this.boxAccessToken }))
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        this.postToUploads(JSON.parse(xhr.responseText))
      }
    }
  }

  postToUploads (boxResponse) {
    const formData = new FormData()
    formData.set('primary_files', [this.event[0].name])
    formData.set('filename', [this.event[0].name])
    formData.set('remote_url', boxResponse.location)
    var xhr = new XMLHttpRequest()
    xhr.open('POST', '/uploads')
    xhr.setRequestHeader('X-CSRF-Token', this.csrfToken)
    xhr.send(formData)
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (formStore.boxFilePickerMode.mode === 'primary') {
          this.sharedState.files.push(
            JSON.parse(xhr.responseText).files
          )
        }

        if (formStore.boxFilePickerMode.mode === 'supplemental') {
          this.sharedState.supplementalFiles.push(
            JSON.parse(xhr.responseText).files
          )
        }
      }
    }
  }
}
