<div id="navmenu">
    <div id="navmenulist">
        <ul>
        [% IF ( subscriptionid ) %]
                <li><a href="serials-collection.pl?subscriptionid=[% subscriptionid | uri %]">Serial collection</a></li>
                [% UNLESS closed %]
                    [% IF ( routing && CAN_user_serials_routing ) %]
                        [% IF ( hasRouting ) %]
                            <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid | uri %]">Edit routing list</a></li>
                        [% ELSE %]
                            <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid | uri %]&amp;op=new">Create routing list</a></li>
                        [% END %]
                    [% END %]
                [% END %]
        [% END %]

            [% IF ( CAN_user_serials_claim_serials ) %]
                <li><a href="/cgi-bin/koha/serials/claims.pl">Claims</a></li>
            [% END %]
            [% IF ( CAN_user_serials_check_expiration ) %]
                <li><a href="/cgi-bin/koha/serials/checkexpiration.pl">Check expiration</a></li>
            [% END %]
            <li>
                <a href="/cgi-bin/koha/serials/subscription-frequencies.pl">
                    Manage frequencies
                </a>
            </li>
            <li>
                <a href="/cgi-bin/koha/serials/subscription-numberpatterns.pl">
                    Manage numbering patterns
                </a>
            </li>
            [% IF Koha.Preference('Mana') == 1 %]
                <li><a href="/cgi-bin/koha/serials/serials-search.pl?mana=1">Search on Mana</a></li>
            [% END %]
        </ul>
    </div>
</div>
