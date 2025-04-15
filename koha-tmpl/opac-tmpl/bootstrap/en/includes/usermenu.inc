[% USE Koha %]
[% USE KohaPlugins %]
[% IF ( ( Koha.Preference( 'opacuserlogin' ) == 1 ) && loggedinusername ) %]
    <div id="menu">
        <ul>
            <li [% IF userview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-user.pl">Summary</a></li>

            [% IF Koha.Preference( 'OPACVirtualCard' ) %]
                <li [% IF virtualcardview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-virtual-card.pl">Library card</a></li>
            [% END %]

            [% IF ( OPACFinesTab ) %]
                <li [% IF accountview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-account.pl">Charges</a></li>
            [% END %]

            <li [% IF userupdateview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-memberentry.pl">Personal details</a></li>

            [% IF Koha.Preference('PrivacyPolicyConsent') || KohaPlugins.feature_enabled('patron_consent_type') %]
                <li [% IF consentview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/opac-patron-consent.pl">Consents</a>
                </li>
            [% END %]

            [% IF Koha.Preference( 'TagsEnabled' ) == 1 %]
                <li [% IF tagsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-tags.pl?mine=1">Tags</a></li>
            [% END %]

            [% IF logged_in_user.category.effective_change_password %]
                <li [% IF passwdview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-passwd.pl">Change password</a></li>
            [% END %]

            [% IF EnableOpacSearchHistory %]
                <li [% IF searchhistoryview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-search-history.pl">Search history</a></li>
            [% END %]

            [% IF ( opacreadinghistory ) %]
                <li [% IF readingrecview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-readingrecord.pl">Checkout history</a></li>
                [% IF ( OPACPrivacy ) %]
                    <li [% IF privacyview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-privacy.pl">Privacy</a></li>
                [% END %]
            [% END # / opacreadinghistory %]

            [% IF Koha.Preference('OPACHoldsHistory') == 1 %]
                <li [% IF holdshistoryview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-holdshistory.pl">Holds history</a></li>
            [% END %]

            [% IF Koha.Preference('UseRecalls') %]
                <li [% IF recallsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-recalls.pl">Recalls history</a> </li>
            [% END %]

            [% IF ( suggestion ) %]
                <li [% IF suggestionsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a></li>
            [% END %]

            [% IF ( EnhancedMessagingPreferences ) %]
                [% IF Koha.Preference( 'EnhancedMessagingPreferencesOPAC' ) || Koha.Preference('TranslateNotices') %]
                    <li [% IF messagingview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-messaging.pl">Messaging</a></li>
                [% END %]
            [% END %]

            [% IF Koha.Preference( 'virtualshelves' ) == 1 %]
                <li [% IF listsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-shelves.pl?op=list">Lists</a></li>
            [% END %]

            [% IF Koha.Preference( 'RoutingSerials' ) && logged_in_user && logged_in_user.get_routing_lists.count %]
                <li [% IF routinglistsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-routing-lists.pl">Routing lists</a></li>
            [% END %]

            [% IF Koha.Preference( 'useDischarge' ) == 1 %]
                <li [% IF dischargeview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-discharge.pl">Ask for discharge</a></li>
            [% END %]

            [% IF Koha.Preference( 'ILLModule' ) == 1 %]
                <li [% IF illrequestsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-illrequests.pl">Interlibrary loan requests</a></li>
            [% END %]

            [% IF Koha.Preference( 'CurbsidePickup' ) %]
                <li [% IF curbside_pickups_view %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-curbside-pickups.pl">Curbside pickups</a></li>
            [% END %]

            [% IF logged_in_user.alert_subscriptions.count %]
                <li [% IF alertsview %]class="active"[% END %]> <a href="/cgi-bin/koha/opac-alert-subscriptions.pl">Alert subscriptions ([% logged_in_user.alert_subscriptions.count | html %])</a></li>
            [% END %]
        </ul>
    </div>
[% END %]
