Blacklight.onLoad(function() {

function validateEmail(email) {
  var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

$('#etd_post_graduation_email').keyup(function () {
    var $email = this.value;
    var email = $("#email").val();
    if (validateEmail($email)) {
      $("#etd_post_graduation_email").removeClass('red_input');
    } else {
      $("#etd_post_graduation_email").addClass('red_input');
    }
});

});
