// staff-global.js

function _(s) { return s } // dummy function for gettext

 $(document).ready(function() {
 	$(".focus").focus();
	$('#toplevelmenu').clickMenu(); 
	$('#header_search').tabs({
		onShow: function() {
	        $('#header_search').find('div:visible').find('input').eq(0).focus();
	    }	
	});
	$(".close").click(function(){
		window.close();
	});
 });
 

