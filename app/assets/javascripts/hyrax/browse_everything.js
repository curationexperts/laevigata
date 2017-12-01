//= require browse_everything

// Show the files in the queue

Blacklight.onLoad( function() {
  $('#browse-btn').browseEverything()
  .done(function(data) {
    var evt = { isDefaultPrevented: function() { return false; } };
    // append inputs that will help us on the back end - finding the files we have uploaded with be, to remove their corresponding hidden inputs when we delete themselves, and storing our be-uploaded primary pdf's filename under an input that can only be created by be's primary uploader.
    $('#supplemental_files').append("<input type='hidden' id='be_primary_pcdm' name='be_pcdm_use_primary' value='"+data[0]['file_name']+"' />");
    $('#supplemental_files').append("<input type='hidden' name='sf_ids' value='"+data[0]['id']+"' />");
    var files = $.map(data, function(d) { return { name: d.file_name, size: d.file_size, id: d.url } });

    $.blueimp.fileupload.prototype.options.done.call($('#fileupload').fileupload(), evt, { result: { files: files }});
  })

  $('#supplemental-browse-btn').browseEverything()
  .done(function(data) {
    var evt = { isDefaultPrevented: function() { return false; } };
    // append inputs that will help us on the back end - finding the files we have uploaded with be, to remove their corresponding hidden inputs when we delete themselves
    $('#supplemental_files').append("<input type='hidden' name='sf_ids' value='"+data[0]['id']+"' />");
    var files = $.map(data, function(d) { return { name: d.file_name, size: d.file_size, id: d.url, pcdm_use: 'supplemental' } });
    $.blueimp.fileupload.prototype.options.done.call($('#supplemental_fileupload').fileupload(), evt, { result: { files: files }});

    var seen = {};
    var dup = false;
    $('#supplemental_files tbody.files tr').each(function() {
        var txt = $(this).find('p.name').text();
        if (seen[txt]){
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
