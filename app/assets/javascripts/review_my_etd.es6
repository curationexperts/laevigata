export default class ReviewMyETD {
  constructor(formSelector, previewButtonSelector) {
    this.formSelector = formSelector
    this.tableSelector = formSelector + " table#metadata"
    this.pdfTableSelector = formSelector + " table#uploaded_pdf"
    this.supplementalFilesTableSelector = formSelector + " table#uploaded_supplemental_files"
    this.previewButtonSelector = previewButtonSelector
    this.attach_preview_listener()
    this.attach_validity_listener()
    this.attach_agreement_listener()
  }

  attach_validity_listener(){
    let form = this
    $('a[href="#review"]').on('click', function(){
      let valid_form = $('li#required-about-me').hasClass('complete') && $('li#required-my-etd').hasClass('complete') &&
      $('li#required-files').hasClass('complete') && $('li#required-supplemental-files').hasClass('complete') && $('li#required-embargoes').hasClass('complete')
      if(valid_form){
      //remove table if it's there
        $(form.previewButtonSelector).prop('disabled', false);
        $(form.previewButtonSelector).removeClass('hidden');
      }
    })
  }

  attach_preview_listener(){
    var form = this
    $(this.previewButtonSelector).on('click', function(){
      form.previewMyEtd()
      $('#submission-agreement').removeClass('hidden')
      $(this).addClass('hidden')
    });
  }

  attach_agreement_listener(){
    var form = this
    $('#agreement').on('change', function(){
      if ($(this).prop('checked')){
        $('#with_files_submit').prop('disabled', false)
      } else {
        $('#with_files_submit').prop('disabled', true)
      }
    });
  }

  aboutMyETDData(){
    $('#etd_abstract').val(tinyMCE.get('etd_abstract').getContent())
    $('#etd_table_of_contents').val(tinyMCE.get('etd_table_of_contents').getContent())

    let data = $('#new_etd .about-my-etd :input').serializeArray();

    let optional_data = $('#new_etd #about_my_etd :input.copyright').serializeArray();

    let optional_values = ""

    if(optional_data.length > 0){
      for (var i = 0; i < optional_data.length; i++){
        optional_values += optional_data[i].value;
      }
    }
    let copyright_data = {'name': 'Copyrights and Patents', 'value': optional_values }
    data.push(copyright_data)
    return data
  }

  getSupplementalFileList(){
    var supplemental_files = $("#new_etd #supplemental_fileupload table").clone();
    $(supplemental_files).find('th').remove();
    $(supplemental_files).find('td').each(function(){
      var data = "";
      // skip the delete button that is in the table
      if($(this).find('button').length > 0){
        data = "";
      } else {
        data = $(this).text();
      }
      $(this).html(data);
    });
    return supplemental_files;
  }

  aboutMyPDFData(){
    let data = [{'name': "My Primary PDF", 'value': $('#new_etd #fileupload p.name span').text()}]
    return data
  }

  aboutMySupplementalFilesData(){
    let data = ""
      if ($('#new_etd #supplemental_fileupload tbody tr').length > 0) {
        data = [{'name': "My Supplemental Files", 'value': this.getFileList()}]
        return data
      }
      return data;
  }

  aboutMyEmbargoData(){
    let data = $.merge($('#my_embargoes #embargo_type'), $('#my_embargoes #etd_embargo_length')).serializeArray()

    let row_data = [{'name': "Embargoed ETD Content", 'value': "No Embargoed Content"}]
    let embargo_type = $('#embargo_type :selected').text()
    if(data.length > 0){
      row_data = [{'name': "Embargoed ETD Content", 'value': embargo_type }, {'name': "Embargo Release Date", 'value': data[1].value}]
    }
    return row_data
  }

  aboutMeData(){
    let no_committee_data = $('#new_etd #about_me :input').not(':input.committee').not('.committee-member-select').not('.committee-chair-select').serializeArray();

    //let committee_member_data = $('#new_etd #about_me .committee-member.row :input.committee').not('select');

    //get committee member data separately
    //also, no to serialize array. just get all the rows' inputs and do it yourself.
    //get committee chair
  //  console.log(raw_committee_data)
    // let these_great_rows = this.getCommitteeMemberRow(committee_member_data)
    // let ready_data = no_committee_data.concat(these_great_rows)
    return no_committee_data
  }

  getCommitteeMemberRow(data){
    let valid_data = $.grep(data, function( a ) {
      return a.value !== "";
    });

    let members = ""
    for (var i = 0; i < valid_data.length; i++){
      if(data[i+1].name !== undefined){

        let str = data[i+1].value
        str += ', '
        str += data[i].value
        members += str
      }
    }
    let member_data = {'name': 'Committee Members', 'value': members}
    return member_data
  }

  getLabel(el){
    if (el === undefined){
      return
    }
    if (el === "My Primary PDF" || el === "My Supplemental Files" || el.includes('Committee') || el.includes('Affiliation') || el.includes('Embargo') || el.includes('Copyrights')){
      return el
    }

    let label_class = null
    if(el.includes('[]')){
      let label_class_0 = el.replace("[]", "")
      let label_class_1 = label_class_0.replace("[", "_")
      label_class = label_class_1.replace("]", "")
    } else {
      let label_class_0 = el.replace("[", "_")
      label_class = label_class_0.replace("]", "")
    }

    return $('.form-group.'+ label_class +' label').text()
  }

  showUploadedFilesTables(){
    $(this.pdfTableSelector).append('<tr><th colspan="4">Primary PDF</th></tr>');

    let $pdf = $('#fileupload tbody.files tr');
    $pdf.find('td:last-child').remove();

    $(this.pdfTableSelector).append($pdf);

    // do we have supplemental files but no metadata?
    if ($('#etd_no_supplemental_files').prop('checked') === false && $('#additional_metadata_link').text() == 'Show Additional Metadata') {
      $(this.supplementalFilesTableSelector).append('<tr><th colspan="4">Supplemental Files</th></tr>');

      $(this.supplementalFilesTableSelector).append(this.getSupplementalFileList());

      //do we have supp metadata?

    } else if ($('#new_etd #additional_metadata tr').length > 0 && $('#additional_metadata_link').text() == 'Hide Additional Metadata') {
      $(this.supplementalFilesTableSelector).append('<tr><th colspan="4">Supplemental Files</th></tr>');
      // switch the value of the input with the html for each td
      var supp_data = $("#additional_metadata").clone();
      $(supp_data).find('th').remove();
      $(supp_data).find('td').each(function(){
        //find input and selects
        var data = "";
        if($(this).find('input').length > 0){
          data = $(this).find('input').val();
        } else if ($(this).find('select').length > 0) {
          // was unable to get selected option value from select so it is stored in a hidden element in the td
          data = $(this).find('input["type=hidden"]').val();
        } else {
          //nothing else
        }
        $(this).html(data);
      });
      $(this.supplementalFilesTableSelector).append(supp_data);
    //no supp files at all
    } else {
      $(this.supplementalFilesTableSelector).append('<tr><td colspan="4">No Supplemental Files</td></tr>');
    }
  }

  createAllTheRows(){
    let data_me_and_my = $.merge(this.aboutMeData(), this.aboutMyETDData())
    //do the pdf and supplemental files separately
    let data = $.merge(data_me_and_my, this.aboutMyEmbargoData())

    for (var i = 0; i < data.length; i++){
      $(this.tableSelector).append('<tr><th>' +  this.getLabel(data[i].name) +'</th><td><ul class="tabular"><li class="attribute">'+  data[i].value +'</li></ul></td></tr>');
    }
    this.showUploadedFilesTables();
  }
  showPreviewInstructions(){
    $('.form-instructions p').remove();
    $('.form-instructions').append('<p>Review the information you entered on previous tabs. To edit, use the tabs above to navigate back to that section and correct your information.</p>')
  }

  previewMyEtd(){
    this.showPreviewInstructions();
    this.createAllTheRows();
  }
}
