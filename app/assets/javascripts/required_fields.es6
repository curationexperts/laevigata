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

      return validFields && laevigata_data.etd_abstract.length > 0 && laevigata_data.etd_table_of_contents.length > 0
    } else {
      return this.requiredFields.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0
    }
  }

  /* We need to call this reload method any time we have changed the required fields on the form, for example when we add/remove a field or enable/disable a field. */
  reload(selector, subfields_enabled) {
    // All inputs are required, except inputs that are
    // hidden, disabled, or optional.
    // ":input" matches all input, select or textarea
    // fields, but we want to exclude buttons.

    // if selector == ".about-me", add department, which is disabled when this function is called by the change of school that enables it; in the situation where a specific value for department means a subdepartment is required, handle that case as well.

    this.requiredFields = $(selector).find(":input")
     .filter(":not([type=hidden])")
     .filter(":not([disabled])")
     .filter(":not([class~=optional])")
     .filter(":not(button)")

    if (selector === '.about-me'){
      this.requiredFields = $(this.requiredFields).add($("#etd_department"));
    }

    if (subfields_enabled != undefined){
      this.requiredFields = $(this.requiredFields).add($("#etd_subfield"));
    }

    this.requiredFields.change(this.callback)
  }
}
