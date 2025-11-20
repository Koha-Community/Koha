[% USE raw %]
[% USE Koha %]
[% USE KohaPlugins %]
[% USE Asset %]
[% USE AdditionalContents %]
[% IF Koha.Preference( 'CookieConsent' ) %]
    [% SET CookieConsentBar = AdditionalContents.get( location => "CookieConsentBar", lang => lang, library => branchcode || default_branch ) %]
    [% SET CookieConsentPopup = AdditionalContents.get( location => "CookieConsentPopup", lang => lang, library => branchcode || default_branch ) %]
    [% USE JSConsents %]
[% END %]

[% IF ( ( languages_loop ) && ( ! popup_window ) && ( Koha.Preference('StaffLangSelectorMode') == 'both' || Koha.Preference('StaffLangSelectorMode') == 'footer') ) %]
    [% UNLESS ( one_language_enabled ) %]
        <div id="changelanguage" class="navbar navbar-expand navbar-light bg-light">
            <div class="container-fluid">
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav_lang_menu" aria-controls="nav_lang_menu" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="nav_lang_menu">
                    <ul id="i18nMenu" class="navbar-nav me-auto">
                        [% FOREACH languages_loo IN languages_loop %]
                            [% IF ( languages_loo.group_enabled ) %]
                                [% IF ( languages_loo.plural ) %]
                                    <li class="nav-item dropup">
                                        <a class="nav-link dropdown-toggle" id="show[% languages_loo.rfc4646_subtag | html %]" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            [% IF ( languages_loo.native_description ) %]
                                                [% languages_loo.native_description | html %]
                                            [% ELSE %]
                                                [% languages_loo.rfc4646_subtag | html %]
                                            [% END %]
                                            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                                [% IF ( sublanguages_loo.enabled ) %]
                                                    [% IF ( sublanguages_loo.sublanguage_current ) %]
                                                        <span class="sublanguage-selected">([% sublanguages_loo.rfc4646_subtag | html %])</span>
                                                    [% END %]
                                                [% END %]
                                            [% END %]
                                        </a>
                                        <ul id="sub[% languages_loo.rfc4646_subtag | html %]" class="dropdown-menu dropdown-menu-left">
                                            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                                [% IF ( sublanguages_loo.enabled ) %]
                                                    [% IF ( sublanguages_loo.sublanguage_current ) %]
                                                        <li>
                                                            <a class="nav-link currentlanguage" aria-current="page">
                                                                [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                                                [% sublanguages_loo.variant_description | html %]
                                                                ([% sublanguages_loo.rfc4646_subtag | html %])
                                                            </a>
                                                        </li>
                                                    [% ELSE %]
                                                        <li>
                                                            <a class="dropdown-item" href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]">
                                                                [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                                                [% sublanguages_loo.variant_description | html %]
                                                                ([% sublanguages_loo.rfc4646_subtag | html %])
                                                            </a>
                                                        </li>
                                                    [% END %]
                                                [% END %]
                                            [% END %]
                                        </ul>
                                    </li>
                                [% ELSE %]
                                    [% IF ( languages_loo.group_enabled ) %]
                                        [% IF ( languages_loo.current ) %]
                                            <li class="nav-item">
                                                <a class="nav-link active currentlanguage" aria-current="page" aria-disabled="true" tabindex="-1">
                                                    [% IF ( languages_loo.native_description ) %]
                                                        [% languages_loo.native_description | html %]
                                                    [% ELSE %]
                                                        [% languages_loo.rfc4646_subtag | html %]
                                                    [% END %]
                                                </a>
                                            </li>
                                        [% ELSE %]
                                            <li class="nav-item">
                                                <a class="nav-link" href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]">
                                                    [% IF ( languages_loo.native_description ) %]
                                                        [% languages_loo.native_description | html %]
                                                    [% ELSE %]
                                                        [% languages_loo.rfc4646_subtag | html %]
                                                    [% END %]
                                                </a>
                                            </li>
                                        [% END # /IF ( languages_loo.current ) %]
                                    [% END # /IF ( languages_loo.group_enabled ) %]
                                [% END # /IF ( languages_loo.plural ) %]
                            [% END # /IF ( languages_loo.group_enabled ) %]
                        [% END # /FOREACH languages_loo %]
                    </ul>
                    <!-- /#i18nMenu -->
                </div>
                <!-- /.navbar-collapse -->
            </div>
            <!-- /.container-fluid -->
        </div>
        <!-- /#changelanguage -->
    [% END # /UNLESS ( one_language_enabled ) %]
[% END # /IF ( ( languages_loop )... %]

<span id="audio-alert"></span>

<!-- Cookie consent -->
[% IF Koha.Preference( 'CookieConsent' ) %]
    <!-- Cookie consent bar -->
    <div id="cookieConsentBar" aria-hidden="true">
        [% IF ( CookieConsentBar && CookieConsentBar.content && CookieConsentBar.content.count >0 ) %]
            <div id="cookieConsentBar_content">
                [%- FOREACH item IN CookieConsentBar.content -%]
                    [%- item.content | $raw -%]
                [%- END -%]
            </div>
        [% END %]
        <div class="consentButtons">
            [% IF ( JSConsents.all('staffConsent').size ) %]
                <button type="button" class="btn btn-primary consentAcceptAll">Accept all cookies</button>
            [% END %]
            <button type="button" class="btn btn-primary consentAcceptEssential">Accept essential cookies</button>
            <button type="button" class="btn btn-default" id="consentMoreInfo">More information</button>
        </div>
    </div>
    <!-- /#cookieConsentBar -->

    <!-- Cookie consent modal -->
    <div id="cookieConsentModal" class="modal" tabindex="-1" role="dialog" aria-labelledby="cookieConsentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="cookieConsentModalLabel">Cookies policy</h1>
                </div>
                <div class="modal-body">
                    [% IF ( CookieConsentPopup && CookieConsentPopup.content && CookieConsentPopup.content.count >0 ) %]
                        <div id="cookieConsentPopupText">
                            [%- FOREACH item IN CookieConsentPopup.content -%]
                                [%- item.content | $raw -%]
                            [%- END -%]
                        </div>
                    [% END %]
                    <div id="consentCookieList">
                        [% consents = JSConsents.all('staffConsent') %]
                        [% FOREACH consent IN consents %]
                            <div class="consentModalItem">
                                <div class="consentItemCheckbox">
                                    <input class="consentCheckbox" type="checkbox" name="consentCheckbox" value="[% consent.id | html %]" aria-label="Consent to cookie" />
                                </div>
                                <div class="consentItemMeta">
                                    <div class="consentItemName">[% consent.name | html %]</div>
                                    <div class="consentItemDescription">[% consent.description | html %]</div>
                                </div>
                            </div>
                        [% END %]
                    </div>
                </div>
                <div class="modal-footer">
                    <div id="consentButtons">
                        <button type="button" class="btn btn-primary consentAcceptEssential">Accept essential cookies</button>
                        [% IF ( JSConsents.all('staffConsent').size ) %]
                            <button type="button" class="btn btn-primary consentAcceptAll">Accept all cookies</button>
                            <button type="button" class="btn btn-success" id="consentAcceptSelected">Accept selected non-essential cookies</button>
                        [% END %]
                        <button type="button" class="btn btn-secondary consentCloseModal">Cancel</button>
                    </div>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <!-- /#cookieConsentModal  -->
[% END %]
<!-- CookieConsentedJS code that may run -->
[% IF Koha.Preference( 'CookieConsent' ) && JSConsents.all('staffConsent').size %]
    [% consents = JSConsents.all('staffConsent') %]
    [% FOREACH consent IN consents %]
        <div
            class="consentCode"
            style="display:none"
            aria-hidden="true"
            data-consent-id="[% consent.id | html %]"
            data-consent-code="[% consent.code | html %]"
            data-consent-match-pattern="[% consent.matchPattern | html %]"
            data-consent-cookie-domain="[% consent.cookieDomain | html %]"
            data-consent-cookie-path="[% consent.cookiePath | html %]"
            data-requires-consent="[% consent.staffConsent ? 'true' : 'false' | html %]"
        ></div>
    [% END %]
[% END %]

[% IF Koha.debug_flag %]
    <script>
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
                    if (cssText) cssText.textContent = cssDisabled ? "Enable User CSS" : "Disable User CSS";
                }

                // User JS button
                const jsDisabled = params.get("DISABLE_SYSPREF_IntranetUserJS") === "yes" && params.get("DISABLE_SYSPREF_OPACUserJS") === "yes";
                const jsToggle = document.getElementById("toggleUserJS");
                if (jsToggle) {
                    const jsText = jsToggle.querySelector(".toggle-text");
                    if (jsText) jsText.textContent = jsDisabled ? "Enable User JS" : "Disable User JS";
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
                    if (stylesheetsText) stylesheetsText.textContent = stylesheetsDisabled ? "Enable Custom Stylesheets" : "Disable Custom Stylesheets";
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

[% IF ( footerjs ) %]
    [% INCLUDE js_includes.inc %]
    [% jsinclude | $raw # Parse the page template's JavaScript block if necessary %]
[% END %]
[% KohaPlugins.get_plugins_intranet_js | $raw %]

</body>
<!-- prettier-ignore-start -->
</html>
<!-- prettier-ignore-end -->
