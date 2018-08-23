import BoxFileUploader from './BoxFileUploader'

export default class BoxSupplementalFileUploader extends BoxFileUploader {
  getFileFieldName () {
    return 'supplemental_files'
  }
}
