Blacklight.onLoad(function() {
  $('.about-me #etd_committee_chair_affiliation_type').on("change", function(){
    if ($(this).val() == "Non-Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $('#etd_committee_chair_affiliation').prop('disabled', false)
    } else {
      $('#etd_committee_chair_affiliation').val("Emory")
      $('#etd_committee_chair_affiliation').prop('disabled', true)
    }
  });

  $('.about-me .committee-member-select').on("change", function(){
    if ($(this).val() == "Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      $('[data-affiliation="members"]').val("Emory")
      $('[data-affiliation="members"]').prop('disabled', true);
    } else {
      $('[data-affiliation="members"]').prop('disabled', false);
    }
  });
});
