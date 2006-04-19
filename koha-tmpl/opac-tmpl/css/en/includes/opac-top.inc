<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<!-- TMPL_IF name="opacstylesheet" -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="opacstylesheet"-->" />
	<!-- TMPL_ELSE -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang"-->/includes/opac.css" />
	<!-- /TMPL_IF -->
	<title><!--TMPL_VAR name="LibraryName"--></title>
	<!-- TMPL_IF NAME="TemplateEncoding" --><meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME='TemplateEncoding' -->" /><!-- TMPL_ELSE --><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><!-- /TMPL_IF -->
	<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js"></script>
	<script language="JavaScript" type="text/javascript">
		function _(s) { return s } // dummy function for gettext
		//
	</script>
	<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = _("Basket is empty");
	var MSG_RECORD_IN_BASKET = _("This biblio is already in the basket");
	var MSG_RECORD_ADDED = _("Biblio added to the basket");
	var MSG_NRECORDS_ADDED = _(" Biblio(s) added");
	var MSG_NRECORDS_IN_BASKET = _("already in the basket");
	var MSG_NO_RECORD_SELECTED = _("No biblio selected");
	var MSG_NO_RECORD_ADDED = _("No biblio added");
	function Dopop(link) {
		newin=window.open(link,'popup','width=700,height=500,toolbar=false,scrollbars=yes');
	}
	</script>
</head>
<body>
	<!-- MENUS -->
	<div id="title">
		<!-- TMPL_IF name="opacsmallimage" -->
			<img src="<!-- TMPL_VAR name="opacsmallimage"-->" alt="koha logo"/>
		<!-- TMPL_ELSE -->
			<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" alt="koha logo"/>
		<!-- /TMPL_IF -->
		<div class="SmallLibraryName"><!--TMPL_VAR name="LibraryName"--></div>
	</div>
	<!-- TMPL_INCLUDE name="menus.inc" -->
	<!-- MAIN BODY OF PAGE -->
