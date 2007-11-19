</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- TMPL_IF name="RSS" -->
    <link rel="alternate" type="application/rss+xml" title="Koha - RSS" href="<!-- TMPL_VAR name="site_url"-->/opac-rss.pl?q=<!-- TMPL_VAR name="searchdesc"-->" />
<!-- /TMPL_IF -->
<!-- TMPL_IF name="opacstylesheet" -->
        <style type="text/css"> 
            @import url(<!-- TMPL_VAR NAME="opacstylesheet" -->);
        </style>
<!-- TMPL_ELSE -->
    <!-- TMPL_IF name="opaccolorstylesheet" -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
    <!-- TMPL_ELSE -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/opac.css" />
    <!-- /TMPL_IF -->
    <style type="text/css">
        @import url(<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->);
    </style>
<!-- /TMPL_IF -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/jquery.tabs.css" />
   <!-- Additional IE/Win specific style sheet (Conditional Comments) -->
        <!--[if lte IE 7]>
        <link rel="stylesheet" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/jquery.tabs-ie.css" type="text/css" media="projection, screen">
        <![endif]-->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.tabs.pack.js"></script>
<!-- TMPL_IF NAME="AmazonContent" --><script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/js/amazonimages.js"></script><!-- /TMPL_IF -->
<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/js/script.js"></script>
<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/js/basket.js"></script>
<script type="text/javascript" language="javascript">
    function _(s) { return s } // dummy function for gettext
    var MSG_BASKET_EMPTY = _("You book bag is currently empty");
    var MSG_RECORD_IN_BASKET = _("This item is already in your book bag");
    var MSG_RECORD_ADDED = _("This item has been added to your book bag");
    var MSG_NRECORDS_ADDED = _(" item(s) added to your book bag");
    var MSG_NRECORDS_IN_BASKET = _("already in the bag");
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
    var MSG_NO_RECORD_ADDED = _("No item was added to your book bag");
</script>
<!-- TMPL_IF NAME="opacuserjs" -->
<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	<!-- TMPL_VAR NAME="opacuserjs" -->
	//]]>
</script>	
<!-- /TMPL_IF -->