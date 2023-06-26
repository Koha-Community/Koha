[% USE raw %]
[% USE Asset %]
[% USE AudioAlerts %]
[% USE Branches %]
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

[% Asset.js("lib/jquery/jquery-3.6.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-3.3.2.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-ui-1.13.1.min.js") | $raw %]
[% Asset.js("lib/shortcut/shortcut.js") | $raw %]
[% Asset.js("lib/js-cookie/js.cookie-2.2.1.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.highlight-3.js") | $raw %]
[% Asset.js("lib/bootstrap/bootstrap.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.validate.min.js") | $raw %]
<!-- koha core js -->
[% Asset.js("js/staff-global.js") | $raw %]
[% INCLUDE 'js-date-format.inc' %]
[% INCLUDE 'js-patron-get-age.inc' %]
[% INCLUDE 'js-patron-format-address.inc' %]

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

<script>
    var defaultPatronSearchFields = "[% Koha.Preference('DefaultPatronSearchFields') || 'firstname,middle_name,surname,othernames,cardnumber,userid' | html %]";
    var defaultPatronSearchMethod = "[% Koha.Preference('DefaultPatronSearchMethod') || 'contains' | html %]";
    var loggedInLibrary = '[% Branches.GetLoggedInBranchcode | html %]';
    var singleBranchMode = '[% singleBranchMode | html %]';
</script>
[% IF ( PatronAutoComplete ) %]
    <script>
    // PatronAutoComplete
    var loggedInClass = "";
    $(document).ready(function(){
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            if ( $("#findborrower").length ) {
                patron_autocomplete($("#findborrower"), { 'link-to': 'circ' });
            }
        [% END %]
        if ( $("#searchmember").length ) {
            patron_autocomplete($("#searchmember"), { 'link-to': 'patron' });
        }
    });
    </script>
[% END %]
<!-- / js_includes.inc -->
