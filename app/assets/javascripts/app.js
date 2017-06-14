Hyrax.editor = function() {
    var element = $("[data-behavior='work-form']")
    if (element.length > 0) {
        var Editor = require('hyrax/editor')
        var SaveWorkControl = require('hyrax/save_work/save_work_control')
        var EtdEditor = require('etd_editor')
        new EtdEditor(element)
    }
}

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
