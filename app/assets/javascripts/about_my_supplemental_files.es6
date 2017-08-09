export default class AboutMySupplementalFiles {
  constructor() {
    this.attachMetadataListeners()
    this.uniqueSupplementalFiles()
  }

  uniqueSupplementalFiles(){
    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
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
    });
  }

  displayMetadata(){
    var form = this

    var table_headings = $('<thead><th>File Name</th><th>Title</th><th>Description</th><th>File Type</th></thead>');
    var table_body = $('<tbody></tbody>');

    $('#supplemental_files_metadata').append(table_headings);
    $('#supplemental_files_metadata').append(table_body);

    $('#supplemental_fileupload tbody.files tr').each(function(ind, el){
      //get filename from each row of uploaded files table
      form.populateMetadataTable($(el).find('p.name').text(), ind)
    });
  }

  populateMetadataTable(filename, iterator){
    var formatted_filename = filename.replace(/(\r\n|\n|\r)/gm,"");
    var final_filename = formatted_filename.trim();

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

  attachMetadataListeners(){
    var form = this

    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
      $('#additional_metadata_link').css('display', 'block');
    });

    $('#additional_metadata').on('show.bs.collapse', function(){
      $('#additional_metadata').prop('display', 'block');
      $('#additional_metadata_link').text('Hide Additional Metadata');
      form.displayMetadata();

      //disable upload of any more files
      $('#supplemental_files span.fileinput-button').addClass('disabled_element');
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', true);
      $('#supplemental-browse-btn').prop('disabled', true);
    });

    $('#additional_metadata').on('hide.bs.collapse', function(){
      $('#additional_metadata_link').text('Show Additional Metadata');

      //re-enable upload of files
      $('#supplemental_files span.fileinput-button').removeClass('disabled_element');
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', false);
      $('#supplemental-browse-btn').prop('disabled', false);
    });

    $('#additional_metadata').on('hidden.bs.collapse', function(){
      //clear table
      $('#supplemental_files_metadata').empty();
    });
  }
}
