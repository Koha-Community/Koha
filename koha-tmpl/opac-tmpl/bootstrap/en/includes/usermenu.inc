[% USE Koha %]
[% IF ( ( Koha.Preference( 'opacuserlogin' ) == 1 ) && loggedinusername ) %]
    <div id="menu">
        <ul>
            [% IF ( userview ) %]
                <li class="active">
            [% ELSE %]
                <li>
            [% END %]
                <a href="/cgi-bin/koha/opac-user.pl">Summary</a></li>
            [% IF ( OPACFinesTab ) %]
                [% IF ( accountview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-account.pl">Charges</a></li>
            [% END %]

            [% IF ( userupdateview ) %]
                <li class="active">
            [% ELSE %]
                <li>
            [% END %]
                <a href="/cgi-bin/koha/opac-memberentry.pl">Personal details</a></li>

            [% IF Koha.Preference('PrivacyPolicyConsent') || Koha.Preference('CookieConsent') # remove when extending %]
                [% IF consentview %]<li class="active">[% ELSE %]<li>[% END %]
                    <a href="/cgi-bin/koha/opac-patron-consent.pl">Consents</a>
                </li>
            [% END %]

            [% IF Koha.Preference( 'TagsEnabled' ) == 1 %]
                [% IF ( tagsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-tags.pl?mine=1">Tags</a></li>
            [% END %]

            [% IF logged_in_user.category.effective_change_password %]
                [% IF ( passwdview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-passwd.pl">Change password</a></li>
            [% END %]

            [% IF EnableOpacSearchHistory %]
                [% IF ( searchhistoryview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-search-history.pl">Search history</a></li>
            [% END %]

            [% IF ( opacreadinghistory ) %]
                [% IF ( readingrecview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-readingrecord.pl">Checkout history</a></li>
                [% IF ( OPACPrivacy ) %]
                    [% IF ( privacyview ) %]
                        <li class="active">
                    [% ELSE %]
                        <li>
                    [% END %]
                    <a href="/cgi-bin/koha/opac-privacy.pl">Privacy</a></li>
                [% END %]
            [% END # / opacreadinghistory %]

            [% IF Koha.Preference('OPACHoldsHistory') == 1 %]
                [% IF ( holdshistoryview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-holdshistory.pl">Holds history</a></li>
            [% END %]

            [% IF Koha.Preference('UseRecalls') %]
                [% IF ( recallsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-recalls.pl">Recalls history</a>
            [% END %]

            [% IF ( suggestion ) %]
                [% IF ( suggestionsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a></li>
            [% END %]

            [% IF ( EnhancedMessagingPreferences ) %]
                [% IF Koha.Preference( 'EnhancedMessagingPreferencesOPAC' ) || Koha.Preference('TranslateNotices') %]
                    [% IF ( messagingview ) %]
                        <li class="active">
                    [% ELSE %]
                        <li>
                    [% END %]
                    <a href="/cgi-bin/koha/opac-messaging.pl">Messaging</a></li>
                 [% END %]
            [% END %]

            [% IF Koha.Preference( 'virtualshelves' ) == 1 %]
                [% IF ( listsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-shelves.pl?op=list">Lists</a></li>
            [% END %]

            [% IF Koha.Preference( 'RoutingSerials' ) && logged_in_user && logged_in_user.get_routing_lists.count %]
                [% IF ( routinglistsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-routing-lists.pl">Routing lists</a></li>
            [% END %]

            [% IF Koha.Preference( 'useDischarge' ) == 1 %]
                [% IF ( dischargeview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-discharge.pl">Ask for discharge</a></li>
            [% END %]

            [% IF Koha.Preference( 'ILLModule' ) == 1 %]
                [% IF ( illrequestsview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-illrequests.pl">Interlibrary loan requests</a></li>
            [% END %]

            [% IF Koha.Preference( 'CurbsidePickup' ) %]
                [% IF ( ermview ) %]
                    <li class="active">
                [% ELSE %]
                    <li>
                [% END %]
                <a href="/cgi-bin/koha/opac-curbside-pickups.pl">Curbside pickups</a></li>
            [% END %]

        </ul>
    </div>
[% END %]
