export default class FileDelete {
  constructor (options) {
    this.deleteUrl = options.deleteUrl
    this.token = options.token
    this.formStore = options.formStore
  }

  deleteFile () {
    var xhr = new XMLHttpRequest()
    xhr.open('DELETE', this.deleteUrl, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.send(null)
    const filteredFiles = this.formStore.files.filter(
      file => file[0].deleteUrl !== this.deleteUrl
    )
    this.formStore.files = filteredFiles
    this.formStore.removeSavedFile(this.deleteUrl)
    localStorage.removeItem('files')
  }
}
