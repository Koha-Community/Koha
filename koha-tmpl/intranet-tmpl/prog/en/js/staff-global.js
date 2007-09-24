// staff-global.js

 $(document).ready(function() {
 	$(".focus").focus();
	$('#toplevelmenu').clickMenu(); 
	$('#header_search').tabs({
		onShow: function() {
	        $('#header_search').find('div:visible').find('input').eq(0).focus();
	    }	
	});
 });
 

