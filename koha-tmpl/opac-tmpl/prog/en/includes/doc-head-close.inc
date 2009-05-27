</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="Koha <!-- TMPL_VAR NAME="Version" -->" /> <!-- leave this for stats -->
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME="themelang" -->/includes/favicon.ico" type="image/x-icon" />
<!-- TMPL_IF name="opacstylesheet" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="opacstylesheet" -->" /><!-- TMPL_ELSE -->
<!-- TMPL_IF name="opaclayoutstylesheet" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->" /><!-- TMPL_ELSE --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/opac.css" /><!-- /TMPL_IF --><!-- /TMPL_IF -->
<!-- TMPL_IF name="opaccolorstylesheet" -->
    <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
<!-- /TMPL_IF -->
<!-- TMPL_IF name="opac_css_override" -->
    <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opac_css_override" -->" />
<!-- /TMPL_IF -->
<link rel="stylesheet" type="text/css" media="print" href="<!-- TMPL_VAR NAME="themelang" -->/css/print.css" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/ui.tabs.css" />
<!-- TMPL_IF NAME="OPACUserCSS" --><style type="text/css"><!-- TMPL_VAR NAME="OPACUserCSS" --></style><!-- /TMPL_IF -->
<!-- yui js --> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/utilities/utilities.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/container/container-min.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/menu/menu-min.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ui.tabs.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.dimensions-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.dropshadow-min.js"></script>
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/script.js"></script>
<!-- TMPL_IF NAME="OPACAmazonCoverImages" -->
<script type="text/javascript" language="javascript">//<![CDATA[
		var NO_AMAZON_IMAGE = _("No cover image available");
	//]]>
</script>
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/amazonimages.js"></script>
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="SyndeticsCoverImages" -->
<script type="text/javascript" language="javascript">//<![CDATA[
        var NO_AMAZON_IMAGE = _("No cover image available");
    //]]>
</script>
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/amazonimages.js"></script>          <!-- /TMPL_IF -->

<script type="text/javascript" language="javascript"
<!-- TMPL_IF NAME="opacbookbag" -->src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"><!-- TMPL_ELSIF NAME="virtualshelves" -->src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"><!-- TMPL_ELSE -->>var readCookie;<!-- /TMPL_IF --></script>
<!-- TMPL_IF NAME="TagsEnabled" --><script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/tags.js"></script><!-- /TMPL_IF -->
<script type="text/javascript" language="javascript">
	//<![CDATA[
    <!-- TMPL_IF NAME="opacbookbag" -->var MSG_BASKET_EMPTY = _("Your cart is currently empty");
    var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
    var MSG_RECORD_ADDED = _("This item has been added to your cart");
    var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
    var MSG_NRECORDS_IN_BASKET = _("already in your cart");
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
    var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
    var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
    var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
	$("#cartDetails").ready(function(){ $("#cmspan").html("<a href=\"#\" id=\"cartmenulink\" class=\"\"><i></i><span><i></i><span></span><img src=\"/opac-tmpl/prog/images/cart.gif\" width=\"14\" height=\"14\" alt=\"\" border=\"0\" /> "+_("Cart")+"<span id=\"basketcount\"></span></span></a>"); }); <!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="OPACAmazonCoverImages" -->$(window).load(function() {
		 	verify_images();
		 });<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="SyndeticsCoverImages" -->$(window).load(function() {
            verify_images();
         });<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="opacuserjs" --><!-- TMPL_VAR NAME="opacuserjs" --><!-- /TMPL_IF -->
	//]]>
</script><script type="text/javascript" language="javascript"
<!-- TMPL_IF NAME="opacbookbag" -->src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"><!-- TMPL_ELSIF NAME="virtualshelves" -->src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"><!-- TMPL_ELSE -->>var readCookie;<!-- /TMPL_IF --></script>
<!-- TMPL_IF NAME="TagsEnabled" --><script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/tags.js"></script><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="GoogleJackets" -->
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/google-jackets.js"></script>
<script type="text/javascript" language="javascript">
	//<![CDATA[
	var NO_GOOGLE_JACKET = _("No cover image available");
	//]]>
</script>
<!-- /TMPL_IF --><!-- TMPL_IF NAME="BakerTaylorEnabled" --><script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/bakertaylorimages.js"></script>
<script type="text/javascript" language="javascript">
	//<![CDATA[
	var NO_BAKERTAYLOR_IMAGE = _("No cover image available");
	$(window).load(function(){
		bt_verify_images();
	});
	//]]>
</script><!-- /TMPL_IF -->
<link rel="unapi-server" type="application/xml" title="unAPI" href="<!-- TMPL_VAR NAME="OPACBaseURL" -->/cgi-bin/koha/unapi" />
