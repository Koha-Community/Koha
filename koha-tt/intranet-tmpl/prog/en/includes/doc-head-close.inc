<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% themelang %]/includes/favicon.ico[% END %]" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% themelang %]/lib/jquery/plugins/ui.tabs.css" />
<link rel="stylesheet" type="text/css" media="print" href="[% themelang %]/css/print.css" />
[% IF ( intranetstylesheet ) %]
    <link rel="stylesheet" type="text/css" href="[% intranetstylesheet %]" />
[% ELSE %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/staff-global.css" />
[% END %]
[% IF ( css_libs ) %]
    [% FOREACH css_lib IN css_libs %]
        <link rel="stylesheet" type="text/css" href="[% themelang %]/[% css_lib.lib %]" />
    [% END %]
[% END %]

[% IF ( css_module ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/modules/[% css_module %]" />
[% END %]
[% IF ( css_page ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/pages/[% css_page %]" />
[% END %]

[% IF ( css_widgets ) %]
    [% FOREACH css_widget IN css_widgets %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/[% css_widget.widget %]" />
    [% END %]
[% END %]
[% IF ( IntranetUserCSS ) %]<style type="text/css">[% IntranetUserCSS %]</style>[% END %]

<script type="text/javascript" src="[% themelang %]/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/ui.tabs.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/jquery.hotkeys.min.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/jquery.cookie.min.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/jquery.highlight-3.js"></script>

[% IF ( js_libs ) %]
    [% FOREACH js_lib IN js_libs %]
        <script type="text/javascript" src="[% themelang %]/[% js_lib.lib %]"></script>
    [% END %]
[% END %]
[% IF ( js_module ) %]
    <script type="text/javascript" src="[% themelang %]/js/modules/[% js_module %]"></script>
[% END %]
[% IF ( js_page ) %]
    <script type="text/javascript" src="[% themelang %]/js/pages/[% js_page %]"></script>
[% END %]

[% IF ( js_widgets ) %]
    [% FOREACH js_widget IN js_widgets %]
        <script type="text/javascript" src="[% themelang %]/[% js_widget.widget %]"></script>
    [% END %]
[% END %]
[% IF ( login ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/login.css" />
[% END %]
[% IF ( wizard ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/wizard.css" />
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% intranetcolorstylesheet %]" />
[% END %]

<!-- yui js --> 
<script type="text/javascript" src="[% yuipath %]/utilities/utilities.js"></script> 
<script type="text/javascript" src="[% yuipath %]/datasource/datasource-min.js"></script>
[% IF ( CircAutocompl ) %]
    <script type="text/javascript" src="[% yuipath %]/autocomplete/autocomplete-min.js"></script>
[% END %]
<script type="text/javascript" src="[% yuipath %]/button/button-min.js"></script> 
<script type="text/javascript" src="[% yuipath %]/container/container_core-min.js"></script> 
<script type="text/javascript" src="[% yuipath %]/menu/menu-min.js"></script> 

<!-- koha core js -->
<script type="text/javascript" src="[% themelang %]/js/staff-global.js"></script>
[% IF ( intranetuserjs ) %]
    <script type="text/javascript">
    //<![CDATA[
    [% intranetuserjs %]
    //]]>
    </script>
[% END %]
<script type="text/javascript" language="javascript">
    //<![CDATA[
    [% IF ( intranetbookbag ) %]var MSG_BASKET_EMPTY = _("Your cart is currently empty");
        var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
        var MSG_RECORD_ADDED = _("This item has been added to your cart");
        var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
        var MSG_NRECORDS_IN_BASKET = _("already in your cart");
        var MSG_NO_RECORD_SELECTED = _("No item was selected");
        var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
        var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
        var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
        var MSG_NON_RESERVES_SELECTED = _("One or more selected items cannot be reserved.");
    [% END %]
    //]]>
    </script>
    [% IF ( virtualshelves || intranetbookbag ) %]
        <script type="text/javascript" language="javascript" src="[% themelang %]/js/basket.js"></script>
    [% END %]
