export default class AboutMyETD {
  constructor(formSelector, saveButtonSelector) {
    this.formSelector = formSelector
    this.saveButtonSelector = saveButtonSelector
    this.attach_save_listener()
  }

  getTinyContent(selector){
    return tinyMCE.get(selector).getContent()
  }

  serialize_with_partial_data(){
    this.getAboutMyEtdData()
    var data = $('#new_etd #about_my_etd :input').serializeArray();
    data.push({name: "partial_data", value: true})
    return data
  }

  getAboutMyEtdData(){
    $('#etd_abstract').val(this.getTinyContent('etd_abstract'))
    $('#etd_table_of_contents').val(this.getTinyContent('etd_table_of_contents'))
  }


  attach_save_listener(){
    var form = this
    $(this.saveButtonSelector).on("click", function(event) {
      $.ajax({
        type: "POST",
        url: "/concern/etds",
        data: form.serialize_with_partial_data(),
        success: function(result) {
          $("#my-etd-success").append("Successfully saved About My Etd")
        },
        error: function(error_msg){
          $("#new_etd").append(error_msg)
        },
      })
    })
  }
}
