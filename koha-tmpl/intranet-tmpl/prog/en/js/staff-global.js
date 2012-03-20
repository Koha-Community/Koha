// staff-global.js
if ( KOHA === undefined ) var KOHA = {};

function _(s) { return s; } // dummy function for gettext

 $(document).ready(function() {
    $('#header_search').tabs().bind('tabsshow', function(e, ui) { $('#header_search > div:not(.ui-tabs-hide)').find('input').eq(0).focus(); });
	$(".close").click(function(){ window.close(); });
    if($("#header_search #checkin_search").length > 0){ $(document).bind('keydown','Alt+r',function (){ $("#header_search").tabs("select","#checkin_search"); $("#ret_barcode").focus(); }); } else { $(document).bind('keydown','Alt+r',function (){ location.href="/cgi-bin/koha/circ/returns.pl"; }); }
    if($("#header_search #circ_search").length > 0){ $(document).bind('keydown','Alt+u',function (){ $("#header_search").tabs("select","#circ_search"); $("#findborrower").focus(); }); } else { $(document).bind('keydown','Alt+u',function(){ location.href="/cgi-bin/koha/circ/circulation.pl"; }); }
    if($("#header_search #catalog_search").length > 0){ $(document).bind('keydown','Alt+q',function (){ $("#header_search").tabs("select","#catalog_search"); $("#search-form").focus(); }); } else { $(document).bind('keydown','Alt+q',function(){ location.href="/cgi-bin/koha/catalogue/search.pl"; }); }
    $(".focus").focus();
    $(".validated").validate();
});



// http://jennifermadden.com/javascript/stringEnterKeyDetector.html
function checkEnter(e){ //e is event object passed from function invocation
	var characterCode; // literal character code will be stored in this variable
	if(e && e.which){ //if which property of event object is supported (NN4)
		e = e;
		characterCode = e.which; //character code is contained in NN4's which property
	} else {
		e = event;
		characterCode = e.keyCode; //character code is contained in IE's keyCode property
	}

	if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
		return false;
	} else {
		return true;
	}
}

function clearHoldFor(){
	$.cookie("holdfor",null, { path: "/", expires: 0 });
}

jQuery.fn.preventDoubleFormSubmit = function() {
    jQuery(this).submit(function() {
        if (this.beenSubmitted)
            return false;
        else
            this.beenSubmitted = true;
    });
};

function openWindow(link,name,width,height) {
    name = (typeof name == "undefined")?'popup':name;
    width = (typeof width == "undefined")?'600':width;
    height = (typeof height == "undefined")?'400':height;
    var newin=window.open(link,name,'width='+width+',height='+height+',resizable=yes,toolbar=false,scrollbars=yes,top');
}
