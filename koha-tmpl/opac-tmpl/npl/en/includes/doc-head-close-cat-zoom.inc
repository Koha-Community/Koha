</title>
<!-- TMPL_IF NAME="TemplateEncoding" -->
<meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME='TemplateEncoding' -->" />
<!-- TMPL_ELSE -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- /TMPL_IF -->
<meta http-equiv="Content-Language" content="en-us" />
<link rel="shortcut icon" href="<TMPL_VAR NAME="themelang">/includes/favicon.ico" type="image/x-icon" />
    <!-- TMPL_IF name="opacstylesheet" -->
<style type="text/css">
    @import url(<!-- TMPL_VAR NAME="opacstylesheet" -->);
</style>
    <!-- TMPL_ELSE -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
<style type="text/css">
    @import url(<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->);
</style>
    <!-- /TMPL_IF -->
<script language="JavaScript" type="text/javascript">
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
 


	function openDictionary(dict, search, target) {
	    if ((dict == 'all') || (dict == 'publicationyear')) {
	        alert("The selected field is not correct to search on dictionary.");
		} else {
	    	var dict_window = window.open('/cgi-bin/koha/dictionary.pl?dictionary=' + dict + '&search=' + search + '&target=' + target,'_blanck','height=325,width=550,status=no,toolbar=no,menubar=no,location=no,resizable=no,top=100,left=100');
        	dict_window.focus();
		}
	}

	</script>
	<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/catsearch.js"></script>
<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/basket.js"></script>
<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = "You book bag is currently empty";
	var MSG_RECORD_IN_BASKET = "This item is already in your book bag";
	var MSG_RECORD_ADDED = "This item has been added to your book bag";
	var MSG_NRECORDS_ADDED = " item(s) added to your book bag";
	var MSG_NRECORDS_IN_BASKET = "already in the bag";
	var MSG_NO_RECORD_SELECTED = "No item was selected";
	var MSG_NO_RECORD_ADDED = "No item was added to your book bag";
</script>
</head>

<body>
