Blacklight.onLoad(function() {
  var SaveEtd = require('etd_save_work_control')
  var etd_save_work_control = new SaveEtd($("#form-progress"), this.adminSetWidget)

  $('.about-me .committee-chair-select').on("change", function(){
    if ($(this).val() == "Non-Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $(this).parent().next('div').find($('input')).prop('disabled', false);
    } else {
      $(this).parent().next('div').find($('input')).val("Emory")
      $(this).parent().next('div').find($('input')).prop('disabled', true);
    }
  });

  $('.about-me').on('change', '.committee-member-select', function(){
    if ($(this).val() == "Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $(this).parent().next('div').find($('input')).val("Emory")
      $(this).parent().next('div').find($('input')).prop('disabled', true);
    } else {
      $(this).parent().next('div').find($('input')).prop('disabled', false);
    }
  });

  $('#add-another-member').on('click', function(event){
    var $removeMember = $(".committee-member.row.hidden").first().find('.remove-member');

    $(".committee-member.row.hidden").first().removeClass('hidden');
      //fire form changed event
      etd_save_work_control.aboutMeFormChanged()
      $removeMember.on('click', function(){
       $(this).parents('.committee-member.row').remove();
      });
    });

    $('#add-another-chair').on('click', function(event){
      var $removeMember = $(".committee-chair.row.hidden").first().find('.remove-chair');

      $(".committee-chair.row.hidden").first().removeClass('hidden');
        //fire form changed event
        etd_save_work_control.aboutMeFormChanged()
        $removeMember.on('click', function(){
         $(this).parents('.committee-chair.row').remove();
        });
      });

});
