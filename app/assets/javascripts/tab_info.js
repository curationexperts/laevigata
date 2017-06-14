Blacklight.onLoad(function() {
  $('[data-toggle="tab"]').on("click", function() {
    $('h1').text($(this).data('tab-description'));
  });
  $('.about-me #etd_committee_chair_name').on("change", function(){
    if ($(this).val() == "Emory Faculty"){
      //needs to be pulled, ajax autocomplete faculty list
      //remove affiliation field
      $('#chair-affiliation-elements').remove();
    } else {
      //make affiliation field appear
      $('#chair-affiliation').append(affiliation_elements());
    }
  });

  function affiliation_elements(){
    return '<div id="chair-affiliation-elements"><label class="affiliation" for="affiliation">Chair/Thesis Advisor\'s Affiliation</label><input id="committee_chair_affiliation" class="form-control committee affiliation" name="committee_chair_affiliation" type="text"></div>'
  }
});
