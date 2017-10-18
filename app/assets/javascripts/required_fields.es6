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
    // this selector should get changed to '.copyright'
    // because not all radios should be optional, just the copyright ones
    if (this.selector == ".about-my-etd") {
      var validFields = this.requiredFields.filter((n, elem) => {
        return this.isValuePresent(elem) } ).length === 0

      return validFields && tinyMCE.get('etd_abstract').getContent().length > 0 && tinyMCE.get('etd_table_of_contents').getContent().length > 0
    } else {
      return this.requiredFields.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0
    }
  }

  /* We need to call this reload method any time we have changed the required fields on the form, for example when we add/remove a field or enable/disable a field. */
  reload(selector) {
    // All inputs are required, except inputs that are
    // hidden, disabled, or optional.
    // ":input" matches all input, select or textarea
    // fields, but we want to exclude buttons.
    this.requiredFields = $(selector).find(":input")
      .filter(":not([type=hidden])")
      .filter(":not([disabled])")
      .filter(":not([class~=optional])")
      .filter(":not(button)")

    this.requiredFields.change(this.callback)
  }
}
