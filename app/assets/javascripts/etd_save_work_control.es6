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
        this.supplemental_file_list = [];
    }

    //  * This seems to occur when focus is on one of the visibility buttons
    //  */
    preventSubmitUnlessValid() {
    }

    // /**
    //  * Keep the form from being submitted many times.
    //  *
    //  */
    preventSubmitIfAlreadyInProgress() {
    }

    // /**
    //  * Keep the form from being submitted while uploads are running
    //  *
    //  */
     preventSubmitIfUploading() {
    }

    /* Call this when the form has been rendered */
    activate() {
      if (!this.form) {
        return
      }

      // Required fields
      this.requiredAboutMeFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-me"), ".about-me")
      this.requiredAboutMyETDFields = new ETDRequiredFields(this.form, () => this.formStateChanged(".about-my-etd"), ".about-my-etd")
      this.requiredEmbargoFields = new ETDRequiredFields(this.form, () => this.formStateChanged('#my_embargoes'), '#my_embargoes')

      // File uploads
      this.primary_pdf_upload = new UploadedFiles(this.form, () => this.formStateChanged('#fileupload'), '#fileupload', 'li#required-files')

      this.supplemental_files_upload = new UploadedFiles(this.form, () => this.formStateChanged('#supplemental_fileupload'),'#supplemental_fileupload','li#required-supplemental-files')

      this.depositAgreement = new DepositAgreement(this.form, () => this.formStateChanged())

      // Validation checklist items
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

      this.departments_with_subfields = ['Business', 'Executive Masters of Public Health - MPH', 'Biostatistics and Bioinformatics', 'Biostatistics', 'Biological and Biomedical Sciences', 'Environmental Studies', 'Epidemiology', 'Psychology', 'Religion', 'Religion and Anthropology', 'Religion and Classical Civilization', 'Religion and History', 'Religion and Sociology']


      this.preventSubmit()
      this.fileDeleted()
      this.supplementalFilesListener()
      this.setEmbargoLengths()
      this.setEmbargoContentListener()
      this.setCommitteeMembersContentListener()
      this.setAgreementListener()
      this.setTinyListener()
      this.setPartneringAgencyListener()
      this.setSchoolListener()
      this.setDepartmentListener()
      this.setSubfieldListener()
      this.supplementalMetadataListener()

      // Check if the form is already valid. (e.g. If the user is editing an existing record, the form should be valid immediately.)
      this.updateEmbargoState('#no_embargoes', this);
      this.updateCommitteeMembersState('#no_committee_members', this);
      this.updateReviewState('#agreement', this);
      this.updateTinyMceState()
      this.validateAllTabs()
    }

    updateTinyMceState() {
      laevigata_data.etd_abstract = $('#etd_abstract').text();
      laevigata_data.etd_table_of_contents =  $('#etd_table_of_contents').text();
    }

    validateAllTabs() {
      let form = this;
      form.validateMeAndMyProgram();
      form.validateMyETD();
      form.validatePDF();
      form.validateSupplementalFiles();
      form.validateMyEmbargo();
      form.validateReview();
    }

    // If user edits one of the TinyMCE fields, call formStateChanged for that tab.
    setTinyListener(){
      var form = this
      $(document).bind('laevigata:tinymce:change', null, (e) => form.formStateChanged('.about-my-etd'));
    }
    // dynamically added fields need to explicitly trigger validation
    setPartneringAgencyListener(){
      var form = this
      $('#etd_partnering_agency').on('change', function(){
        // if we should add subfield for validating, do so
        if (form.departments_with_subfields.includes($('#etd_department').val())){
          form.requiredAboutMeFields.reload('.about-me', true)
        } else {
          form.requiredAboutMeFields.reload('.about-me')
        }
        form.formStateChanged('.about-me');
      });
    }

    setSchoolListener(){
      var form = this
      $('#etd_school').on('change', function(){
        $("#etd_subfield").val("").change().prop('disabled', true)
        form.requiredAboutMeFields.reload('.about-me')
      });
    }

    setDepartmentListener(){
      var form = this
      $('#etd_department').on('change', function(){
        // call reload if subfield has content, based upon array of department names that contain subfields
          if (form.departments_with_subfields.includes($(this).val())){
            form.requiredAboutMeFields.reload('.about-me', true)
          } else {
            form.requiredAboutMeFields.reload('.about-me')
          }
      });
    }

    setSubfieldListener(){
      var form = this
      $('#etd_subfield').on('change', function(){
        form.requiredAboutMeFields.reload('.about-me', true)
      });
    }

    setAgreementListener(){
      var form = this
      $('#agreement').on('change', function(){
        form.validateReview();
      })
    }

    formStateChanged(selector) {
      this.isValid(selector);
    }

    //this empty function overrides the super function, we track when the form has changed more explicitly, per form tab, in this class
    formChanged() {}

    // pdf and supplemental files functions

    fileDeleted(){
      let form = this
      let file = ''
      $('#fileupload').bind('fileuploaddestroy', function (e, data) {
        // remove inputs named 'selected_files[]' that will interfere with the back end
        $("input[name='selected_files[]']").remove();
        $("input[name='sf_ids']").each(function(){
          $('div.fields-div').find(`input[name^='${$(this).val()}']`).remove();
        });
        //then remove yourself?
      //  $("input[name='sf_ids']").remove();
      });
      $('#fileupload').bind('fileuploaddestroyed', function (e, data) {
        // if student deletes uploaded primary file, we need to remove this param because the backend uses it to know when a browse-everything file is primary
        $('#be_primary_pcdm').remove();
        form.validatePDF()
      });

      $('#supplemental_fileupload').bind('fileuploaddestroy', function (e, data) {
        file = $(data.context).find('p.name span').text();
      });

      $('#supplemental_fileupload').bind('fileuploaddestroyed', function (e, data) {
        $('#supplemental_files_metadata tr').each(function(){
          if ($(this).find('td').first().text() === file) {
            $(this).remove();
          }
        });
        form.validateSupplementalFiles()
      })
    }

    clearSupplementalMetadataTable(){
      $('#supplemental_files_metadata tbody tr').each(function(){
        $(this).remove();
      });
      $('#additional_metadata').collapse('hide');
    }

    // If the user is editing an existing ETD record that has a previously-uploaded PDF, then that file will be displayed on the page.  This method determines whether or not that file is present.
    hasExistingPDF(){
      return $.find('#primary_file_name').length > 0
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
        form.toggleSupplementalUpload();
        form.validateSupplementalFiles();
      });
    }

    toggleSupplementalUpload(){
      if ($('#etd_no_supplemental_files').prop('checked')){
        this.disableSupplementalUpload()
      } else {
        this.enableSupplementalUpload()
      }
    }

    disableSupplementalUpload(){
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', true)
      $('#supplemental_files tbody.files').empty();
      this.clearSupplementalMetadataTable();
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
          break;
      }
    }

    setEmbargoContent(el){
      if($(el).val() === '[:files_embargoed]'){
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

    updateEmbargoState(no_embargoes_checkbox, form){
      if ($(no_embargoes_checkbox).prop('checked')){
        form.disableEmbargoes();
        form.requiredEmbargoes.check();
      } else {
        form.requiredEmbargoes.uncheck();
        form.enableEmbargoes();
      }
      form.requiredEmbargoFields.reload('#my_embargoes');
    }

    updateReviewState(agreement_checkbox, form){
      if ($(agreement_checkbox).prop('checked')){
        $('#submission-agreement').removeClass('hidden')
        $('#with_files_submit').prop('disabled', false)
      }
    }

    setEmbargoContentListener(){
      var form = this
      $("#no_embargoes").on('change', function(e){
        form.updateEmbargoState(this, form);
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
        if ($(this).val() === 'Undergraduate Honors') {
          form.attachNonLaneyEmbargoDurations();
        } else if ($(this).val() === 'Rollins School of Public Health') {
            form.attachNonLaneyEmbargoDurations();
        } else if ($(this).val() === 'Candler School of Theology') {
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

    validateReview() {
      if ($('#agreement').prop('checked')) {
        this.requiredReview.check()
        return true
      } else {
        this.requiredReview.uncheck()
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
      // if Rollins is school, partnering agency is required, otherwise not
      if ($('#etd_school').val() != "Rollins School of Public Health"){
        this.requiredAboutMeFields.requiredFields = $(this.requiredAboutMeFields.requiredFields).not("#etd_partnering_agency")
      } else {
        this.requiredAboutMeFields.requiredFields = $(this.requiredAboutMeFields.requiredFields).add($("#etd_partnering_agency"))
      }

      // If no committee members is checked then fields not required
      if ($('#no_committee_members').is(':checked')){
        this.requiredAboutMeFields.requiredFields = $(this.requiredAboutMeFields.requiredFields).not(".committee-member-select, .committee-member-name, .committee-member-school")
        $('.cloning').not('.hidden').remove();

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
    if (this.hasExistingPDF()) {
      this.requiredPDF.check()
      return true
    } else if (this.primary_pdf_upload.hasFiles && this.onlyOnePdfAllowed() && this.isAPdf()) {
      this.requiredPDF.check()
      return true
    } else {
      this.requiredPDF.uncheck()
      return false
    }
  }

 supplementalMetadataListener(){
  var form = this

  $("#additional_metadata").on('change', function() {
    form.validateSupplementalFiles();
  });

  $(document).on('laevigata:supp:meta:change', function() {
    form.validateSupplementalFiles();
  });
 }

  // Check if all the metadata fields for supplemental files have values filled in.
  hasSupplementalMetadata(){
    var invalidInputs;
    invalidInputs = $("#additional_metadata :input:visible").map(function() {
      if (this.value === undefined || this.value.length === 0) {
        return 'invalid'
      }
    })
    return invalidInputs.length === 0
  }

  validateSupplementalFiles() {
    if ($('#etd_no_supplemental_files').prop('checked')){
      this.supplementalFiles.check()
      return true
    } else if (!this.isNew && this.hasSupplementalMetadata()) {
      this.supplementalFiles.check()
      return true
    } else if (this.supplemental_files_upload.hasFiles && this.hasSupplementalMetadata()) {
      this.supplementalFiles.check()
      return true
    } else {
      this.supplementalFiles.uncheck()
      return false
    }
  }

  // Making committee members optional

  disableCommitteeMembers(){
      $('.committee-member .etd_committee_members_affiliation_type select').val("")
      $('.committee-member .etd_committee_members_affiliation_type select').prop('disabled', true);
      $('.committee-member .etd_committee_members_affiliation input').val("")
      $('.committee-member .etd_committee_members_affiliation input').prop('disabled', true);
      $('.committee-member .etd_committee_members_name input').val("")
      $('.committee-member .etd_committee_members_name input').prop('disabled', true);
      $('#add-another-member').prop('disabled', true);
  }

  enableCommitteeMembers(){
      $('#add-another-member').prop('disabled', false);
      $('.committee-member .etd_committee_members_name input').prop('disabled', false);
      $('.committee-member .etd_committee_members_affiliation_type select').prop('disabled', false);
      if($('.committee-member .etd_committee_members_affiliation_type select').val() != "Emory Committee Member"){
      $('.committee-member .etd_committee_members_affiliation input').prop('disabled', false);
      }
  }

  updateCommitteeMembersState(no_committee_members_checkbox, form){
      if ($(no_committee_members_checkbox).prop('checked')){
        form.disableCommitteeMembers();
      } else {
        form.enableCommitteeMembers();
      }
      form.requiredAboutMeFields.reload('.about-me');
      form.validateMeAndMyProgram()
  }

  setCommitteeMembersContentListener(){
      var form = this
      $("#no_committee_members").on('change', function(e){
        form.updateCommitteeMembersState(this, form);
      });
  }
}
