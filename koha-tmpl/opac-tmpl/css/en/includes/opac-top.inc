<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang"-->/includes/opac.css" />
	<title><!--TMPL_VAR name="LibraryName"--></title>
	<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js"></script>
	<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = "No biblio !";
	var MSG_RECORD_IN_BASKET = "This biblio is already in the basket";
	var MSG_RECORD_ADDED = "Biblio added to the basket";
	var MSG_NRECORDS_ADDED = " Biblio(s) added";
	var MSG_NRECORDS_IN_BASKET = "already in the basket";
	var MSG_NO_RECORD_SELECTED = "No biblio selected";
	var MSG_NO_RECORD_ADDED = "No biblio added";
	</script>
</head>
<body>
	<!-- MENUS -->
	<div id="menuline">
		<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" height="50" alt="koha logo" style="float: left" />
		<div class="SmallLibraryName"><!--TMPL_VAR name="LibraryName"--></div>
		<span class="spacer">&nbsp;</span>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Koha home page">Home</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-search.pl" title="Advanced search">Advanced search</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="Member Home page" >Members</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="javascript:openBasket()" title="Biblio basket">Biblio basket <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
	</div>
	<!-- MAIN BODY OF PAGE -->
