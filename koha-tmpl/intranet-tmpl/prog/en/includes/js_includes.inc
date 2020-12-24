[% USE raw %]
[% USE Asset %]
[% USE AudioAlerts %]
[% USE To %]
[% USE Koha %]
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

[% INCLUDE 'validator-strings.inc' %]
[% IF ( IntranetUserJS ) %]
    <!-- js_includes.inc: IntranetUserJS -->
    <script>
    [% IntranetUserJS | $raw %]
    </script>
    <!-- / js_includes.inc: IntranetUserJS -->
[% END %]

<!-- js_includes.inc -->
[% IF ( Koha.Preference('virtualshelves') || Koha.Preference('intranetbookbag') ) %]
    [% Asset.js("js/basket.js") | $raw %]
[% END %]

[% IF LocalCoverImages %]
    [% Asset.js("js/localcovers.js") | $raw %]
[% END %]

[% IF Koha.Preference('AudioAlerts') || AudioAlertsPage %]
    <script>
        // AudioAlerts
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
            // PatronAutoComplete && CAN_user_circulate_circulate_remaining_permissions
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
                            cardnumber = " (" + item.cardnumber + ") ";
                        }
                        var itemString = "<a href=\"" + item.link + "\">" + ( item.surname ? item.surname.escapeHtml() : "" ) + ", " + ( item.firstname ? item.firstname.escapeHtml() : "" ) + cardnumber.escapeHtml() + " <small>";
                        if( item.dateofbirth ) {
                            itemString += ( item.dateofbirth ? item.dateofbirth.escapeHtml() : "" )
                                        + "<span class=\"age_years\"> (" + ( item.age ? item.age.escapeHtml() : "" ) + " " +  _("years") + ")</span>, ";
                        }
                        itemString += ( item.address ? item.address.escapeHtml() : "" ) + " "
                                    + ( item.city    ? item.city.escapeHtml()    : "" ) + " "
                                    + ( item.zipcode ? item.zipcode.escapeHtml() : "" ) + " "
                                    + ( item.country ? item.country.escapeHtml() : "" )
                                    + "</small></a>";
                        return $( "<li></li>" )
                        .data( "ui-autocomplete-item", item )
                        .append( itemString )
                        .appendTo( ul );
                    };
                }
            });
        </script>
    [% END %]
[% END %]
[% IF ( PatronAutoComplete ) %]
    <script>
    // PatronAutoComplete
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
                item.link = "/cgi-bin/koha/members/moremember.pl?borrowernumber=" + item.borrowernumber;
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
<!-- / js_includes.inc -->
