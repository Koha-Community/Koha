[% USE raw %]
[% USE Asset %]
[% USE AudioAlerts %]
[% USE To %]
[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <script>
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
[% Asset.js("lib/js-cookie/js.cookie-2.2.1.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.highlight-3.js") | $raw %]
[% Asset.js("lib/bootstrap/bootstrap.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.validate.min.js") | $raw %]
<!-- koha core js -->
[% Asset.js("js/staff-global.js") | $raw %]
[% Asset.js("js/commons.js") | $raw %]

[% INCLUDE 'validator-strings.inc' %]
[% IF ( IntranetUserJS ) %]
    <script>
    [% IntranetUserJS | $raw %]
    </script>
[% END %]

[% IF ( virtualshelves || intranetbookbag ) %]
    <script>
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
    </script>

    [% Asset.js("js/basket.js") | $raw %]
[% END %]

[% IF LocalCoverImages %]
    [% Asset.js("js/localcovers.js") | $raw %]
    <script>
        var NO_LOCAL_JACKET = _("No cover image available");
    </script>
[% END %]

[% IF Koha.Preference('AudioAlerts') || AudioAlertsPage %]
    <script>
        var AUDIO_ALERT_PATH = '[% interface | html %]/[% theme | html %]/sound/';
        var AUDIO_ALERTS = JSON.parse( "[% To.json(AudioAlerts.AudioAlerts) | $raw %]" );

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
    [% IF ( PatronAutoComplete ) %]
        <script>
            $(document).ready(function(){
                var obj = $( "#findborrower" ).autocomplete({
                    source: "/cgi-bin/koha/circ/ysearch.pl",
                    minLength: 3,
                    select: function( event, ui ) {
                        window.location.href = ui.item.link;
                    }
                }).data( "ui-autocomplete" );
                if( obj ) {
                    obj._renderItem = function( ul, item ) {
                        item.link = "/cgi-bin/koha/circ/circulation.pl?borrowernumber=" + item.borrowernumber;
                        var cardnumber = "";
                        if( item.cardnumber != "" ){
                            // Display card number in parentheses if it exists
                            cardnumber = " (" + ( item.cardnumber ? item.surname.escapeHtml() : "" ) + ") ";
                        }
                        return $( "<li></li>" )
                        .data( "ui-autocomplete-item", item )
                        .append( "<a href=\"" + item.link + "\">" + ( item.surname ? item.surname.escapeHtml() : "" ) + ", " + ( item.firstname ? item.firstname.escapeHtml : "" ) + ( cardnumber ? cardnumber.escapeHtml() : "" ) + " <small>" + ( item.dateofbirth ? item.dateofbirth.escapeHtml() : "" ) + " " + ( item.address ? item.address.escapeHtml() : "" ) + " " + ( item.city ? item.city.escapeHtml() : "" ) + " " + ( item.zipcode ? item.zipcode.escapeHtml() : "" ) + " " + ( item.country ? item.country.escapeHtml() : "" ) + "</small></a>" )
                        .appendTo( ul );
                    };
                }
            });
        </script>
    [% END %]
[% END %]
[% IF ( PatronAutoComplete ) %]
    <script>
    $(document).ready(function(){
        var obj = $( "#searchmember" ).autocomplete({
            source: "/cgi-bin/koha/circ/ysearch.pl",
            minLength: 3,
            select: function( event, ui ) {
                window.location.href = ui.item.link;
            }
        }).data( "ui-autocomplete" );
        if( obj ) {
            obj._renderItem = function( ul, item ) {
                item.link = "/cgi-bin/koha/circ/circulation.pl?borrowernumber=" + item.borrowernumber;
                var cardnumber = "";
                if( item.cardnumber != "" ){
                    // Display card number in parentheses if it exists
                    cardnumber = " (" + item.cardnumber + ") ";
                }
                return $( "<li></li>" )
                .data( "ui-autocomplete-item", item )
                .append(
                    "<a href=\"" + item.link + "\">" + ( item.surname ? item.surname.escapeHtml() : "" ) + ", "
                        + ( item.firstname ? item.firstname.escapeHtml() : "" )
                        + cardnumber.escapeHtml()
                        + " <small>"
                            + ( item.dateofbirth ? item.dateofbirth.escapeHtml() : "" ) + " "
                            + ( item.address     ? item.address.escapeHtml() : "" )     + " "
                            + ( item.city        ? item.city.escapeHtml() : "" )        + " "
                            + ( item.zipcode     ? item.zipcode.escapeHtml() : "" )     + " "
                            + ( item.country     ? item.country.escapeHtml() : "" )
                        + "</small>"
                    + "</a>" )
                .appendTo( ul );
            };
        }
    });
    </script>
[% END %]
