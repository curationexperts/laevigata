export default class FileUploader {
  constructor (options) {
    this.formStore = options.formStore
    this.token = options.token
    this.event = options.event
    this.formData = options.formData
  }

  uploadFile () {
    var files = this.event.target.files || this.event.dataTransfer.files
    if (!files.length) return
    var xhr = new XMLHttpRequest()
    xhr.open('POST', '/uploads/', true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        this.formStore.files.push(
          JSON.parse(xhr.responseText).files
        )
      }
    }
    xhr.send(this.formData)
  }
}
