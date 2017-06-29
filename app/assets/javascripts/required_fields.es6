import { RequiredFields } from 'hyrax/save_work/required_fields'

export class ETDRequiredFields extends RequiredFields {
  // Monitors the form and runs the callback if any of the required fields change

  constructor(form, callback, selector) {
    super(form, callback)
    this.form = form
    this.callback = callback
    this.selector = selector
    this.reload(selector)
  }

  get areComplete() {
    if (this.selector == ".about-my-etd") {
      var validFields = this.requiredFields.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0

      return validFields && tinyMCE.get('etd_abstract').getContent().length > 0 && tinyMCE.get('etd_table_of_contents').getContent().length > 0
    } else {
      return this.requiredFields.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0
    }
  }

  isValuePresent(elem) {
    //these things are only a problem if disabled is not set
    return (($(elem).prop('disabled') === false) && ($(elem).val() === null)) || (($(elem).prop('disabled') === false) && ($(elem).val().length < 1))
  }

  // Reassign requiredFields because fields may have been added or removed.
  reload(selector) {
    this.requiredFields = []
    this.requiredFields = $.merge($(selector).find('select').filter(":visible"), $(selector).find('input').filter(":visible"))
    this.requiredFields.change(this.callback)
  }
}
