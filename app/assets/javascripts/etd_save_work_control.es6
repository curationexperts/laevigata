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
      this.requiredReview = new ChecklistItem(this.element.find('#required-review'))

      // this is not at all ideal, but because this class is instanted in several places, it's not easy to append and remove one option, so we just remove and append the whole set
      this.nonLaneyEmbargoDurations = '<option value=""></option><option value="6 months">6 months</option><option value="1 year">1 year</option><option value="2 years">2 years</option>';

      this.laneyEmbargoDurations = '<option value=""></option><option value="6 months">6 months</option><option value="1 year">1 year</option><option value="2 years">2 years</option><option value="6 years">6 years</option>';

      this.preventSubmit()
      this.formChanged()
      this.fileDeleted()
      this.supplementalFilesListener()
      this.setEmbargoLengths()
      this.setEmbargoContentListener()
      this.setAgreementListener()
      this.getTinyContent()
      this.addSupplementalFilesMetadata()
    }

    getTinyContent(){
      this.form.on('submit', (evt) => {
        $('#etd_abstract').val(this.getTinyContent('etd_abstract'))
        $('#etd_table_of_contents').val(this.getTinyContent('etd_table_of_contents'))
      });
    }

    setAgreementListener(){
      var form = this
      $('#agreement').on('change', function(){
        if ($(this).prop('checked')){
          form.requiredReview.check()
        } else {
          form.requiredReview.uncheck()
        }
      })
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

    //this empty function overrides the super function, we track when the form has changed more explicitly, per form tab, in this class
    formChanged() {}

    // pdf and supplemental files functions

    fileDeleted(){
      let form = this
      $('#fileupload').bind('fileuploaddestroyed', function (e, data) {
        form.validatePDF()
      })
      $('#supplemental_fileupload').bind('fileuploaddestroyed', function (e, data) {
        form.validateSupplementalFiles()
      })
    }

    // this is not a check of the file type, but given that the app writes the filename to the page, and a student would have to change their Primary PDF file's type while uploading in order to foil this, I feel this is sufficient.

    isAPdf(){
      if( $('#fileupload p.name span').text().includes('.pdf')){
        $("#pdf-format-error").addClass('hidden')
        return true
      } else {
        $("#pdf-format-error").removeClass('hidden')
        $('#fileupload tbody.files').empty()
        return false
      }
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

    addSupplementalFilesMetadata(){
      //is this called by both local and cloud? this is a local event handler

      // better to just have our own, watches for files in the uploaded table, submits to uploads controller?
      $('#supplemental_fileupload').bind('fileuploaddone', function (e, data) {
        $('#additional_metadata_link').show();
        //show metadata fields -- ajax post to uploads controller with them?
        //
        // $.ajax({
        //   type: "POST",
        //   url: "/uploads",
        //   data: "a string"
        // });
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
        if ($(this).prop('checked')){
          form.disableEmbargoes();
          form.requiredEmbargoes.check();
        } else {
          form.requiredEmbargoes.uncheck();
          form.enableEmbargoes();
        }
      });

      $('#embargo_type').on('change', function(e){
        form.setEmbargoContent(this);
      });
      $('#my_embargoes select').on('change', function(e){
        form.formStateChanged('#my_embargoes');
      });
    }

    attachNonLaneyEmbargoDurations(){
      $('#etd_embargo_length').empty();
      $('#etd_embargo_length').html(this.nonLaneyEmbargoDurations)
    }

    attachLaneyEmbargoDurations(){
      $('#etd_embargo_length').empty();
      $('#etd_embargo_length').html(this.laneyEmbargoDurations)
    }

    setEmbargoLengths(){
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
      if (this.requiredEmbargoFields.areComplete) {
        this.requiredEmbargoes.check();
        return true
      } else {
        this.requiredEmbargoes.uncheck();
        return false
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
    if (this.primary_pdf_upload.hasFiles && this.onlyOnePdfAllowed() && this.isAPdf()) {
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
}
