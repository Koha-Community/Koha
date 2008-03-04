</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME="themelang" -->/includes/favicon.ico" type="image/x-icon" />
<!-- TMPL_IF name="RSS" --><link rel="alternate" type="application/rss+xml" title="Koha - RSS" href="<!-- TMPL_VAR name="site_url"-->/opac-rss.pl?q=<!-- TMPL_VAR name="searchdesc"-->" /><!-- /TMPL_IF -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/button.css" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/menu.css" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/container.css" />
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/element/element-beta-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/animation/animation-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/container/container-min.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/menu/menu-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/button/button-beta-min.js"></script>

<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/utilities/utilities.js"></script>
<!-- TMPL_IF name="opacstylesheet" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="opacstylesheet" -->" /><!-- TMPL_ELSE -->
<!-- TMPL_IF name="opaccolorstylesheet" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" /><!-- /TMPL_IF -->
<!-- TMPL_IF name="opaclayoutstylesheet" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->" /><!-- TMPL_ELSE --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/opac.css" /><!-- /TMPL_IF --><!-- /TMPL_IF -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/ui.tabs.css" />
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ui.tabs.js"></script>
<!-- TMPL_IF NAME="AmazonContent" --><script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/amazonimages.js"></script><!-- /TMPL_IF -->
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/script.js"></script>
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"></script>
<script type="text/javascript" language="javascript">
	//<![CDATA[
    function _(s) { return s } // dummy function for gettext
    <!-- TMPL_IF NAME="opacbookbag" -->var MSG_BASKET_EMPTY = _("You cart is currently empty");
    var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
    var MSG_RECORD_ADDED = _("This item has been added to your cart");
    var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
    var MSG_NRECORDS_IN_BASKET = _("already in your cart");
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
    var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
    var MSG_CONFIRM_DEL_BASKET = "Are you sure you want to empty your cart?"
    var MSG_CONFIRM_DEL_RECORDS = "Are you sure you want to remove the selected items?";<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="AmazonContent" -->$(window).load(function() {
		 	verify_images();
		 });<!-- /TMPL_IF -->
	//]]>
</script>
<!-- TMPL_IF NAME="opacuserjs" -->
<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	<!-- TMPL_VAR NAME="opacuserjs" -->
	//]]>
</script>	
<!-- /TMPL_IF -->
<link rel="unapi-server" type="application/xml" title="unAPI" href="/cgi-bin/koha/unapi" />
<link rel="search" type="application/opensearchdescription+xml" title="Koha OpenSearch" href="/cgi-bin/koha/opensearch" />
