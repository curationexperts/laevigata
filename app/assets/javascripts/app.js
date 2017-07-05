Hyrax.editor = function() {
  var element = $("[data-behavior='work-form']")
  if (element.length > 0) {
      var Editor = require('hyrax/editor')
      var RequiredFields = require('required_fields')
      var SaveWorkControl = require('hyrax/save_work/save_work_control')
      var EtdEditor = require('etd_editor')
      new EtdEditor(element)
  }
}

Hyrax.tinyMCE = function(){
  if (typeof tinyMCE === "undefined")
    return;
  tinyMCE.init({
    selector: 'textarea.tinymce',
    setup:function(ed) {
      ed.on("init",
         function(ed) {
           tinyMCE.get('etd_abstract').setContent("<p></p>");
           tinyMCE.get('etd_table_of_contents').setContent("<p></p>");
           tinyMCE.execCommand('mceRepaint');
         }
     );
      var SaveEtd = require('etd_save_work_control')
      var etd_save_work_control = new SaveEtd($("#form-progress"), this.adminSetWidget)
      ed.on('change', function(e) {
        etd_save_work_control.formStateChanged(".about-my-etd");
      });
    }
  });
}
