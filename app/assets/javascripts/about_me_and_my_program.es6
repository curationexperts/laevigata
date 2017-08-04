export default class AboutMeAndMyProgram {

  constructor(){
    this.attach_save_listener()
    this.attach_committee_select_listeners('.committee-chair-select')
    this.attach_committee_select_listeners('.committee-member-select')
    this.attach_add_committee_listeners('#add-another-chair', ".committee-chair.row", ".remove-chair")
    this.attach_add_committee_listeners('#add-another-member', ".committee-member.row", ".remove-member")
    this.attach_school_listener()
  }

  // Partnering Agencies are not shown unless the Rollins School is selected (or derived from the student's netId, potentially.)

  attach_school_listener(){
    $('#etd_school').on('change', function(){
      if ($(this).val() === "Rollins School of Public Health"){
        $('#rollins_partnering_agencies').show();
      } else {
        $('#rollins_partnering_agencies').hide();
      }
    });
  }

  attach_committee_select_listeners(selector){
    $('.about-me').on('change', selector, function(){
      if ($(this).val() == "Emory Committee Chair" || $(this).val() == "Emory Committee Member"){
        //needs to be pulled, ajax autocomplete faculty list
        $(this).parent().next('div').find($('input')).val("Emory")
        $(this).parent().next('div').find($('input')).prop('disabled', true);
      } else {
        $(this).parent().next('div').find($('input')).prop('disabled', false);
      }
    });
  }

  attach_add_committee_listeners(add_selector, row_selector, remove_selector){
    let hidden_row = row_selector + ".hidden"

    $(add_selector).on('click', function(event){
      var $removeMember = $(hidden_row).first().find(remove_selector);
      $(hidden_row).first().removeClass('hidden');
        $removeMember.on('click', function(){
         $(this).parents(row_selector).remove();
        });
    });
  }

  serialize_with_partial_data(){
    var data = $('#new_etd #about_me :input').not('#about_me :hidden').serializeArray();
    data.push({name: "partial_data", value: true})
    return data
  }

  attach_save_listener(){
    let form = this
    $("#about_me_and_my_program").on("click", function(event) {
      event.preventDefault();
      $.ajax({
        type: "POST",
        url: "/concern/etds",
        data: form.serialize_with_partial_data(),
        success: function(result) {
          $("#success").append("Successfully saved About: " + result['creator']+", "+ result['title']);
        },
        error: function(error_msg){
          $("#new_etd").append(error_msg);
        },
      });
    });
  }
}
