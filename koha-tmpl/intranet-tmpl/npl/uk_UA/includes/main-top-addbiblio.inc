<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Інтерфейс бібліотекаря у Коха</title>
<!-- TMPL_IF NAME="TemplateEncoding" -->
<meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME='TemplateEncoding' -->" />
<!-- TMPL_ELSE -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- /TMPL_IF -->
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<style type="text/css"> 
	<!-- TMPL_IF NAME="intranetstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetstylesheet" -->);<!-- TMPL_ELSE -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet.css);<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="intranetcolorstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->);<!-- /TMPL_IF -->
	@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/tabs.css);
</style>
<script language="JavaScript" type="text/javascript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
// newwin =
// window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
	location.href = targeturl;
}
 
 	var newwin;
	
	// Open the popup window if it doesn't already exist and give it focus.
	function PopWin(targeturl, windowname) {
	
		if (!newwin || newwin.closed) newwin = window.open(targeturl,windowname, "height=300,width=400");
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
 
// end hiding -->
</script>
</head>

<body onload="showPanel(1);">
