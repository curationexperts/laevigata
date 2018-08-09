import FileUploader from './FileUploader'
import { isSafari11 } from './lib/isSafari11'
export default class SupplementalFileUploader extends FileUploader {
  uploadFile () {
    if (isSafari11()) {
      this.formData.delete('primary_files[]')
    }
    var files = this.event.target.files || this.event.dataTransfer.files
    if (!files.length) return
    var xhr = new XMLHttpRequest()
    xhr.open('POST', '/uploads/', true)
    xhr.setRequestHeader('X-CSRF-Token', this.token)
    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        console.log(xhr.responseText)
        this.formStore.supplementalFiles.push(
          JSON.parse(xhr.responseText).files[0]
        )
      }
    }
    xhr.send(this.formData)
  }
}
