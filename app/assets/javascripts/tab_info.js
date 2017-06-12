Blacklight.onLoad(function() {
  $('[data-toggle="tab"]').on("click", function() {
    $('h1').text($(this).data('tab-description'));
  });
});
