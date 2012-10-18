</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="Koha [% Version %]" /> <!-- leave this for stats -->
<link rel="shortcut icon" href="[% IF ( OpacFavicon ) %][% OpacFavicon %][% ELSE %][% themelang %]/includes/favicon.ico[% END %]" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% themelang %]/lib/jquery/jquery-ui.css" />
<link rel="stylesheet" type="text/css" href="/opac-tmpl/lib/yui/reset-fonts-grids.css" />
<link rel="stylesheet" type="text/css" href="/opac-tmpl/lib/yui/skin.css" />
[% SET opaclayoutstylesheet='opac.css' UNLESS opaclayoutstylesheet %]
[% IF (opaclayoutstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% opaclayoutstylesheet %]" />
[% ELSE %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% opaclayoutstylesheet %]" />
[% END %]
[% IF ( opaccolorstylesheet ) %]
    [% IF (opaccolorstylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% opaccolorstylesheet %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% opaccolorstylesheet %]" />
    [% END %]
[% END %]
[% IF ( opac_css_override ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% opac_css_override %]" />
[% END %]
<link rel="stylesheet" type="text/css" media="print" href="[% themelang %]/css/print.css" />
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0,user-scalable=no">
<link rel="stylesheet" type="text/css" media="screen and (max-width:700px)" href="[% themelang %]/css/mobile.css" />
[% IF ( OPACMobileUserCSS ) %]<style type="text/css" media="screen and (max-width:700px)">[% OPACMobileUserCSS %]</style>[% END %]
[% IF ( OPACUserCSS ) %]<style type="text/css">[% OPACUserCSS %]</style>[% END %]
<!-- yui js -->
<script type="text/javascript" src="[% yuipath %]/utilities/utilities.js"></script>
<script type="text/javascript" src="[% yuipath %]/container/container-min.js"></script>
<script type="text/javascript" src="[% yuipath %]/menu/menu-min.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/jquery-ui.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript" language="javascript" src="[% themelang %]/js/script.js"></script>
[% IF ( OPACAmazonCoverImages ) %]
<script type="text/javascript" language="javascript">//<![CDATA[
    var NO_AMAZON_IMAGE = _("No cover image available");
//]]>
</script>
<script type="text/javascript" language="javascript" src="[% themelang %]/js/amazonimages.js"></script>
[% END %]
[% IF ( SyndeticsCoverImages ) %]
<script type="text/javascript" language="javascript">//<![CDATA[
        var NO_AMAZON_IMAGE = _("No cover image available");
    //]]>
</script>
<script type="text/javascript" language="javascript" src="[% themelang %]/js/amazonimages.js"></script>          [% END %]

[% IF ( opacbookbag ) %]<script type="text/javascript" language="javascript" src="[% themelang %]/js/basket.js">
[% ELSIF ( virtualshelves ) %]<script type="text/javascript" language="javascript" src="[% themelang %]/js/basket.js">
[% ELSE %]<script type="text/javascript" language="javascript"> var readCookie;[% END %]
</script>

<script type="text/javascript" language="javascript">
//<![CDATA[
    [% IF ( opacbookbag ) %]var MSG_BASKET_EMPTY = _("Your cart is currently empty");
    var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
    var MSG_RECORD_ADDED = _("This item has been added to your cart");
    var MSG_RECORD_REMOVED = _("This item has been removed from your cart");
    var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
    var MSG_NRECORDS_IN_BASKET = _("already in your cart");
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
    var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
    var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
    var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
    var MSG_ITEM_IN_CART = _("In your cart");
    var MSG_IN_YOUR_CART = _("Items in your cart: ");
    var MSG_ITEM_NOT_IN_CART = _("Add to your cart");
      $("#cartDetails").ready(function(){ $("#cmspan").html("<a href=\"#\" id=\"cartmenulink\" class=\"\"><span> "+_("Cart")+"<span id=\"basketcount\"><\/span><\/span><\/a>"); });
    [% ELSE %][% IF ( virtualshelves ) %]
    var MSG_NO_RECORD_SELECTED = _("No item was selected");[% END %][% END %]
    [% IF ( opacuserlogin ) %][% IF ( TagsEnabled ) %]var MSG_TAGS_DISABLED = _("Sorry, tags are not enabled on this system.");
    var MSG_TAG_ALL_BAD = _("Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text.");
    var MSG_ILLEGAL_PARAMETER = _("Error! Illegal parameter");
    var MSG_TAG_SCRUBBED = _("Note: your tag contained markup code that was removed. The tag was added as ");
    var MSG_ADD_TAG_FAILED = _("Error! The add_tag operation failed on");
    var MSG_ADD_TAG_FAILED_NOTE = _("Note: you can only tag an item with a given term once.  Check 'My Tags' to see your current tags.");
    var MSG_DELETE_TAG_FAILED = _("Error! You cannot delete the tag");
    var MSG_DELETE_TAG_FAILED_NOTE = _("Note: you can only delete your own tags.")
    var MSG_LOGIN_REQUIRED = _("You must be logged in to add tags.");
    var MSG_TAGS_ADDED = _("Tags added: ");
    var MSG_TAGS_DELETED = _("Tags added: ");
    var MSG_TAGS_ERRORS = _("Errors: ");
    var MSG_MULTI_ADD_TAG_FAILED = _("Unable to add one or more tags.");
    var MSG_NO_TAG_SPECIFIED = _("No tag was specified.");[% END %][% END %]
    [% IF ( OPACAmazonCoverImages ) %]$(window).load(function() {
        verify_images();
    });[% END %]
    [% IF ( SyndeticsCoverImages ) %]$(window).load(function() {
            verify_images();
         });[% END %]
//]]>
[% IF ( opacbookbag ) %]</script><script type="text/javascript" language="javascript" src="[% themelang %]/js/basket.js">
[% ELSIF ( virtualshelves ) %]</script><script type="text/javascript" language="javascript" src="[% themelang %]/js/basket.js">
[% ELSE %]</script><script type="text/javascript" language="javascript">var readCookie;[% END %]</script>
[% IF ( opacuserlogin ) %][% IF ( TagsEnabled ) %]<script type="text/javascript" language="javascript" src="[% themelang %]/js/tags.js"></script>[% END %][% ELSE %][% END %]
[% IF ( GoogleJackets ) %]
<script type="text/javascript" language="javascript" src="[% themelang %]/js/google-jackets.js"></script>
<script type="text/javascript" language="javascript">
//<![CDATA[
    var NO_GOOGLE_JACKET = _("No cover image available");
//]]>
</script>
[% END %]
[% IF OpenLibraryCovers %]
<script type="text/javascript" language="javascript" src="[% themelang %]/js/openlibrary.js"></script>
<script type="text/javascript" language="javascript">
//<![CDATA[
var NO_OL_JACKET = _("No cover image available");
//]]>
</script>
[% END %]

[% IF OPACLocalCoverImages %]
<script type="text/javascript" language="javascript" src="[% themelang %]/js/localcovers.js"></script>
<script type="text/javascript" language="javascript">
//<![CDATA[
var NO_LOCAL_JACKET = _("No cover image available");
//]]>
</script>
[% END %]

[% IF ( BakerTaylorEnabled ) %]<script type="text/javascript" language="javascript" src="[% themelang %]/js/bakertaylorimages.js"></script>
<script type="text/javascript" language="javascript">
//<![CDATA[
    var NO_BAKERTAYLOR_IMAGE = _("No cover image available");
    $(window).load(function(){
        bt_verify_images();
    });
//]]>
</script>[% END %]
<link rel="unapi-server" type="application/xml" title="unAPI" href="[% OPACBaseURL %]/cgi-bin/koha/unapi" />
[% IF ( GoogleIndicTransliteration ) %]
        <script type="text/javascript" src="http://www.google.com/jsapi"></script>
        <script type="text/javascript" language="javascript" src="[% themelang %]/js/googleindictransliteration.js"></script>
[% END %]
