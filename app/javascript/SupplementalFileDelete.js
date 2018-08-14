import FileDelete from './FileDelete'
export default class SupplementalFileDelete extends FileDelete {
  deleteFile (key) {
    
    var xhr = new XMLHttpRequest()
    xhr.open('DELETE', this.deleteUrl, true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.send(null)
    
    const filteredFiles = this.formStore.supplementalFiles.filter(
      file => file.deleteUrl !== this.deleteUrl
    )
    const filteredMetadata = this.formStore.supplementalFilesMetadata.filter(
      file => file.id !== this.id
    )
    
    this.formStore.supplementalFiles = filteredFiles
    this.formStore.supplementalFilesMetadata = filteredMetadata
    this.formStore.removeSavedSupplementalFile(this.deleteUrl)
    this.formStore.removeSavedSupplementalFileMetadata(key)
  }
}
