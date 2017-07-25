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

if($('#etd_school option:selected').index()==4){
	
	$('#help-members').remove();
	$(".etd_committee_members_0_name label, .etd_committee_members_0_name, #etd_committee_members_0_name").removeClass('required').addClass('optional');
	$('.etd_partnering_agency').removeClass('hidden');
}else{
	$('.etd_committee_members_0_name label').append("<p class='help-block' id='help-members'>At least one committee member is required</p>")
	$(".etd_committee_members_0_name label, .etd_committee_members_0_name, #etd_committee_members_0_name").removeClass('optional').addClass('required');
	$('.etd_partnering_agency').addClass('hidden');
}
var res = observed.val().split(" ")[0].toLowerCase() + "_programs";
url = url_mask.replace(regexp, res);

$.getJSON(url, function (data) {
$.each(data, function (i, object) {
observer.append($('<option>').attr('value', object.id).text(object.label));
observer.attr('disabled', false);
});
});
}else{
	$(".etd_committee_members_0_name label, .etd_committee_members_0_name, #etd_committee_members_0_name").removeClass('required').addClass('optional');
	$('.etd_partnering_agency').removeClass('hidden');
}
});
});
});
