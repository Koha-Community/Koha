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
        </div>
[% IF ( ( languages_loop ) && ( ! popup_window ) && ( Koha.Preference('StaffLangSelectorMode') == 'both' || Koha.Preference('StaffLangSelectorMode') == 'footer') ) %]
    [% UNLESS ( one_language_enabled ) %]
        <div id="changelanguage" class="navbar navbar-default navbar-fixed-bottom">
            <div class="container-fluid">
        <ul id="i18nMenu" class="nav navbar-nav">
        [% FOREACH languages_loo IN languages_loop %]

            [% IF ( languages_loo.group_enabled ) %]
            [% IF ( languages_loo.plural ) %]
                <li class="dropdown"><a class="dropdown-toggle dropup" data-toggle="dropdown" id="show[% languages_loo.rfc4646_subtag | html %]" href="#">
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
                <span class="caret"></span></a>
            <ul id="sub[% languages_loo.rfc4646_subtag | html %]" class="dropdown-menu dropdown-menu-left">
            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
        [% IF ( sublanguages_loo.enabled ) %]
                [% IF ( sublanguages_loo.sublanguage_current ) %]
                    <li class="navbar-text"> <span class="currentlanguage disabled">[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</span></li>
                [% ELSE %]
                <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]"> [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</a></li>
        [% END %]
                [% END %]

            [% END %]
            </ul></li>

            [% ELSE %]
            [% IF ( languages_loo.group_enabled ) %]
                [% IF ( languages_loo.current ) %]
                    <li class="navbar-text">
                        [% IF ( languages_loo.native_description ) %]
                            <span class="currentlanguage">[% languages_loo.native_description | html %]</span>
                        [% ELSE %]
                            <span class="currentlanguage">[% languages_loo.rfc4646_subtag | html %]</span>
                        [% END %]
                    </li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]">
                        [% IF ( languages_loo.native_description ) %]
                            [% languages_loo.native_description | html %]
                        [% ELSE %]
                            [% languages_loo.rfc4646_subtag | html %]
                        [% END %]
                    </a></li>
                [% END %]
        [% END %]
            [% END %]
            [% END %]

        [% END %]
        </ul>
        </div>
        </div>
    [% END %]
[% END %]
    <span id="audio-alert"></span>
    [% IF ( footerjs ) %]
        [% INCLUDE js_includes.inc %]
        [% jsinclude | $raw # Parse the page template's JavaScript block if necessary %]
    [% END %]
[% KohaPlugins.get_plugins_intranet_js | $raw %]

    <!-- Cookie consent -->
    [% IF Koha.Preference( 'CookieConsent' ) %]
        <!-- Cookie consent bar -->
        <div id="cookieConsentBar" aria-hidden="true">
            [% IF ( CookieConsentBar && CookieConsentBar.content && CookieConsentBar.content.count >0 ) %]
                <div id="cookieConsentBarText">
                    [%- FOREACH item IN CookieConsentBar.content -%]
                        [%- item.content | $raw -%]
                    [%- END -%]
                </div>
            [% END %]
            <div id="consentButtons">
                <button type="button" class="btn btn-primary consentAcceptAll">Accept all cookies</button>
                [% IF ( JSConsents.all('staffConsent').size ) %]
                    <button type="button" class="btn btn-primary consentAcceptEssential">Accept only essential cookies</button>
                    <button type="button" class="btn btn-info" id="consentMoreInfo">More information</button>
                [% END %]
            </div>
        </div> <!-- /#cookieConsentBar -->
        <!-- Cookie consent modal -->
        <div id="cookieConsentModal" class="modal" tabindex="-1" role="dialog" aria-labelledby="cookieConsentModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title" id="cookieConsentModalLabel">Cookie consent</h2>
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
                                        <input class="consentCheckbox" type="checkbox" name="consentCheckbox" value="[% consent.id | html %]" aria-label="Consent to cookie">
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
                            <button type="button" class="btn btn-primary consentAcceptAll">Accept all cookies</button>
                            [% IF ( JSConsents.all('staffConsent').size ) %]
                                <button type="button" class="btn btn-primary consentAcceptEssential">Accept only essential cookies</button>
                                <button type="button" class="btn btn-success" id="consentAcceptSelected">Accept selected non-essential cookies</button>
                            [% END %]
                            <a type="button" href="#" class="btn btn-secondary consentCloseModal">Cancel</a>
                        </div>
                    </div>
                </div> <!-- /.modal-content -->
            </div> <!-- /.modal-dialog -->
        </div>  <!-- /#cookieConsentModal  -->
    [% END %]
    <!-- CookieConsentedJS code that may run -->
    [% IF Koha.Preference( 'CookieConsent' ) && JSConsents.all('staffConsent').size %]
        [% consents = JSConsents.all('staffConsent') %]
        [% FOREACH consent IN consents %]
            <div class="consentCode" style="display:none" aria-hidden="true" data-consent-id="[% consent.id | html %]" data-consent-code="[% consent.code | html %]" data-consent-match-pattern="[% consent.matchPattern | html %]" data-consent-cookie-domain="[% consent.cookieDomain | html %]" data-consent-cookie-path="[% consent.cookiePath | html %]" data-requires-consent="[% consent.staffConsent ? 'true' : 'false' | html %]"></div>
        [% END %]
    [% END %]
    [% IF Koha.Preference( 'CookieConsent' ) %]
        [% Asset.js("js/cookieconsent.js") | $raw %]
    [% END %]

</body>
</html>
