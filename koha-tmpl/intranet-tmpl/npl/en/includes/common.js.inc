<script language="javascript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}

function openWindow(targeturl, windowname) {
	newwin =
	window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
 
 	var newwin;
	
	// Open the popup window if it doesn't already exist and give it focus.
	function PopWin(targeturl, windowname) {
	
		if (!newwin || newwin.closed) newwin = window.open(targeturl,windowname, "height=300,width=400,scrollbars=yes,resizable=yes");
	  newwin.focus();
	}
	
  // Set the value of the form field to the passed value and optionally shift
	// focus and close the popup.
	function FillForm(val,formname,formfield) {
	
		document.forms[formname].elements[formfield].value = val;

		// Uncomment below to shift focus after clicking link in popup.
		document.forms[formname].elements[formfield].focus();
		
		// Uncomment below to close popup after clicking link.
		newwin.close();
	}

// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_images() {
    for (var i = 0; i < document.images.length; i++) {
        img = document.images[i];
        if ((img.src.indexOf('images') >= 0)) {
			w = img.width;
            h = img.height;
     if ((w == 0) && (h == 0) || ((img.complete != null) && (!img.complete))) {
               img.src = '<!-- TMPL_VAR NAME='themelang' -->/images/patron-blank.png';
			}
        }
    }
}

function mainfocus() {
		if(document.forms['mainform']){
			document.forms['mainform'].elements[0].focus();
		}
	}
</script>