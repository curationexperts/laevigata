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
