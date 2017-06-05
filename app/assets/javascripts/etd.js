Etd = {
    initialize: function () {
      this.editor();
    },

    etd_save_work_control: function() {
	   var EtdSaveWorkControl = require('etd_save_work_control')
      return new EtdSaveWorkControl()
    },
    editor: function () {
      var element = $("[data-behavior='work-form']")
      if (element.length > 0) {
        var EtdEditor = require('editor')
         return new EtdEditor(element)
      }
    }
}
