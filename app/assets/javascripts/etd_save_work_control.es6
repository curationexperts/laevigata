import { ETDRequiredFields } from './required_fields'
import { ReviewMyETD } from './review_my_etd'
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
    removeHiddenAboutMeElements(){
      this.form.on('submit', (evt) => {
        $("#new_etd").remove("#about_me input:hidden")
      })
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
      //all fields are required
      this.requiredAboutMeFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-me"), ".about-me")

      this.requiredAboutMyETDFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-my-etd"), ".about-my-etd input:not(:radio)")

      this.primary_pdf_upload = new UploadedFiles(this.form, () => this.formStateChanged('#fileupload'), '#fileupload', 'li#required-files')

      this.supplemental_files_upload = new UploadedFiles(this.form, () => this.formStateChanged('#supplemental_fileupload'),'#supplemental_fileupload','li#required-supplemental-files')

      this.requiredEmbargoFields = new ETDRequiredFields(this.form, 'none', '#my_embargoes')

    //This needs to be adjusted
      this.saveButton = this.element.find('#about_me_and_my_program')
      this.depositAgreement = new DepositAgreement(this.form, () => this.formStateChanged())
      this.requiredMeAndMyProgram = new ChecklistItem(this.element.find('#required-about-me'))
      this.requiredMyETD = new ChecklistItem(this.element.find('#required-my-etd'))
      this.requiredMetadata = new ChecklistItem(this.element.find('#required-metadata'))
      this.requiredPDF = new ChecklistItem(this.element.find('#required-files'))
      this.supplementalFiles = new ChecklistItem(this.element.find('#required-supplemental-files'))
      this.requiredEmbargoes = new ChecklistItem(this.element.find('#required-embargoes'))

      // this is not at all ideal, but because this class is instanted in several places, it's not easy to append and remove one option, so we just remove and append the whole set
      this.nonLaneyEmbargoDurations = '<option value=""></option><option value="6 months">6 months</option><option value="1 year">1 year</option><option value="2 years">2 years</option>';

      this.laneyEmbargoDurations = '<option value=""></option><option value="6 months">6 months</option><option value="1 year">1 year</option><option value="2 years">2 years</option><option value="6 years">6 years</option>';

      this.preventSubmit()
      this.formChanged()
      this.fileDeleted()
      this.supplementalFilesListener()
      this.setEmbargoReleaseDates()
      this.setEmbargoContentListener()
    }


    preventSubmit() {
      //this.preventSaveAboutMeUnlessValid()
      // this.preventSubmitUnlessValid()
      // this.preventSubmitIfAlreadyInProgress()
      // this.preventSubmitIfUploading()
    }

    formStateChanged(selector) {
      switch (selector) {
        case '.about-me':
          this.requiredAboutMeFields.reload(".about-me");
        case '.about-my-etd':
          this.requiredAboutMyETDFields.reload('.about-my-etd')
        case '#fileupload':

        case '#supplemental_fileupload':

        case '#my_embargoes':
          this.requiredEmbargoFields.reload('#my_embargoes')

        default:
          break;
      }
      this.saveButton.prop("disabled", !this.isValid(selector));
    }


    formChanged() {}

    // called when a new field has been added to the form.
    // TODO: remove
    aboutMeFormChanged() {
      this.requiredAboutMeFields.reload(".about-me");
      this.formStateChanged(".about-me");
    }

    // pdf and supplemental files functions - might extract to class might use object in here instead

    fileDeleted(){
      let form = this
      $('#fileupload').bind('fileuploaddestroyed', function (e, data) {
        form.validatePDF()
      })
      $('#supplemental_fileupload').bind('fileuploaddestroyed', function (e, data) {
        form.validateSupplementalFiles()
      })
    }

    onlyOnePdfAllowed(){
      if($('#fileupload tbody.files tr').length > 1){
        $("#pdf-max-error").removeClass('hidden')
        $('#fileupload tbody.files').empty()
        return false
      } else {
        $("#pdf-max-error").addClass('hidden')
        return true
      }
    }

    supplementalFilesListener(){
      let form = this
      $('#etd_no_supplemental_files').on('change', function(){
        form.validateSupplementalFiles()
      });
    }

    disableSupplementalUpload(){
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', true)
      $('#supplemental_files tbody.files').empty();
      $('#supplemental_files span.fileinput-button').addClass('disabled_element');
      $('#supplemental-browse-btn').prop('disabled', true)
    }

    enableSupplementalUpload(){
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', false)
      $('#supplemental_files span.fileinput-button').removeClass('disabled_element');
      $('#supplemental-browse-btn').prop('disabled', false)
    }

    isValid(selector) {
      switch (selector) {
        case ".about-my-etd":
          return this.validateMyETD()
        case ".about-me":
          return this.validateMeAndMyProgram()
        case "#fileupload":
          return this.validatePDF()
        case "#supplemental_fileupload":
          return this.validateSupplementalFiles()
        case '#my_embargoes':
          return this.validateMyEmbargo()
        default:
          //console.log('nothing is valid');
          break;
      }
    //   return metadataValid && filesValid && agreementValid
    }

    setEmbargoContent(el){
      if($(el).val() === 'files_embargoed'){
        $('#etd_files_embargoed').val(true);

        //other two are false
        $('#etd_toc_embargoed').val(false);
        $('#etd_abstract_embargoed').val(false)
      } else if ($(el).val() === '[:files_embargoed, :toc_embargoed]'){
        $('#etd_files_embargoed').val(true);
        $('#etd_toc_embargoed').val(true);

        //other one is false
        $('#etd_abstract_embargoed').val(false);
      } else if ($(el).val() === '[:files_embargoed, :toc_embargoed, :abstract_embargoed]') {
        // no one is false
        $('#etd_files_embargoed').val(true);
        $('#etd_toc_embargoed').val(true);
        $('#etd_abstract_embargoed').val(true);
      } else {
        // everyone is false
        $('#etd_files_embargoed').val(false);
        $('#etd_toc_embargoed').val(false);
        $('#etd_abstract_embargoed').val(false);
      }
    }

    setEmbargoContentListener(){
      var form = this
      $("#no_embargoes").on('change', function(e){
        form.validateMyEmbargo();
      });
      $('#embargo_type').on('change', function(e){
        form.setEmbargoContent(this);
      });
      $('#my_embargoes select').on('change', function(e){
        form.formStateChanged('#my_embargoes');
      });
    }

    attachNonLaneyEmbargoDurations(){
      $('#etd_embargo_release_date').empty();
      $('#etd_embargo_release_date').html(this.nonLaneyEmbargoDurations)
    }

    attachLaneyEmbargoDurations(){
      $('#etd_embargo_release_date').empty();
      $('#etd_embargo_release_date').html(this.laneyEmbargoDurations)
    }

    setEmbargoReleaseDates(){
      var form = this;
      $('#embargo_school').on('change', function(){
        if ($(this).val() === 'Undergraduate Honors, Rollins or Candler') {
          form.attachNonLaneyEmbargoDurations();
        } else if ($(this).val() === 'Laney Graduate School') {
          form.attachLaneyEmbargoDurations();
        }
      });
    }

    disableEmbargoes(){
      $('#my_embargoes select').val("")
      $('#my_embargoes select').prop('disabled', true);
    }

    enableEmbargoes(){
      $('#my_embargoes select').prop('disabled', false);
    }

    validateMyEmbargo() {
      if ($('#no_embargoes').prop('checked')){
        this.disableEmbargoes();
        this.requiredEmbargoes.check();
        return true
      } else {

        this.enableEmbargoes();
        if (this.requiredEmbargoFields.areComplete) {
          this.requiredEmbargoes.check();
          return true
        } else {
          this.requiredEmbargoes.uncheck();
          return false
        }
      }
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

  // sets the file indicators to complete/incomplete
  validatePDF() {
    if (this.primary_pdf_upload.hasFiles && this.onlyOnePdfAllowed()) {
      this.requiredPDF.check()
      return true
    }
    this.requiredPDF.uncheck()
    return false
  }

  validateSupplementalFiles() {
    if ($('#etd_no_supplemental_files').prop('checked')){
      this.supplementalFiles.check()
      this.disableSupplementalUpload()
      return true
    } else {
      this.enableSupplementalUpload()
      if (this.supplemental_files_upload.hasFiles) {
        this.supplementalFiles.check()
        return true
      } else {
        this.supplementalFiles.uncheck()
        return false
     }
   }
  }

//one way to validate form
  // validateForm(){
  //   if(this.validateMeAndMyProgram() && this.validateMyETD() && this.validatePDF() && this.validateSupplementalFiles() && this.validateMyEmbargo()){
  //     $(this.previewButtonSelector).prop('disabled', false);
  //   }
  // }

  validateAgreement(filesValid) {
  //   if (filesValid && this.uploads.hasNewFiles && this.depositAgreement.mustAgreeAgain) {
  //     // Force the user to agree again
  //     this.depositAgreement.setNotAccepted()
  //     return false
  //   }
  //   return this.depositAgreement.isAccepted
  }
}
