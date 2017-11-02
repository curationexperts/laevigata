export default class AboutMySupplementalFiles {
  constructor() {
    this.updateMetadataButtonState()
    this.attachMetadataListeners()
    this.uniqueSupplementalFiles()
  }

  // If there are existing supplemental files, display the button to show/hide the metadata section.
  updateMetadataButtonState(){
    if ($('#supplemental_fileupload tbody.files tr').length === 0){
      console.log('hiding meta button');
      $('#additional_metadata_link').css('display', 'none');
    } else {
      console.log('showing meta button');
      $('#additional_metadata_link').css('display', 'block');
    }
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

  syncMetadataWithFiles(file_rows, metadata_rows){
    console.log('sync meta w files');
    let form = this;
    //files have been added, add correct number of new rows to metadata table, with filename supplied
    for (var i = 0; i < file_rows.length; i++){
      if (i >= metadata_rows.length){
        var filename = $(file_rows[i]).find('p.name').text().trim();
        form.populateMetadataTable(filename, metadata_rows.length + 1)
      }
    }
  }

  displayMetadata(){
    console.log('displayMeta');
    var form = this
    // is there metadata already?
    if($('#supplemental_files_metadata tbody tr').length > 0){
      console.log('meta already exists');
      // have more files been uploaded?
      if( $('#supplemental_fileupload tbody.files tr').length > $('#supplemental_files_metadata tbody tr').length ){
        form.syncMetadataWithFiles($('#supplemental_fileupload tbody.files tr'), $('#supplemental_files_metadata tbody tr'));
      } else if ( $('#supplemental_fileupload tbody.files tr').length === $('#supplemental_files_metadata tbody tr').length){
        // do nothing, metadate table is in sync and will be shown
      }
    } else {
      console.log('meta doesnt exist yet');
      // create new metadata table
      var table_headings = $('<thead><th>File Name</th><th>Title</th><th>Description</th><th>File Type</th></thead>');
      var table_body = $('<tbody></tbody>');

      $('#supplemental_files_metadata').append(table_headings);
      $('#supplemental_files_metadata').append(table_body);
      $('#supplemental_fileupload tbody.files tr').each(function(ind, el){
        //get filename from each row of uploaded files table
        form.populateMetadataTable($(el).find('p.name').text(), ind)
      });
    }
  }

  populateMetadataTable(filename, iterator){
    console.log('populateMetadataTable');
    var formatted_filename = filename.replace(/(\r\n|\n|\r)/gm,"");
    var final_filename = formatted_filename.trim();

    var row = $('<tr></tr>');

    // filename td and hidden input
    var filename_cell = $('<td></td>');
    $(filename_cell).text(final_filename);
    var name_input = $('<input />');
    $(name_input).prop('name', 'etd[supplemental_file_metadata]['+iterator+']filename');
    $(name_input).prop('id', 'etd[supplemental_file_metadata]['+iterator+']filename');
    $(name_input).prop('type', 'hidden');
    $(name_input).val(final_filename);
    $(filename_cell).append(name_input);
    $(row).append(filename_cell);

    // title td and text input
    var title_cell = $('<td></td>');
    var title_input = $('<input />');
    $(title_input).addClass('form-control');
    $(title_input).addClass('optional');
    $(title_input).prop('name', 'etd[supplemental_file_metadata]['+iterator+']title');
    $(title_input).prop('id', 'etd[supplemental_file_metadata]['+iterator+']title');
    $(title_input).prop('type', 'text');
    $(title_cell).append(title_input);
    $(row).append(title_cell);

    // description td and text input
    var description_cell = $('<td></td>');
    var description_input = $('<input />');
    $(description_input).addClass('form-control');
    $(description_input).addClass('optional');
    $(description_input).prop('name', 'etd[supplemental_file_metadata]['+iterator+']description');
    $(description_input).prop('id', 'etd[supplemental_file_metadata]['+iterator+']description');
    $(description_input).prop('type', 'text');

    $(description_cell).append(description_input);
    $(row).append(description_cell);

    // file type td and dropdown: Text, Dataset, Video, Image, Software, Sound
    var file_type_cell = $('<td></td>');
    var file_type_input = $('<select />');
    $(file_type_input).addClass('form-control');
    $(file_type_input).addClass('optional');
    $(file_type_input).prop('name', 'etd[supplemental_file_metadata]['+iterator+']file_type');
    $(file_type_input).prop('id', 'etd[supplemental_file_metadata]['+iterator+']file_type');

    $(file_type_input).append(new Option("",""));
    $(file_type_input).append(new Option("Text","Text"));
    $(file_type_input).append(new Option("Dataset","Dataset"));
    $(file_type_input).append(new Option("Image","Image"));
    $(file_type_input).append(new Option("Video","Video"));
    $(file_type_input).append(new Option("Sound","Sound"));
    $(file_type_input).append(new Option("Software","Software"));

    //this should not be necessary, but can't seem to get selected option value in preview, so creating a hidden element to store it in, which works :/
    var selected_option = $('<input />');
    $(selected_option).prop('type', 'hidden');

    $(file_type_input).on('change', function(){
      $(selected_option).val($(this).val());
    });

    $(file_type_cell).append(file_type_input);
    $(file_type_cell).append(selected_option);
    $(row).append(file_type_cell);

    // append the final row to the table
    $('#supplemental_files_metadata tbody').append(row);
  }

  attachMetadataListeners(){
    var form = this

    $('#supplemental_fileupload').bind('fileuploadfinished', function (e, data) {
      $('#additional_metadata_link').css('display', 'block');
    });

    $('#additional_metadata').on('show.bs.collapse', function(){
      $('#additional_metadata').prop('display', 'block');
      $('#additional_metadata_link').text('Hide Required Metadata');
      form.displayMetadata();
      //disable upload of any more files
      $('#supplemental_files span.fileinput-button').addClass('disabled_element');
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', true);
      $('#supplemental-browse-btn').prop('disabled', true);
    });


    $('#additional_metadata').on('hide.bs.collapse', function(){
      $('#additional_metadata_link').text('Add Required Metadata');

      //re-enable upload of files
      $('#supplemental_files span.fileinput-button').removeClass('disabled_element');
      $('#supplemental_files .fileupload-buttonbar input').prop('disabled', false);
      $('#supplemental-browse-btn').prop('disabled', false);
    });
  }
}
