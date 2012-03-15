// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require private_pub
//= require_tree .

$(function() { 
	var loading = "<span class='loading'><img src='/assets/loading.gif'></span>"	
	$('div#veh-brand select').change(function() {
		var brand_id = $(this).val();	
		$('div#veh-model select').after(loading)
		$('div#veh-variant select').html('<option>Select Variant</option>')
		$.ajax({
			type: 'get',
			url: '/car_brands/' + parseInt(brand_id) + '/selected'
		});
	});
	$('div#veh-model select').change(function() {
		var model_id = $(this).val();		
		$('div#veh-variant select').after(loading)
		$.ajax({
			type: 'get',
			url: '/car_models/' + parseInt(model_id) + '/selected'
		});
	});
	$('div#regions select').change(function() { 
		var region_id = $(this).val();
		$('div#cities select').after(loading)
		$.ajax({
			type: 'get',
			url: '/regions/' + parseInt(region_id) + '/selected'
		});
	});
	$('div#companies select').change(function() { 
		var company_id = $(this).val();
		$('div#branches select').after(loading)
		$.ajax({
			type: 'get',
			url: '/companies/' + parseInt(company_id) + '/selected',
			success: function(html) {
				$('div#branches select').html(html);
			},
			complete: function() { $('span.loading').remove(); }
		});
	});
	$('div.fields').addClass('well');
	$('div.fields div').addClass('span5');
	$("#parts-pagination a").live("click", function() {
    $(".pagination").html(loading);
		$.getScript(this.href);
		return false;
	});
	$('input.btn').live("click", function() {
	    $(".spinner").toggle();
	});
	
	// $('div#cart-search').hide();
	// function autosaveForm() {
	//   $('form[data-remote]').submit();
	// }
	// window.setInterval("autosaveForm()", 1000);
	// 
	// $("a .group").colorbox();
});