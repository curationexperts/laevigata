export default class BoxFileUploader {
  constructor (options) {
    this.boxAccessToken = options.boxAccessToken
    this.event = options.event
    this.crsfToken = options.crsfToken
    this.sharedState = options.formStore
  }

  getUrlFromBox () {
    var xhr = new XMLHttpRequest()
    xhr.open('POST', '/file/box')
    xhr.setRequestHeader('X-CSRF-Token', this.crsfToken)
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
    xhr.setRequestHeader('X-CSRF-Token', this.crsfToken)
    xhr.send(formData)
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        this.sharedState.files.push(
          JSON.parse(xhr.responseText).files
        )
      }
    }
  }
}
