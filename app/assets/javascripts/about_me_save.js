Blacklight.onLoad(function() {
  $("#about_me_and_my_program").on("click", function(event) {
    event.preventDefault();
    $.ajax({
      type: "POST",
      url: "/concern/etds",
      data: $('#new_etd').serialize(),
      success: function(result) {
        $("#success").append("Successfully saved About: " + result['creator']);
      },
      error: function(error_msg){
        $("#new_etd").append(error_msg);
      },
    });
  });
});
