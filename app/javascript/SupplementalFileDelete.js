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
    const filteredMetadata = this.formStore.supplementalFilesMetadata.filter(
      file => file.id !== this.id
    )
    console.log(filteredFiles)
    this.formStore.supplementalFiles = filteredFiles
    this.formStore.supplementalFilesMetadata = filteredMetadata
    this.formStore.removeSavedSupplementalFile(this.deleteUrl)
    this.formStore.removeSavedSupplementalFileMetadata(this.id)
  }
}
