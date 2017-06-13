// Hyrax.editor = () => {
//     var AdminSetControls = require('hyrax/admin/admin_set_controls')
//     var MyAdminSetControls = require('my_admin_set_controls')
//     var controls = new MyAdminSetControls($('#admin-set-controls'))
//     console.log("Init'ng my controls")
// }





// Once, javascript is written in a modular format, all initialization
// code should be called from here.
Hyrax = {
    initialize: function () {
        this.autocomplete();
        this.popovers();
        this.permissions();
        this.notifications();
        this.transfers();
        this.editor();
        this.fileManager();
        this.selectWorkType();
        this.datatable();
        this.admin();
        this.adminStatisticsGraphs();
        this.tinyMCE();
    },

    tinyMCE: function() {
        if (typeof tinyMCE === "undefined")
            return;
        tinyMCE.init({
            selector: 'textarea.tinymce'
        });
    },

    admin: function() {
      var AdminSetControls = require('hyrax/admin/admin_set_controls');
      var controls = new AdminSetControls($('#admin-set-controls'));
    },

    adminStatisticsGraphs: function() {
        var AdminGraphs = require('hyrax/admin/graphs');
        new AdminGraphs(Hyrax.statistics);
    },

    datatable: function () {
        // This keeps the datatable from being added to a table that already has it.
        // This is a problem when turbolinks is active.
        if ($('.dataTables_wrapper').length === 0) {
            $('.datatable').DataTable();
        }
    },

    autocomplete: function () {
        var Autocomplete = require('hyrax/autocomplete')
        var autocomplete = new Autocomplete()

        $('[data-autocomplete]').each((function() {
          var data = $(this).data()
          autocomplete.setup({'element' : $(this), 'data': data})
        }))

        $('.multi_value.form-group').manage_fields({
          add: function(e, element) {
              autocomplete.setup({'element':$(element), 'data':$(element).data()})
	      // Don't mark an added element as readonly even if previous element was
	      $(element).attr('readonly', false)
          }
        })
    },

    editor: function () {
        var element = $("[data-behavior='work-form']")
        if (element.length > 0) {
          var Editor = require('hyrax/editor');
          new Editor(element)
        }
    },

    // initialize popover helpers
    popovers: function () {
        $("a[data-toggle=popover]").popover({html: true})
            .click(function () {
                return false;
            });
    },

    permissions: function () {
        var PermissionsControl = require('hyrax/permissions/control');
        // On the edit work page
        new PermissionsControl($("#share"), 'tmpl-work-grant');
        // On the edit fileset page
        new PermissionsControl($("#permission"), 'tmpl-file-set-grant');
        // On the batch edit page
        new PermissionsControl($("#form_permissions"), 'tmpl-work-grant');
    },

    notifications: function () {
        var Notifications = require('hyrax/notifications');
        $('[data-update-poll-url]').each(function () {
            var interval = $(this).data('update-poll-interval');
            var url = $(this).data('update-poll-url');
            new Notifications(url, interval);
        });
    },

    transfers: function () {
        $("#proxy_deposit_request_transfer_to").userSearch();
    },

    selectWorkType: function () {
        var SelectWorkType = require('hyrax/select_work_type');
        $("[data-behavior=select-work]").each(function () {
            new SelectWorkType($(this));
        });
    },

    fileManager: function () {
        var FileManager = require('hyrax/file_manager');
        new FileManager();
    },

    authoritySelect: function(options) {
	var AuthoritySelect = require('hyrax/authority_select');
	var authoritySelect = new AuthoritySelect(options);
	authoritySelect.initialize();
    },

    // Saved so that inline javascript can put data somewhere.
    statistics: {}

};


jQuery(document).ready(function () {
$('select[data-option-dependent=true]').each(function (i) {
var observer_dom_id = $(this).attr('id');
var observed_dom_id = $(this).data('option-observed');
var url_mask = $(this).data('option-url');
var key_method = $(this).data('option-key-method');
var value_method = $(this).data('option-value-method');
var prompt = $(this).has("option[value='']").size() ? $(this).find("option[value='']") : $("<option>").text("?");

var regexp = /:[0-9a-zA-Z_]+:/g;
var observer = $('select#' + observer_dom_id);
var observed = $('#' + observed_dom_id);

if (!observer.val() && observed.size() > 1) {
observer.attr('disabled', true);
}
observed.on('change', function () {
observer.empty().append(prompt);
if (observed.val()) {
url = url_mask.replace(regexp, observed.val());
$.getJSON(url, function (data) {
$.each(data, function (i, object) {
console.log(object)
observer.append($('<option>').attr('value', object.id).text(object.label));
observer.attr('disabled', false);
});
});
}
});
});
});

jQuery(document).ready(function () {
$('select[data-option-dependent=true]').each(function (i) {
var observer_dom_id = $(this).attr('id');
var observed_dom_id = $(this).data('option-observed');
var url_mask = $(this).data('option-url');
var key_method = $(this).data('option-key-method');
var value_method = $(this).data('option-value-method');
var prompt = $(this).has("option[value='']").size() ? $(this).find("option[value='']") : $("<option>").text("?");

var regexp = /:[0-9a-zA-Z_]+:/g;
var observer = $('select#' + observer_dom_id);
var observed = $('#' + observed_dom_id);

if (!observer.val() && observed.size() > 1) {
observer.attr('disabled', true);
}
observed.on('change', function () {
observer.empty().append(prompt);
if (observed.val()) {
url = url_mask.replace(regexp, observed.val());
$.getJSON(url, function (data) {
$.each(data, function (i, object) {
console.log(object)
observer.append($('<option>').attr('value', object.id).text(object.label));
observer.attr('disabled', false);
});
});
}
});
});
});

