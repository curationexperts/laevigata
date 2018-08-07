export default class BoxFilePickerMode {
  constructor () {
    if (window.localStorage) {
      this.mode = localStorage.getItem('boxMode')
    }
  }

  setMode (value) {
    if (window.localStorage) {
      if (value === 'supplemental' || value === 'primary') {
        localStorage.setItem('boxMode', value)
        this.mode = value
      }
    }
  }
}
