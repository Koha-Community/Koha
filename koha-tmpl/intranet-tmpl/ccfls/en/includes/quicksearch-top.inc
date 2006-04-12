<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>popup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<script language="javascript" type="text/javascript">
	// Set the value of the form field to the passed value and optionally shift
	// focus and close the popup.
	function FillForm(val,formname,formfield) {
		document.forms[formname].elements[formfield].value = val;
		// Uncomment below to shift focus after clicking link in popup.
		document.forms[formname].elements[formfield].focus();
		// Uncomment below to close popup after clicking link.
		newwin.close();
	}
</script>
</head>

<body>
<!-- NO MENUS for popup-top -->
