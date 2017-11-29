// The workflow actions don't appear on the ETD edit form, so it would cause an error:
// TypeError: $(...).offset(...) is undefined
// I override this file from Hyrax to add a check to make sure those divs exist before trying to operate on them.

Blacklight.onLoad(function() {
  $(document).on('scroll', function() {
    if ($('.workflow-actions').length) {
      var workflowDiv = $('#workflow_controls');
      var workflowDivPos = $('.workflow-actions').offset().top + $('#workflow_controls').height();
      workflowDiv.removeClass('workflow-affix');
      if(workflowDivPos > ($(window).scrollTop() + $(window).height())){
        workflowDiv.addClass('workflow-affix');
      } else {
        workflowDiv.removeClass('workflow-affix');
      }
    }
  });
});
