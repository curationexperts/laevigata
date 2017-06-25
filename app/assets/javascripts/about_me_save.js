Blacklight.onLoad(function() {
  $("#about_me_and_my_program").on("click", function(event) {
    $('#new_etd').append('<input name="about_me" value="true" id="about_me" type="hidden" />');
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
});
