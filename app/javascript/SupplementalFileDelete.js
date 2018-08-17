import FileDelete from './FileDelete'
export default class SupplementalFileDelete extends FileDelete {
  deleteFile (key) {

    var xhr = new XMLHttpRequest()
    xhr.open('DELETE', this.deleteUrl, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.send(null)

    const filteredFiles = this.formStore.supplementalFiles.filter(
      file => file.deleteUrl !== this.deleteUrl
    )

    this.formStore.supplementalFiles = filteredFiles
    this.formStore.supplementalFilesMetadata.splice(key, 1);
    this.formStore.removeSavedSupplementalFile(this.deleteUrl)
    this.formStore.removeSavedSupplementalFileMetadata(key)
  }
}
