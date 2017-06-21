import { RequiredFields } from 'hyrax/save_work/required_fields'

export class ETDRequiredFields extends RequiredFields {
  // Monitors the form and runs the callback if any of the required fields change
  // I want to pass in the selector for this so I can make new ones for each tab

  constructor(form, callback, selector) {
    super(form, callback)
    this.form = form
    this.callback = callback
    this.reload(selector)
  }

  get areComplete() {
    return this.requiredFields.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0
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
