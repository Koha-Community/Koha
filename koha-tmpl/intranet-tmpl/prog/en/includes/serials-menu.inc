<div id="serials-menu" class="sidebar_menu icon-collapse">
    [% INCLUDE "serials-filters.inc" %]
    <h5>Serials</h5>
    <ul>
        [% IF ( subscriptionid ) %]
            <li
                ><a href="/cgi-bin/koha/serials/serials-collection.pl?subscriptionid=[% subscriptionid | uri %]" title="Serial collection"
                    ><i class="fa-solid fa-newspaper fa-fw" aria-hidden="true"></i><span class="menu-label">Serial collection</span></a
                ></li
            >
            [% UNLESS closed %]
                [% IF ( routing && CAN_user_serials_routing ) %]
                    [% IF ( hasRouting ) %]
                        <li
                            ><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid | uri %]" title="Edit routing list"
                                ><i class="fa-solid fa-route fa-fw" aria-hidden="true"></i><span class="menu-label">Edit routing list</span></a
                            ></li
                        >
                    [% ELSE %]
                        <li
                            ><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid | uri %]&amp;op=new" title="Create routing list"
                                ><i class="fa-solid fa-route fa-fw" aria-hidden="true"></i><span class="menu-label">Create routing list</span></a
                            ></li
                        >
                    [% END %]
                [% END %]
            [% END %]
        [% END %]

        [% IF ( CAN_user_serials_claim_serials ) %]
            <li
                ><a href="/cgi-bin/koha/serials/claims.pl" title="Claims"><i class="fa-solid fa-flag fa-fw" aria-hidden="true"></i><span class="menu-label">Claims</span></a></li
            >
        [% END %]
        [% IF ( CAN_user_serials_check_expiration ) %]
            <li
                ><a href="/cgi-bin/koha/serials/checkexpiration.pl" title="Check expiration"><i class="fa-solid fa-calendar-xmark fa-fw" aria-hidden="true"></i><span class="menu-label">Check expiration</span></a></li
            >
        [% END %]
        <li>
            <a href="/cgi-bin/koha/serials/subscription-frequencies.pl" title="Manage frequencies"><i class="fa-solid fa-repeat fa-fw" aria-hidden="true"></i><span class="menu-label">Manage frequencies</span></a>
        </li>
        <li>
            <a href="/cgi-bin/koha/serials/subscription-numberpatterns.pl" title="Manage numbering patterns"><i class="fa-solid fa-list-ol fa-fw" aria-hidden="true"></i><span class="menu-label">Manage numbering patterns</span></a>
        </li>
        [% IF Koha.Preference('Mana') == 1 %]
            <li
                ><a href="/cgi-bin/koha/serials/serials-search.pl?mana=1" title="Search on Mana"><i class="fa-solid fa-magnifying-glass fa-fw" aria-hidden="true"></i><span class="menu-label">Search on Mana</span></a></li
            >
        [% END %]
        [% IF CAN_user_serials_edit_subscription && CAN_user_parameters_manage_additional_fields %]
            <li>
                <a href="/cgi-bin/koha/admin/additional-fields.pl?tablename=subscription" title="Manage subscription fields"
                    ><i class="fa-solid fa-list-check fa-fw" aria-hidden="true"></i><span class="menu-label">Manage subscription fields</span></a
                >
            </li>
        [% END %]
    </ul>

    [% IF ( CAN_user_reports ) %]
        <h5>Reports</h5>
        <ul>
            <li
                ><a href="/cgi-bin/koha/reports/serials_stats.pl" title="Serials statistics wizard"><i class="fa-solid fa-chart-column fa-fw" aria-hidden="true"></i><span class="menu-label">Serials statistics wizard</span></a></li
            >
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
