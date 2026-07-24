[% USE raw %]
[% USE Asset %]
[% USE AudioAlerts %]
[% USE Branches %]
[% USE To %]
[% USE Koha %]
[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <script nonce="[% Koha.CSPNonce | $raw %]">
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
[% Asset.js("lib/jquery/jquery-ui-1.13.2.min.js") | $raw %]
[% Asset.js("lib/shortcut/shortcut.js") | $raw %]
[% Asset.js("lib/js-cookie/js.cookie-2.2.1.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.highlight-5.js") | $raw %]
[% Asset.js("lib/bootstrap/bootstrap.bundle.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.validate.min.js") | $raw %]
<!-- koha core js -->
[% Asset.js("js/patron-format.js") | $raw %]
[% Asset.js("js/sidebar.js") | $raw %]
[% Asset.js("js/staff-global.js") | $raw %]
[% Asset.js("js/form-submit.js",{'type' => 'module'}) | $raw %]
[% INCLUDE 'js-date-format.inc' %]
[% INCLUDE 'js-patron-get-age.inc' %]
[% INCLUDE 'js-patron-format-address.inc' %]

[% INCLUDE 'validator-strings.inc' %]
[% IF ( IntranetUserJS ) %]
    <!-- js_includes.inc: IntranetUserJS -->
    <script nonce="[% Koha.CSPNonce | $raw %]">
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
    <script nonce="[% Koha.CSPNonce | $raw %]">
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
<script nonce="[% Koha.CSPNonce | $raw %]">
    var defaultPatronSearchFields = "[% Koha.Preference('DefaultPatronSearchFields') || 'firstname|preferred_name|middle_name|surname|othernames|cardnumber|userid' | html %]";
    var defaultPatronSearchMethod = "[% Koha.Preference('DefaultPatronSearchMethod') || 'contains' | html %]";
    var extendedPatronAttributes = "[% Koha.Preference('ExtendedPatronAttributes') | html %]";
    var loggedInLibrary = '[% Branches.GetLoggedInBranchcode | html %]';
    var singleBranchMode = '[% singleBranchMode | html %]';
    var showPatronFirstnameIfDifferentThanPreferredname = [% Koha.Preference('ShowPatronFirstnameIfDifferentThanPreferredname') ? 1 : 0 | html %];
</script>
[% IF ( PatronAutoComplete ) %]
    <script nonce="[% Koha.CSPNonce | $raw %]">
        // PatronAutoComplete
        var loggedInClass = "";
        $(document).ready(function(){
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                if ( $("#findborrower").length ) {
                    patron_autocomplete($("#findborrower"), { 'link-to': 'circ' });
                }
                if ( $("#findborrower_main").length ) {
                    patron_autocomplete($("#findborrower_main"), { 'link-to': 'circ' });
                }
            [% END %]
            if ( $("#searchmember").length ) {
                patron_autocomplete($("#searchmember"), { 'link-to': 'patron' });
            }
        });
    </script>
[% END %]

[% IF ( CAN_user_parameters_manage_sysprefs ) %]
    <script nonce="[% Koha.CSPNonce | $raw %]">
        $(document).ready(function () {
            if ($("#syspref_searchfield").length) {
                syspref_autocomplete($("#syspref_searchfield"));
            }
        });
    </script>
[% END %]

[% IF Koha.Preference( 'CookieConsent' ) %]
    [% Asset.js("js/cookieconsent.js") | $raw %]
[% END %]

[% IF Koha.debug_flag %]
    <script nonce="[% Koha.CSPNonce | $raw %]">
        (function () {
            function getURLParams() {
                const params = new URLSearchParams(window.location.search);
                return params;
            }

            function toggleURLParams(paramsToToggle) {
                const url = new URL(window.location.href);
                const params = url.searchParams;

                // Check if all params are currently set
                const allSet = paramsToToggle.every(param => params.get(param) === "yes");

                if (allSet) {
                    // Remove all params
                    paramsToToggle.forEach(param => params.delete(param));
                } else {
                    // Add all params
                    paramsToToggle.forEach(param => params.set(param, "yes"));
                }

                window.location.href = url.toString();
            }

            function updateButtonText() {
                const params = getURLParams();

                // User CSS button
                const cssDisabled = params.get("DISABLE_SYSPREF_IntranetUserCSS") === "yes" && params.get("DISABLE_SYSPREF_OPACUserCSS") === "yes";
                const cssToggle = document.getElementById("toggleUserCSS");
                if (cssToggle) {
                    const cssText = cssToggle.querySelector(".toggle-text");
                    if (cssText) cssText.textContent = cssDisabled ? _("Enable custom CSS") : _("Disable custom CSS");
                }

                // User JS button
                const jsDisabled = params.get("DISABLE_SYSPREF_IntranetUserJS") === "yes" && params.get("DISABLE_SYSPREF_OPACUserJS") === "yes";
                const jsToggle = document.getElementById("toggleUserJS");
                if (jsToggle) {
                    const jsText = jsToggle.querySelector(".toggle-text");
                    if (jsText) jsText.textContent = jsDisabled ? _("Enable custom JS") : _("Disable custom JS");
                }

                // Stylesheets button
                const stylesheetsDisabled =
                    params.get("DISABLE_SYSPREF_OpacAdditionalStylesheet") === "yes" &&
                    params.get("DISABLE_SYSPREF_opaclayoutstylesheet") === "yes" &&
                    params.get("DISABLE_SYSPREF_intranetcolorstylesheet") === "yes" &&
                    params.get("DISABLE_SYSPREF_intranetstylesheet") === "yes";
                const stylesheetsToggle = document.getElementById("toggleStylesheets");
                if (stylesheetsToggle) {
                    const stylesheetsText = stylesheetsToggle.querySelector(".toggle-text");
                    if (stylesheetsText) stylesheetsText.textContent = stylesheetsDisabled ? _("Enable custom stylesheets") : _("Disable custom stylesheets");
                }

                // Update icon color based on whether any toggles are active
                const anyDisabled = cssDisabled || jsDisabled || stylesheetsDisabled;
                const debugIcon = document.getElementById("debug-icon");
                if (debugIcon) {
                    if (anyDisabled) {
                        debugIcon.style.color = "#ffc107"; // Warning/amber color
                    } else {
                        debugIcon.style.color = ""; // Default color
                    }
                }
            }

            // Update button text on page load
            updateButtonText();

            // User CSS toggle
            const cssToggle = document.getElementById("toggleUserCSS");
            if (cssToggle) {
                cssToggle.addEventListener("click", function (e) {
                    e.preventDefault();
                    toggleURLParams(["DISABLE_SYSPREF_IntranetUserCSS", "DISABLE_SYSPREF_OPACUserCSS"]);
                });
            }

            // User JS toggle
            const jsToggle = document.getElementById("toggleUserJS");
            if (jsToggle) {
                jsToggle.addEventListener("click", function (e) {
                    e.preventDefault();
                    toggleURLParams(["DISABLE_SYSPREF_IntranetUserJS", "DISABLE_SYSPREF_OPACUserJS"]);
                });
            }

            // Stylesheets toggle
            const stylesheetsToggle = document.getElementById("toggleStylesheets");
            if (stylesheetsToggle) {
                stylesheetsToggle.addEventListener("click", function (e) {
                    e.preventDefault();
                    toggleURLParams(["DISABLE_SYSPREF_OpacAdditionalStylesheet", "DISABLE_SYSPREF_opaclayoutstylesheet", "DISABLE_SYSPREF_intranetcolorstylesheet", "DISABLE_SYSPREF_intranetstylesheet"]);
                });
            }
        })();
    </script>
[% END # IF %]
<!-- / js_includes.inc -->
