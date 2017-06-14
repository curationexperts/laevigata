import { RequiredFields } from 'hyrax/save_work/required_fields'
import { ChecklistItem } from 'hyrax/save_work/checklist_item'
import { UploadedFiles } from 'hyrax/save_work/uploaded_files'
import { DepositAgreement } from 'hyrax/save_work/deposit_agreement'
import VisibilityComponent from 'hyrax/save_work/visibility_component'

import SaveWorkControl from 'hyrax/save_work/save_work_control'
export default class EtdSaveWorkControl extends SaveWorkControl {
    constructor(element, adminSetWidget) {
        super(element, adminSetWidget)
    }
    //  * This seems to occur when focus is on one of the visibility buttons
    //  */
    preventSubmitUnlessValid() {
    //   this.form.on('submit', (evt) => {
    //     if (!this.isValid())
    //       evt.preventDefault();
    //   })
    }
    //
    // /**
    //  * Keep the form from being submitted many times.
    //  *
    //  */
    preventSubmitIfAlreadyInProgress() {
    //   this.form.on('submit', (evt) => {
    //     if (this.isValid())
    //       this.saveButton.prop("disabled", true);
    //   })
    }
    //
    // /**
    //  * Keep the form from being submitted while uploads are running
    //  *
    //  */
     preventSubmitIfUploading() {
    //   this.form.on('submit', (evt) => {
    //     if (this.uploads.inProgress) {
    //       evt.preventDefault()
    //     }
    //   })
    }
    //
    // /**
    //  * Is the form for a new object (vs edit an existing object)
    //  */
    get isNew() {
    //   return this.form.attr('id').startsWith('new')
     }

    //  * Call this when the form has been rendered
    //  */
    activate() {
      if (!this.form) {
        return
      }
      this.requiredFields = new RequiredFields(this.form, () => this.formStateChanged())
      this.uploads = new UploadedFiles(this.form, () => this.formStateChanged())
      this.saveButton = this.element.find(':submit')
      this.depositAgreement = new DepositAgreement(this.form, () => this.formStateChanged())
      this.requiredMetadata = new ChecklistItem(this.element.find('#required-metadata'))
      this.requiredFiles = new ChecklistItem(this.element.find('#required-files'))
      new VisibilityComponent(this.element.find('.visibility'), this.adminSetWidget)
      //this.preventSubmit()
      this.watchMultivaluedFields()
      this.formChanged()
    }

    preventSubmit() {
      // this.preventSubmitUnlessValid()
      // this.preventSubmitIfAlreadyInProgress()
      // this.preventSubmitIfUploading()
    }

    // If someone adds or removes a field on a multivalue input, fire a formChanged event.
    // // If someone adds or removes a field on a multivalue input, fire a formChanged event.
    // watchMultivaluedFields() {
    //     $('.multi_value.form-group', this.form).bind('managed_field:add', () => this.formChanged())
    //     $('.multi_value.form-group', this.form).bind('managed_field:remove', () => this.formChanged())
    // }

    // Called when a file has been uploaded, the deposit agreement is clicked or a form field has had text entered.
    formStateChanged() {
      //this.saveButton.prop("disabled", !this.isValid());
    }

    // called when a new field has been added to the form.
    formChanged() {
      //this.requiredFields.reload();
      //this.formStateChanged();
    }

    isValid() {
    //   avoid short circuit evaluation. The checkboxes should be independent.
    //   let metadataValid = this.validateMetadata()
    //   let filesValid = this.validateFiles()
    //   let agreementValid = this.validateAgreement(filesValid)
    //   return metadataValid && filesValid && agreementValid
    }
// hm so, should each tab have its own validations? i think so, therefor required metadata becomes required-aboutmeandmyprogram
    // // sets the metadata indicator to complete/incomplete
    validateMetadata() {
      if (this.requiredFields.areComplete) {
        this.requiredMetadata.check()
        return true
      }
      this.requiredMetadata.uncheck()
      return false
    }

  // // sets the files indicator to complete/incomplete
  validateFiles() {
  //   if (!this.uploads.hasFileRequirement) {
  //     return true
  //   }
  //   if (!this.isNew || this.uploads.hasFiles) {
  //     this.requiredFiles.check()
  //     return true
  //   }
  //   this.requiredFiles.uncheck()
  //   return false
  }

  validateAgreement(filesValid) {
  //   if (filesValid && this.uploads.hasNewFiles && this.depositAgreement.mustAgreeAgain) {
  //     // Force the user to agree again
  //     this.depositAgreement.setNotAccepted()
  //     return false
  //   }
  //   return this.depositAgreement.isAccepted
  }
}
