<!-- circ-nav.inc -->
[% USE Koha %]
[% USE Branches %]
<div class="circ-nav-menu sidebar_menu icon-collapse">
    <h5>Circulation</h5>
    <ul>
        <li>
            <a href="/cgi-bin/koha/circ/circulation.pl" title="Check out"><i class="fa-solid fa-right-from-bracket fa-fw" aria-hidden="true"></i><span class="menu-label">Check out</span></a>
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/checkin.pl" title="Check in"><i class="fa-solid fa-right-to-bracket fa-fw" aria-hidden="true"></i><span class="menu-label">Check in</span></a>
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/renew.pl" title="Renew"><i class="fa-solid fa-arrows-rotate fa-fw" aria-hidden="true"></i><span class="menu-label">Renew</span></a>
        </li>
        [% IF ( CAN_user_superlibrarian || CAN_user_loggedinlibrary ) %]
            <li>
                [% IF Koha.Preference('UseCirculationDesks') %]
                    <a href="/cgi-bin/koha/circ/set-library.pl" title="Set library and desk"><i class="fa-solid fa-building fa-fw" aria-hidden="true"></i><span class="menu-label">Set library and desk</span></a>
                [% ELSE %]
                    <a href="/cgi-bin/koha/circ/set-library.pl" title="Set library"><i class="fa-solid fa-building fa-fw" aria-hidden="true"></i><span class="menu-label">Set library</span></a>
                [% END %]
            </li>
        [% ELSIF Koha.Preference('UseCirculationDesks') %]
            <li>
                <a href="/cgi-bin/koha/circ/set-library.pl" title="Set desk"><i class="fa-solid fa-building fa-fw" aria-hidden="true"></i><span class="menu-label">Set desk</span></a>
            </li>
        [% END %]
        [% IF ( fast_cataloging && CAN_user_editcatalogue_fast_cataloging ) %]
            <li>
                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=FA" title="Fast cataloging"><i class="fa-solid fa-bolt fa-fw" aria-hidden="true"></i><span class="menu-label">Fast cataloging</span></a>
            </li>
        [% END %]
        [% IF ( Koha.Preference('AllowCheckoutNotes') && CAN_user_circulate_manage_checkout_notes ) %]
            <li>
                <a href="/cgi-bin/koha/circ/checkout-notes.pl" title="Checkout notes"><i class="fa-solid fa-note-sticky fa-fw" aria-hidden="true"></i><span class="menu-label">Checkout notes</span></a>
            </li>
        [% END %]
        [% IF Koha.Preference('OnSiteCheckouts') %]
            <li>
                <a href="/cgi-bin/koha/circ/on-site_checkouts.pl" title="Pending on-site checkouts"><i class="fa-solid fa-desktop fa-fw" aria-hidden="true"></i><span class="menu-label">Pending on-site checkouts</span></a>
            </li>
        [% END %]
    </ul>

    <h5>Holds</h5>
    <ul>
        <li>
            [% IF Koha.Preference('UseHoldsQueueFilterOptions') %]
                <a href="/cgi-bin/koha/circ/holds_queue.pl?branchlimit=[% Branches.GetLoggedInBranchcode | uri %]" title="Holds queue"
                    ><i class="fa-solid fa-list-check fa-fw" aria-hidden="true"></i><span class="menu-label">Holds queue</span></a
                >
            [% ELSE %]
                <a href="/cgi-bin/koha/circ/holds_queue.pl?branchlimit=[% Branches.GetLoggedInBranchcode | uri %]&run_report=1" title="Holds queue"
                    ><i class="fa-solid fa-list-check fa-fw" aria-hidden="true"></i><span class="menu-label">Holds queue</span></a
                >
            [% END %]
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/pendingreserves.pl" title="Holds to pull"><i class="fa-solid fa-hand fa-fw" aria-hidden="true"></i><span class="menu-label">Holds to pull</span></a>
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/waitingreserves.pl" title="Holds awaiting pickup"><i class="fa-solid fa-box-open fa-fw" aria-hidden="true"></i><span class="menu-label">Holds awaiting pickup</span></a>
        </li>
        [% IF ( Koha.Preference('CurbsidePickup') && CAN_user_circulate_manage_curbside_pickups ) %]
            <li>
                <a href="/cgi-bin/koha/circ/curbside_pickups.pl" title="Curbside pickups"><i class="fa-solid fa-car fa-fw" aria-hidden="true"></i><span class="menu-label">Curbside pickups</span></a>
            </li>
        [% END %]
        <li>
            <a href="/cgi-bin/koha/circ/reserveratios.pl" title="Hold ratios"><i class="fa-solid fa-scale-balanced fa-fw" aria-hidden="true"></i><span class="menu-label">Hold ratios</span></a>
        </li>
    </ul>

    [% IF Koha.Preference('UseRecalls') != "off" and CAN_user_recalls %]
        <h5>Recalls</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_queue.pl" title="All active recalls"><i class="fa-solid fa-list-check fa-fw" aria-hidden="true"></i><span class="menu-label">Recalls queue</span></a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_to_pull.pl" title="Recalls that could be filled but have not been set waiting"
                    ><i class="fa-solid fa-hand fa-fw" aria-hidden="true"></i><span class="menu-label">Recalls to pull</span></a
                >
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_overdue.pl" title="Recalled items that are overdue to be returned"><i class="fa-solid fa-clock fa-fw" aria-hidden="true"></i><span class="menu-label">Overdue recalls</span></a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_waiting.pl" title="Recalled items awaiting pickup"><i class="fa-solid fa-box-open fa-fw" aria-hidden="true"></i><span class="menu-label">Recalls awaiting pickup</span></a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_old_queue.pl" title="Inactive recalls"><i class="fa-solid fa-box-archive fa-fw" aria-hidden="true"></i><span class="menu-label">Old recalls</span></a>
            </li>
        </ul>
    [% END %]

    [% IF Koha.Preference('ArticleRequests') %]
        <h5>Patron request</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/circ/article-requests.pl" title="Article requests"><i class="fa-solid fa-file-lines fa-fw" aria-hidden="true"></i><span class="menu-label">Article requests</span></a>
            </li>
        </ul>
    [% END %]

    <h5>Transfers</h5>
    <ul>
        [% IF !Koha.Preference('IndependentBranchesTransfers') || CAN_user_superlibrarian %]
            <li>
                <a href="/cgi-bin/koha/circ/branchtransfers.pl" title="Transfer"><i class="fa-solid fa-truck fa-fw" aria-hidden="true"></i><span class="menu-label">Transfer</span></a>
            </li>
        [% END %]
        [% IF Koha.Preference('StockRotation') %]
            <li>
                <a href="/cgi-bin/koha/circ/transfers_to_send.pl" title="Transfers to send"><i class="fa-solid fa-paper-plane fa-fw" aria-hidden="true"></i><span class="menu-label">Transfers to send</span></a>
            </li>
        [% END %]
        <li>
            <a href="/cgi-bin/koha/circ/transferstoreceive.pl" title="Transfers to receive"><i class="fa-solid fa-inbox fa-fw" aria-hidden="true"></i><span class="menu-label">Transfers to receive</span></a>
        </li>
    </ul>

    [% IF ( CAN_user_circulate_overdues_report ) %]
        <h5>Overdues</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/circ/overdue.pl" title="Warning: This report is very resource intensive on systems with large numbers of overdue items."
                    ><i class="fa-solid fa-triangle-exclamation fa-fw" aria-hidden="true"></i><span class="menu-label">Overdues</span></a
                >
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/branchoverdues.pl" title="Limited to your library. See report help for other details."
                    ><i class="fa-solid fa-money-bill-wave fa-fw" aria-hidden="true"></i><span class="menu-label">Overdues with fines</span></a
                >
            </li>
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
