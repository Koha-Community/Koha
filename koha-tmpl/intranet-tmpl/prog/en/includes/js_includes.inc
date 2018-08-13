[% USE raw %]
[% USE Asset %]
[% USE AudioAlerts %]
[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <script type="text/javascript">
       if (self === top) {
           var antiClickjack = document.getElementById("antiClickjack");
           antiClickjack.parentNode.removeChild(antiClickjack);
       } else {
           top.location = self.location;
       }
    </script>
[% END %]

[% Asset.js("lib/jquery/jquery-2.2.3.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-1.3.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-ui-1.11.4.min.js") | $raw %]
[% Asset.js("lib/shortcut/shortcut.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.cookie.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.highlight-3.js") | $raw %]
[% Asset.js("lib/bootstrap/bootstrap.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.validate.min.js") | $raw %]
<!-- koha core js -->
[% Asset.js("js/staff-global.js") | $raw %]
[% Asset.js("js/commons.js") | $raw %]

[% INCLUDE 'validator-strings.inc' %]
[% IF ( IntranetUserJS ) %]
    <script type="text/javascript">
    //<![CDATA[
    [% IntranetUserJS | $raw %]
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

    [% Asset.js("js/basket.js") | $raw %]
[% END %]

[% IF LocalCoverImages %]
    [% Asset.js("js/localcovers.js") | $raw %]
    <script type="text/javascript">
        //<![CDATA[
            var NO_LOCAL_JACKET = _("No cover image available");
        //]]>
    </script>
[% END %]

[% IF Koha.Preference('AudioAlerts') || AudioAlertsPage %]
    <script type="text/javascript">
        //<![CDATA[
            var AUDIO_ALERT_PATH = '[% interface | html %]/[% theme | html %]/sound/';
            var AUDIO_ALERTS = JSON.parse( '[% AudioAlerts.AudioAlerts | replace( "'", "\\'" ) | replace( '"', '\\"' ) | html %]' );
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

[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    [% IF ( CircAutocompl ) %]
        <script type="text/javascript">
            $(document).ready(function(){
                var obj = $( "#findborrower" ).autocomplete({
                    source: "/cgi-bin/koha/circ/ysearch.pl",
                    minLength: 3,
                    select: function( event, ui ) {
                        $( "#findborrower" ).val( ui.item.cardnumber );
                        $("#patronsearch").submit();
                        return false;
                    }
                }).data( "ui-autocomplete" );
                if( obj ) {
                    obj._renderItem = function( ul, item ) {
                        return $( "<li></li>" )
                        .data( "ui-autocomplete-item", item )
                        .append( "<a>" + item.surname + ", " + item.firstname + " (" + item.cardnumber + ") <small>" + item.dateofbirth + " " + item.address + " " + item.city + " " + item.zipcode + " " + item.country + "</small></a>" )
                        .appendTo( ul );
                    };
                }
            });
        </script>
    [% END %]
[% END %]
