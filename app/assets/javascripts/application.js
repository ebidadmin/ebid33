// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function() { 
	var loading = "<span class='loading'>loading ...</span>"	
	$('div#veh-brand select').change(function() {
		var brand_id = $(this).val();	
		$('div#veh-model select').after(loading)
		$('div#veh-variant select').html('<option>Select Variant</option>')
		$.ajax({
			type: 'get',
			url: '/car_brands/' + parseInt(brand_id) + '/selected',
			success: function(html) {
				$('div#veh-model select').html(html);
			},
			complete: function() { $('span.loading').remove(); }
		});
	});
	$('div#veh-model select').change(function() {
		var model_id = $(this).val();		
		$('div#veh-variant select').after(loading)
		$.ajax({
			type: 'get',
			url: '/car_models/' + parseInt(model_id) + '/selected',
			success: function(html) {
				$('div#veh-variant select').html(html);
			},
			complete: function() { $('span.loading').remove(); }
		});
	});
	$('div#regions select').change(function() { 
		var region_id = $(this).val();
		$('div#cities select').after(loading)
		$.ajax({
			type: 'get',
			url: '/regions/' + parseInt(region_id) + '/selected',
			success: function(html) {
				$('div#cities select').html(html);
			},
			complete: function() { $('span.loading').remove(); }
		});
	});
	$('div.fields').addClass('span4')
	// function autosaveForm() {
	//   $('form[data-remote]').submit();
	// }
	// window.setInterval("autosaveForm()", 1000);
	// 
});