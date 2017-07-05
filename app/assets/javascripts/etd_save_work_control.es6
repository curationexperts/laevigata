import { ETDRequiredFields } from './required_fields'
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
    preventSaveAboutMeUnlessValid() {
      $("#about_me_and_my_program").on('click', (evt) => {
        if (!this.isValid())
          evt.preventDefault();
      })
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
      //make one of these for each tab, passing in tab id, all fields are required
      this.requiredAboutMeFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-me"), ".about-me")
      //trial
      this.requiredAboutMyETDFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-my-etd"), ".about-my-etd")
      this.uploads = new UploadedFiles(this.form, () => this.formStateChanged())
      //This needs to be adjusted
      this.saveButton = this.element.find('#about_me_and_my_program')
      this.depositAgreement = new DepositAgreement(this.form, () => this.formStateChanged())
      this.requiredMeAndMyProgram = new ChecklistItem(this.element.find('#required-about-me'))
      this.requiredMyETD = new ChecklistItem(this.element.find('#required-my-etd'))
      this.requiredMetadata = new ChecklistItem(this.element.find('#required-metadata'))
      this.requiredFiles = new ChecklistItem(this.element.find('#required-files'))
      new VisibilityComponent(this.element.find('.visibility'), this.adminSetWidget)
      this.preventSubmit()
      this.formChanged()
      this.removePartialDataParamUponSubmit()
    }

    removePartialDataParamUponSubmit(){
      this.form.on('submit', (evt) =>
        $('#partial_data').remove())
    }

    preventSubmit() {
      this.preventSaveAboutMeUnlessValid()
      // this.preventSubmitUnlessValid()
      // this.preventSubmitIfAlreadyInProgress()
      // this.preventSubmitIfUploading()
    }

    // Called when a file has been uploaded, the deposit agreement is clicked or a form field has had text entered.
    //seems like it would be best to have selectors in these so that each tab could use them for themselves.

    // formStateChanged() {
    //   console.log('hey, form state changed');
    //   this.saveButton.prop("disabled", !this.isValid());
    // }

    formStateChanged(selector) {
      switch (selector) {
        case '.about-me':
          this.requiredAboutMeFields.reload(".about-me");
        case '.about-my-etd':
          this.requiredAboutMyETDFields.reload('.about-my-etd')
        default:
          break;
      }
      this.saveButton.prop("disabled", !this.isValid(selector));
    }

    formChanged() {}

    // called when a new field has been added to the form.
    aboutMeFormChanged() {
      this.requiredAboutMeFields.reload(".about-me");
      this.formStateChanged(".about-me");
    }

    isValid(selector) {
      switch (selector) {
        case ".about-my-etd":
          return this.validateMyETD()
        case ".about-me":
          return this.validateMeAndMyProgram()
        default:
          //console.log('nothing is valid');
          break;
      }
    //   return metadataValid && filesValid && agreementValid
    }

    validateMyETD() {
      if (this.requiredAboutMyETDFields.areComplete) {
        this.requiredMyETD.check()
        return true
      }
      this.requiredMyETD.uncheck()
      return false
    }

    validateMeAndMyProgram() {
      // TODO: make sure email format is valid
      // red border around input might suffice for invalid

      // if Rollins is school, partnering agency is required, otherwise not
      if ($('#etd_school').val() != "Rollins School of Public Health"){
        this.requiredAboutMeFields.requiredFields = $(this.requiredAboutMeFields.requiredFields).not("#etd_partnering_agency")
      } else {
        this.requiredAboutMeFields.requiredFields = $(this.requiredAboutMeFields.requiredFields).add($("#etd_partnering_agency"))
      }
      if (this.requiredAboutMeFields.areComplete) {
        this.requiredMeAndMyProgram.check()
        return true
      }
      this.requiredMeAndMyProgram.uncheck()
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
