// staff-global.js

 $(document).ready(function() {
 	$(".focus").focus();
	$('#toplevelmenu').clickMenu(); 
	$('#header_search').tabs({
    onShow: function() {
        alert($('#header_search').children("div:visible").children("input:eq(0)").focus());
    }
});
 });
 

