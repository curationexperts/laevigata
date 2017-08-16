export default class AboutMeAndMyProgram {

  constructor(){
    this.attach_save_listener()
    this.attach_committee_select_listeners('.committee-chair-select')
    this.attach_committee_select_listeners('.committee-member-select')
    this.attach_add_committee_listeners('chair')
    this.attach_add_committee_listeners('member')
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

  attach_add_committee_listeners(selector){
    var add_selector = `#add-another-${selector}`;
    var row_selector = `.committee-${selector}.row`;
    var remove_selector = `.remove-${selector}`;
    var cloning_row = `#${selector}-cloning_row`;

    $(add_selector).on('click', function(event){

      var current_index = $(`#index-${selector}`).val();
      //get it and increment it and store it
      current_index++

      $(`#index-${selector}`).val(current_index);

      var $new_row = $(cloning_row).clone();

      //change $new_row's id so we don't find it again when looking for blank row to clone

      $new_row.prop('id', `cloned_${selector}_row`);

      var $removeMember = $new_row.find(remove_selector);

      // same 'etd_committee_members_affiliation' class used for both containing divs
      var $affiliation_input = $new_row.find('div.etd_committee_members_affiliation input');
      var $affiliation_type_input = $new_row.find('div.etd_committee_members_affiliation_type select');

      var affiliation_name = $affiliation_input.prop('name');
      var affiliation_type_name = $affiliation_type_input.prop('name');

      var new_affiliation_name = affiliation_name.replace(/\d/, current_index);
      var new_affiliation_type_name = affiliation_type_name.replace(/\d/, current_index);

      // we are adding the index to the element's name, which the back end will use to keep track of each member.
      $affiliation_input.prop('name', new_affiliation_name);
      $affiliation_type_input.prop('name', new_affiliation_type_name);

      var $name_input = $new_row.find('div.member-name input');

      var name_name = $name_input.prop('name');
      var new_name = name_name.replace(/\d/, current_index);

      $name_input.prop('name', new_name)

      $new_row.removeClass('hidden');
      $(`div.about-me.${selector}`).append($new_row);

       $removeMember.on('click', function(){
         // get current_index again and store it in local variable, decrement it and store it
         var current_index = $(`#index-${selector}`).val();
         current_index--

         $(`#index-${selector}`).val(current_index);
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
