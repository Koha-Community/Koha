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
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
	<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js"></script>
	<script language="JavaScript" type="text/javascript">
		function _(s) { return s } // dummy function for gettext
		//
	</script>
	<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = _("Le panier est vide");
	var MSG_RECORD_IN_BASKET = _("Cette notice est déjà dans le panier");
	var MSG_RECORD_ADDED = _("Notice ajoutée au panier");
	var MSG_NRECORDS_ADDED = _("Notice(s) ajoutée(s)");
	var MSG_NRECORDS_IN_BASKET = _("Envoyer le panier");
	var MSG_NO_RECORD_SELECTED = _("Aucune notice sélectionnée");
	var MSG_NO_RECORD_ADDED = _("Aucune notice ajoutée");
	function Dopop(link) {
		newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
	}
	</script>
</head>
<body>
	<!-- MENUS -->
	<div id="menuline">
		<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" height="50" alt="Logo Koha" style="float: left">
		<div class="SmallLibraryName"><!--TMPL_VAR name="LibraryName"--></div>
		<span class="spacer">&nbsp;</span>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Page d'accueil Koha">Accueil</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-search.pl" title="Recherche avancée">Recherche avancée</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="Page d'accueil Membre">Vos informations</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="javascript:openBasket()" title="Panier de notices">Panier de notices <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
	</div>
	<!-- MAIN BODY OF PAGE -->
