Blacklight.onLoad(function() {
  $("#about_me_and_my_program").on("click", function(event) {
    append_partial_data_input();
    event.preventDefault();
    $.ajax({
      type: "POST",
      url: "/concern/etds",
      data: $('#new_etd :input').not('#about_me :hidden').serialize(),
      success: function(result) {
        $("#success").append("Successfully saved About: " + result['creator']+", "+ result['title']);
      },
      error: function(error_msg){
        $("#new_etd").append(error_msg);
      },
    });
  });

  // TODO: it works refactor next
  $("#about_my_etd_data").on("click", function(event) {
    append_partial_data_input();
    getAboutMyEtdData();
    event.preventDefault();
    $.ajax({
      type: "POST",
      url: "/concern/etds",
      // need a selector for just about-my-etd

      data: $('#new_etd :input').not('#about_me :hidden').serialize(),
      success: function(result) {
        $("#my-etd-success").append("Successfully saved About My Etd");
      },
      error: function(error_msg){
        $("#new_etd").append(error_msg);
      },
    });
  });


  function getAboutMyEtdData(){
    $('#etd_abstract').val(getTinyContent('etd_abstract'));
    $('#etd_table_of_contents').val(getTinyContent('etd_table_of_contents'));
  }

  function getTinyContent(selector){
    return tinyMCE.get(selector).getContent()
  }

  function append_partial_data_input(){
    if ($('#new_etd').has('#partial_data').length > 0){
      return
    } else {
      $('#new_etd').append('<input name="partial_data" value="true" id="partial_data" type="hidden" />');
    }
  }
});
