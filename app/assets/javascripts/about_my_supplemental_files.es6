export default class AboutMySupplementalFiles {
  constructor() {
    this.attach_metadata_listeners()
    this.uniqueSupplementalFiles()
  }

  //do this on the created table, before showing it.
  //going to need to fix the duplicate file problem.

  uniqueSupplementalFiles(){
    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
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
    });
  }

  displayMetadata(){
    var form = this
    $('#supplemental_fileupload tbody.files tr').each(function(ind, el){
      //get filename from each row
      form.populateMetadataTable($(el).find('p.name').text(), ind)
    });
  }

  populateMetadataTable(filename, iterator){
    var formatted_filename = filename.replace(/(\r\n|\n|\r)/gm,"");
    var final_filename = formatted_filename.trim();
    //TODO: strip extra whitespace from filename
    //needs to be unique names, same problem as with committee members, dynamic fields need to be uniquely named --- or just serialize into array and add into hidden element's value at submission.
    var row = $('<tr><td>'+ final_filename +'<input name="etd[supplemental_file_metadata]['+iterator+']filename" id="supplemental_file_filename" type="hidden" value="'+final_filename+'"></td><td><input name="etd[supplemental_file_metadata]['+iterator+']title" id="supplemental_file_title" type="text"></td></tr>');
      $('#supplemental_files_metatdata tbody').append(row);
  }

  attach_metadata_listeners(){
    var form = this
      //make this an html element
    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
      $('#supplemental_fileupload tbody.files').append($('#additional_metadata_link').show());
    });

    $('#additional_metadata').on('show.bs.collapse', function(){
      $('#additional_metadata_link').text('Hide Additional Metadata');
      form.displayMetadata()
    });

    $('#additional_metadata').on('hide.bs.collapse', function(){
      $('#additional_metadata_link').text('Show Additional Metadata');
    });
  }
}
