// staff-global.js

function _(s) { return s } // dummy function for gettext

 $(document).ready(function() {
 	$(".focus").focus();
	$('#toplevelmenu').clickMenu(); 
	$('#i18nMenu').clickMenu();
	$('#header_search').tabs({
		onShow: function() {
	        $('#header_search').find('div:visible').find('input').eq(0).focus();
	    }	
	});
	$(".close").click(function(){
		window.close();
	});
 });
 

// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_patron_images() {
    for (var i = 0; i < document.images.length; i++) {
        img = document.images[i];
        if ((img.src.indexOf('patronimages') >= 0)) {
			w = img.width;
            h = img.height;
     if ((w == 0) && (h == 0) || ((img.complete != null) && (!img.complete))) {
               img.src = '/intranet-tmpl/prog/img/patron-blank.png';
			}
        }
    }
}
