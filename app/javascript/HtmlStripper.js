export default class HtmlStripper {
  constructor (options) {
    this.html = options.html
  }

  strippedHtml () {
    const doc = new DOMParser().parseFromString(this.html, 'text/html')
    return doc.body.textContent || ''
  }
}
