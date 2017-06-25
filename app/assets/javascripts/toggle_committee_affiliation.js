Blacklight.onLoad(function() {
  var number_of_selects = 1;
  var SaveEtd = require('etd_save_work_control')
  var etd_save_work_control = new SaveEtd($("#form-progress"), this.adminSetWidget)

  $('.about-me #etd_committee_chair_affiliation_type').on("change", function(){
    if ($(this).val() == "Non-Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $('#etd_committee_chair_affiliation').prop('disabled', false)
    } else {
      $('#etd_committee_chair_affiliation').val("Emory")
      $('#etd_committee_chair_affiliation').prop('disabled', true)
    }
  });

  $('.about-me').on('change', '.committee-member-select', function(){
    if ($(this).val() == "Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $('[data-affiliation="members"]').val("Emory")
      $(this).parent().next('div').find($('input')).prop('disabled', true);
    } else {
      $(this).parent().next('div').find($('input')).prop('disabled', false);
    }
  });

  $('#add-another-member').on('click', function(event){
    number_of_selects += 1;
    var name = "committee_members[name_"+number_of_selects+"][affiliation_type]";
    $(".committee-member.row.hidden").first().find('select').prop('name', name);

    var $removeMember = $(".committee-member.row.hidden").first().find('.remove-member');

    $(".committee-member.row.hidden").first().removeClass('hidden');
      //fire form changed event
      etd_save_work_control.aboutMeFormChanged()
      $removeMember.on('click', function(){
       $(this).parents('.committee-member.row').remove();
      });
    });
});
