// staff-global.js

 $(document).ready(function() {
 	$(".focus").focus();
 });
 
 $(document).ready(function() {
	$('a#showCatSearch').click(function() {
		$('#catalog_search').show();
		$('#circ_search').hide();
		$('#showCircSearch').parents("li").addClass('off').removeClass('on');
		$('#showCatSearch').parents("li").addClass('on').removeClass('off');
		$('#search-form').val($('#findborrower').val()).focus();
		$('#residenttip').html("Enter search keywords:");
		return false;
	});
	
	$('a#showCircSearch').click(function() {
		$('#circ_search').show();
		$('#catalog_search').hide();
		$('#showCatSearch').parents("li").addClass('off').removeClass('on');
		$('#showCircSearch').parents("li").addClass('on').removeClass('off');
		$('#findborrower').val($('#search-form').val()).focus();
		$('#residenttip').html("Enter patron card number or partial name:");
		return false;
	});
});

