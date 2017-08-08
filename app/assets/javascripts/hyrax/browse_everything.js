//= require browse_everything

// Show the files in the queue

Blacklight.onLoad( function() {
  $('#browse-btn').browseEverything()
  .done(function(data) {
    var evt = { isDefaultPrevented: function() { return false; } };
    var files = $.map(data, function(d) { return { name: d.file_name, size: d.file_size, id: d.url } });
    $.blueimp.fileupload.prototype.options.done.call($('#fileupload').fileupload(), evt, { result: { files: files }});
  })

  $('#supplemental-browse-btn').browseEverything()
  .done(function(data) {
    var evt = { isDefaultPrevented: function() { return false; } };
    var files = $.map(data, function(d) { return { name: d.file_name, size: d.file_size, id: d.url } });
    $.blueimp.fileupload.prototype.options.done.call($('#supplemental_fileupload').fileupload(), evt, { result: { files: files }});
    //validate for uniqueSupplementalFiles
    // also show the additional metadata button
    //maybe require the class here, rather than duplicating this code?
    //TODO: comment about where other function is and why

    $('#supplemental_fileupload tbody.files').append($('#additional_metadata_link').show());

    var seen = {};
    var dup = false;
    $('#supplemental_files tbody.files tr').each(function() {
        var txt = $(this).find('p.name').text();
        if (seen[txt]){
          console.log('seen', seen[txt])
          $(this).first().remove();
          dup = true
        } else {
          seen[txt] = true;
        }
    });
    if (dup){
      $("#duplicate-files-error").removeClass('hidden')
    } else {
      $("#duplicate-files-error").addClass('hidden')
    }
  })
});
