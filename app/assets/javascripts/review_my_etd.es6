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
      // remove table if it's there
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

    let data = $('.about-my-etd :input').serializeArray();

    let permission_data = "Unanswered"

    if ($('#about_my_etd :input#etd_copyright_question_one_true').prop('checked')) {
      permission_data = "Yes, my thesis or dissertation does contain third-party material that would require permission to use"
    } else if ($('#about_my_etd :input#etd_copyright_question_one_false').prop('checked')) {
      permission_data = "No, my thesis or dissertation does not contain third-party material that would require permission to use"
    }

    let copyright_data = "Unanswered"

    if ($('#about_my_etd :input#etd_copyright_question_two_true').prop('checked')) {
      copyright_data = "Yes, my thesis or dissertation does contain content for which I no longer own copyright"
    } else if ($('#about_my_etd :input#etd_copyright_question_two_false').prop('checked')) {
      copyright_data = "No, my thesis or dissertation does not contain content for which I no longer own copyright"
    }

    let patent_data = "Unanswered"

    if ($('#about_my_etd :input#etd_copyright_question_three_true').prop('checked')) {
      patent_data = "Yes, my thesis or dissertation does have content that may be patented"
    } else if ($('#about_my_etd :input#etd_copyright_question_three_false').prop('checked')) {
      patent_data = "No, my thesis or dissertation does not have content that may be patented"
    }

    let permissions = {'name': 'ETD Requires Permission', 'value': permission_data}
    let copyrights = {'name': 'ETD Contains Copyrighted Material', 'value': copyright_data}
    let patents = {'name': 'ETD Might be Eligible for Patent', 'value': patent_data}

    data.push(permissions, copyrights, patents)

    return data
  }

  aboutMyPDFData(){
    let data = [{'name': "My Primary PDF", 'value': $('#fileupload p.name span').text()}]

    return data
  }

  aboutMySupplementalFilesData(){
    let data = ""
      if ($('#supplemental_fileupload tbody tr').length > 0) {
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
    // just the non-committee text inputs
    let no_committee_data = $('#about_me :input').not('.form-control.committee').not('.committee-member-select').not('.committee-chair-select').not(':button').not('[type="hidden"]').not('#no_committee_members').serializeArray();

    let committee_member_rows = $('#about_me div.committee-member.row').not('#member-cloning_row');

    let committee_chair_rows = $('#about_me div.committee-chair.row').not('#chair-cloning_row');

    let committee_member_data = this.getCommitteeRow(committee_member_rows);

    let committee_chair_data = this.getCommitteeRow(committee_chair_rows);

    var partial_data = $.merge(no_committee_data, committee_chair_data);
    if($('#no_committee_members').prop('checked')){
      var data = partial_data
    }else{
      var data = $.merge(partial_data, committee_member_data)
    }
    
    var final_data = this.suppressPartneringAgency(data);
    return final_data;
  }

  suppressPartneringAgency(data){
    let partnering_agency = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i].name === "etd[partnering_agency][]" && data[i].value === ""){
        partnering_agency = i;
      }
    }
    if (partnering_agency > 0){
      data.splice(partnering_agency, 1)
    }
    return data
  }

  name_and_affiliation(member_inputs){
    //serializeArray rejects disabled fields, and we need to find affiliation from fields that might be disabled, so re-enable temporarily
    $(member_inputs).each(function(){
      $(this).prop('disabled', false)
    });

    var members = member_inputs.serializeArray().reverse();
    var member_string;

    member_string = $.map(members, function(m){
        return m.value;
    });

    //find affiliation = Emory and re-disable
    $(member_inputs).each(function(){
      if($(this).val() === "Emory"){
        $(this).prop('disabled', true);
      }
    });

    // if no committee member re-disable fields
    if($('#no_committee_members').prop('checked')){
      $('.committee-member-name').prop('disabled', true);
      $('.committee-member-school').prop('disabled', true);
      $('.committee-member-select').prop('disabled', true);
      $('#add-another-member').prop('disabled', true);

    }

    return member_string.join(', ');
  }

  getCommitteeRow(rows){
    let committee = "";
    let name = "";

    for (var i = 0; i < rows.length; i++){
      var row_inputs = $(rows[i]).find('input').not('select').not('input[name="etd[no_committee_members]"]');
        committee += `${this.name_and_affiliation(row_inputs)}`;
        if (i !== (rows.length - 1)) {
          committee += '<br/>'
        }
    }

    if($(rows).first().hasClass('committee-member')){
      name = 'Committee Members';
    } else {
      name = 'Committee Chair/Thesis Advisor';
    }

    let committee_data = [{'name': name, 'value': committee}]
    return committee_data
  }

  getLabel(el){
    if (el === undefined){
      return
    }
    if (el === "My Primary PDF" || el === "My Supplemental Files" || el.includes('Affiliation') || el.includes('Embargo') || el.includes('Copyrighted') || el.includes('Permission') || el.includes('Patent')){
      return el
    }

    if (el.includes('Committee Chair')){
      return "Committee Chair/Thesis Advisor"
    }

    if (el.includes('Committee Members')){
      return "Committee Members"
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

    let final_label = $('.form-group.'+ label_class +' label').text().replace('required','');
    return final_label
  }

  showUploadedFilesTables(){
    // Primary PDF file
    $(this.pdfTableSelector).append('<tr><th colspan="4">Primary PDF</th></tr>');
    let $pdf = $('#fileupload tbody.files tr');
    $pdf.find('td:last-child').remove();
    $(this.pdfTableSelector).append($pdf);

    // Supplemental files
    $(this.supplementalFilesTableSelector).append('<tr><th colspan="4">Supplemental Files</th></tr>');
    var supp_data = $("#additional_metadata").clone();
    supp_data.collapse('show'); // Make sure its visible
    $(supp_data).find('th').remove();

    // switch the value of the input with the html for each td
    $(supp_data).find('td').each(function(){
      //find input and selects
      var data = "";
      if($(this).find('input').length > 0){
        data = $(this).find('input').val();
      } else if ($(this).find('select').length > 0) {
        // was unable to get selected option value from select so it is stored in a hidden element in the td
        data = $(this).find('input["type=hidden"]').val();
      } else {
        data = $(this).text();
      }
      $(this).html(data);
    });
    $(this.supplementalFilesTableSelector).append(supp_data);

    //no supplemental files at all
    if(supp_data.find('td').length == 0) {
      $(this.supplementalFilesTableSelector).append('<tr><td colspan="4">No Supplemental Files</td></tr>');
    }
  }

  createAllTheRows(){
    let data_me_and_my = $.merge(this.aboutMeData(), this.aboutMyETDData())

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
