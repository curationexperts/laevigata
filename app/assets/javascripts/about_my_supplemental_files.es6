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

    var table_headings = $('<thead><th>File Name</th><th>Title</th><th>Description</th><th>File Type</th></thead>');
    var table_body = $('<tbody></tbody>');

    $('#supplemental_files_metadata').append(table_headings);
    $('#supplemental_files_metadata').append(table_body);

    $('#supplemental_fileupload tbody.files tr').each(function(ind, el){
      //get filename from each row
      form.populateMetadataTable($(el).find('p.name').text(), ind)
    });
  }

  populateMetadataTable(filename, iterator){
    var formatted_filename = filename.replace(/(\r\n|\n|\r)/gm,"");
    var final_filename = formatted_filename.trim();
    //needs to be unique names, same problem as with committee members, dynamic fields need to be uniquely named --- or just serialize into array and add into hidden element's value at submission?

    var html = '<tr>';

    // filename td and hidden input
    html += '<td>' + final_filename +'<input name="etd[supplemental_file_metadata]['+iterator+']filename" id="supplemental_file_filename" type="hidden" value="'+final_filename+'"></td>';

    // title td and text input
    html += '<td><input name="etd[supplemental_file_metadata]['+iterator+']title" id="supplemental_file_title" type="text"></td>';

    // description td and text input
    html += '<td><input name="etd[supplemental_file_metadata]['+iterator+']description" id="supplemental_file_description" type="text"></td>';

    // file type td and dropdown: Text, Dataset, Video, Image, Software, Sound
    html += '<td><select name="etd[supplemental_file_metadata]['+iterator+']file_type" id="supplemental_file_file_type"><option id="text">Text</option><option id="dataset">Dataset</option><option id="video">Video</option><option id="image">Image</option><option id="software">Software</option><option id="sound">Sound</option></select></td>';

    //end of row
    html += '</tr>';

    var row = $(html);
    $('#supplemental_files_metadata tbody').append(row);
  }

  attach_metadata_listeners(){
    console.log('hey, hello from attach');
    var form = this
      //make this an html element
    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
      $('#link_goes_here').append($('#additional_metadata_link').show());
    });

    $('#additional_metadata').on('show.bs.collapse', function(){
      $('#additional_metadata_link').text('Hide Additional Metadata');
      form.displayMetadata();
    });

    $('#additional_metadata').on('hide.bs.collapse', function(){
      console.log('hey, hello from hide event');
      $('#additional_metadata_link').text('Show Additional Metadata');
    });

    $('#additional_metadata').on('hidden.bs.collapse', function(){
      //clear table
      $('#supplemental_files_metadata').empty();
    });
  }
}
