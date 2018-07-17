import FileDelete from './FileDelete'
export default class SupplementalFileDelete extends FileDelete {
  deleteFile () {
    console.log(this.deleteUrl)
    var xhr = new XMLHttpRequest()
    xhr.open('DELETE', this.deleteUrl, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.send(null)
    console.log(this.deleteUrl)
    const filteredFiles = this.formStore.supplementalFiles.filter(
      file => file.deleteUrl !== this.deleteUrl
    )
    console.log(filteredFiles)
    this.formStore.supplementalFiles = filteredFiles
  }
}
