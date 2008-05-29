if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
* A namespace for Tags related functions.
* readCookie is expected to already be declared.  That's why the assignment below is unscoped.
* readCookie should be from basket.js or undefined.

$.ajaxSetup({
	url: "/cgi-bin/koha/opac-tags.pl",
	type: "POST",
	dataType: "script"
});
*/
if (typeof(readCookie) == "undefined") {
	readCookie = function (name) { // from http://www.quirksmode.org/js/cookies.html
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' '){ c = c.substring(1,c.length); }
			if (c.indexOf(nameEQ) == 0){ return c.substring(nameEQ.length,c.length); }
		}
		return null;
	}
}
KOHA.Tags = {
	add_tag_button: function(){
		var mybibnum = $(this).attr("title");
		var mynewtag = "newtag" + mybibnum;
		var mytagid = "#" + mynewtag;
		var mydata = {CGISESSID: readCookie('CGISESSID')};	// Someday this should be OPACSESSID
		mydata[mynewtag] = $(mytagid).val();	// need [bracket] for variable property id
		var response;	// AJAX from server will assign value to response.
		$.post(
			"/cgi-bin/koha/opac-tags.pl",
			mydata,
			function(data){
				// alert("AJAX Response: " + data);
				eval(data);
				// alert("counts: " + response["added"] + response["deleted"] + response["errors"]);
				KOHA.Tags.set_tag_status(
					mytagid + "_status",
					KOHA.Tags.common_status(response["added"], response["deleted"], response["errors"])
				);
				if (response.alerts) {
					alert(response.alerts.join("\n\n"));
				}
			},
			'script'
		);
		return false;
	},
	common_status : function(addcount, delcount, errcount) {
	    var cstat = "";
	    if (addcount && addcount > 0) {cstat += "Added "   + addcount + (addcount==1 ? " tag" : " tags") + ".  " ;}
	    if (delcount && delcount > 0) {cstat += "Deleted " + delcount + (delcount==1 ? " tag" : " tags") + ".  " ;}
	    if (errcount && errcount > 0) {cstat += (errcount==1 ? "ERROR" : errcount + " ERRORS") + " during operation.";}
	    return cstat;
	},
	set_tag_status : function(tagid, newstatus) {
		$(tagid).html(newstatus);
		$(tagid).css({display:"inline"});
	},

	tag_message: {
	tagsdisabled : function(arg) {return ("Sorry, tags are not enabled on this system.");},
	scrubbed_all_bad : function(arg) {return ("Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text.");},
	badparam : function(arg) {return ("Error! Illegal parameter '" +arg+ "'.");},
	scrubbed : function(arg) {return ("Note: your tag contained markup code that was removed. The tag was added as '" +arg+ "'.");},
    failed_add_tag : function(arg) {return ("Error! The add_tag operation failed on '" +arg+ "'.  Note: you can only tag an item with a given term once.  Check 'My Tags' to see your current tags.");},
    failed_delete  : function(arg) {return ("Error! You cannot delete the tag '" +arg+ "'.  Note: you can only delete your own tags.");},
	},
};

