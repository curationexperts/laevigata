var laevigata_data = {
  // Store values from TinyMCE fields for form validation.
  etd_abstract: '',
  etd_table_of_contents: ''
};

Hyrax.workEditor = function() {
  var element = $("[data-behavior='work-form']")
  if (element.length > 0) {
      var Editor = require('hyrax/editor')
      var RequiredFields = require('required_fields')
      var SaveWorkControl = require('hyrax/save_work/save_work_control')

      var EtdEditor = require('etd_editor')
      new EtdEditor(element)

      var aboutMeAndMyProgram = require('about_me_and_my_program')
      new aboutMeAndMyProgram()

      var AboutMySupplementalFiles = require('about_my_supplemental_files')
      new AboutMySupplementalFiles()

      var reviewMyETD = require('review_my_etd')
      new reviewMyETD("#review_my_etd", "#preview_my_etd")
  }
}

Hyrax.tinyMCE = function(){
  if (typeof tinyMCE === "undefined")
    return
  tinyMCE.init({
    selector: 'textarea.tinymce',
    setup:function(ed) {
      ed.on('change', function(e) {
        // console.log("Editor: " + ed.id + " has changed.");
        laevigata_data[ed.id] = ed.getContent();
        $(document).trigger('laevigata:tinymce:change');
      });
    }
  });
}
