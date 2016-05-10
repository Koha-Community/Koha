[% USE Koha %]
[% USE AudioAlerts %]
[% USE String %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <style id="antiClickjack">body{display:none !important;}</style>
    <script type="text/javascript">
       if (self === top) {
           var antiClickjack = document.getElementById("antiClickjack");
           antiClickjack.parentNode.removeChild(antiClickjack);
       } else {
           top.location = self.location;
       }
    </script>
[% END %]

<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% interface %]/[% theme %]/img/favicon.ico[% END %]" type="image/x-icon" />

<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/bootstrap/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/font-awesome/css/font-awesome.min.css" />
<link rel="stylesheet" type="text/css" media="print" href="[% interface %]/[% theme %]/css/print.css" />
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi )            %]<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/right-to-left.css" />[% END %]

<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-2.2.3.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/shortcut/shortcut.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.cookie.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.highlight-3.js"></script>
<script type="text/javascript" src="[% interface %]/lib/bootstrap/bootstrap.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.validate.min.js"></script>

[% IF ( login ) %]
    <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/login.css" />
[% END %]
[% IF ( IntranetUserCSS ) %]<style type="text/css">[% IntranetUserCSS %]</style>[% END %]

<!-- koha core js -->
<script type="text/javascript" src="[% interface %]/[% theme %]/js/staff-global.js"></script>

[% INCLUDE 'validator-strings.inc' %]
[% IF ( IntranetUserJS ) %]
    <script type="text/javascript">
    //<![CDATA[
    [% IntranetUserJS %]
    //]]>
    </script>
[% END %]

[% IF ( virtualshelves || intranetbookbag ) %]
<script type="text/javascript">
    //<![CDATA[
        var MSG_BASKET_EMPTY = _("Your cart is currently empty");
        var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
        var MSG_RECORD_ADDED = _("This item has been added to your cart");
        var MSG_NRECORDS_ADDED = _("%s item(s) added to your cart");
        var MSG_NRECORDS_IN_BASKET = _("%s already in your cart");
        var MSG_NO_RECORD_SELECTED = _("No item was selected");
        var MSG_NO_RECORD_ADDED = _("No item was added to your cart (already in your cart)!");
        var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
        var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
        var MSG_IN_YOUR_CART = _("Items in your cart: %s");
        var MSG_NON_RESERVES_SELECTED = _("One or more selected items cannot be reserved.");
        var MSG_ITEM_NOT_IN_CART = _("Add to cart");
        var MSG_ITEM_IN_CART = _("In your cart");
        var MSG_RECORD_REMOVED = _("The item has been removed from your cart");
    //]]>
    </script>

    <script type="text/javascript" src="[% interface %]/[% theme %]/js/basket.js"></script>
[% END %]

[% IF LocalCoverImages %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/localcovers.js"></script>
    <script type="text/javascript">
        //<![CDATA[
            var NO_LOCAL_JACKET = _("No cover image available");
        //]]>
    </script>
[% END %]

[% IF Koha.Preference('AudioAlerts') || AudioAlertsPage %]
    <script type="text/javascript">
        //<![CDATA[
            var AUDIO_ALERT_PATH = '[% interface %]/[% theme %]/sound/';
            var AUDIO_ALERTS = JSON.parse( '[% AudioAlerts.AudioAlerts | replace( "'", "\\'" ) | replace( '"', '\\"' ) %]' );
        //]]>

        $( document ).ready(function() {
            if ( AUDIO_ALERTS ) {
                for ( var k in AUDIO_ALERTS ) {
                    var alert = AUDIO_ALERTS[k];
                    if ( $( alert.selector ).length ) {
                        playSound( alert.sound );
                        break;
                    }
                }
            }
        });
    </script>
[% END %]
