export class UploadedFiles {
  // Monitors the form and runs the callback when files are added
  constructor(form, callback, selector, checklist_selector) {
    this.form = form
    this.element = $(selector)
    this.element.bind('fileuploadcompleted', callback)
  }

  get hasFileRequirement() {
    let fileRequirement = this.form.find(checklist_selector)
    return fileRequirement.length > 0
  }

  get inProgress() {
    return this.element.fileupload('active') > 0
  }

  get hasFiles() {
    this.fileField = this.element.find("input[name='uploaded_files[]']")
    return this.fileField.length > 0
  }

  get hasNewFiles() {
    // In a future release hasFiles will include files already on the work plus new files,
    // but hasNewFiles() will include only the files added in this browser window.
    return this.hasFiles
  }
}
