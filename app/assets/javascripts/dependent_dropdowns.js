Blacklight.onLoad(function() {
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

		var res = observed.val().split(" ")[0].toLowerCase() + "_programs";
		url = url_mask.replace(regexp, res);

		$.getJSON(url, function (data) {
			$.each(data, function (i, object) {
				observer.append($('<option>').attr('value', object.id).text(object.label));
				observer.attr('disabled', false);
			});
		});
	}
});
});
});
