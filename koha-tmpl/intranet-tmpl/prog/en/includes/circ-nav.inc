[% USE Koha %]
[% USE Branches %]
<div id="navmenu">
    <div id="navmenulist">
        <h5>Circulation</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/circ/circulation.pl">Check out</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/returns.pl">Check in</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/renew.pl">Renew</a>
            </li>
            [% IF ( CAN_user_superlibrarian || CAN_user_loggedinlibrary ) %]
            <li>
                [% IF Koha.Preference('UseCirculationDesks') %]
                <a href="/cgi-bin/koha/circ/set-library.pl">Set library and desk</a>
                [% ELSE %]
                <a href="/cgi-bin/koha/circ/set-library.pl">Set library</a>
                [% END %]
            </li>
            [% ELSIF Koha.Preference('UseCirculationDesks') %]
            <li>
                <a href="/cgi-bin/koha/circ/set-library.pl">Set desk</a>
            </li>
            [% END %]
            [% IF ( fast_cataloging && CAN_user_editcatalogue_fast_cataloging ) %]
            <li>
                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=FA"> Fast cataloging</a>
            </li>
            [% END %]
            [% IF ( Koha.Preference('AllowCheckoutNotes') && CAN_user_circulate_manage_checkout_notes ) %]
            <li>
                <a href="/cgi-bin/koha/circ/checkout-notes.pl">Checkout notes</a>
            </li>
            [% END %]
            [% IF Koha.Preference('OnSiteCheckouts') %]
            <li>
                <a href="/cgi-bin/koha/circ/on-site_checkouts.pl">Pending on-site checkouts</a>
            </li>
            [% END %]
        </ul>

        <h5>Holds</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/circ/view_holdsqueue.pl">Holds queue</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/pendingreserves.pl">Holds to pull</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/waitingreserves.pl">Holds awaiting pickup</a>
            </li>
            [% IF ( Koha.Preference('CurbsidePickup') && CAN_user_circulate_manage_curbside_pickups ) %]
            <li>
                <a href="/cgi-bin/koha/circ/curbside_pickups.pl">Curbside pickups</a>
            </li>
            [% END %]
            <li>
                <a href="/cgi-bin/koha/circ/reserveratios.pl">Hold ratios</a>
            </li>
        </ul>

        [% IF Koha.Preference('UseRecalls') and CAN_user_recalls %]
        <h5>Recalls</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_queue.pl" title="All active recalls">Recalls queue</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_to_pull.pl" title="Recalls that could be filled but have not been set waiting">Recalls to pull</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_overdue.pl" title="Recalled items that are overdue to be returned">Overdue recalls</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_waiting.pl" title="Recalled items awaiting pickup">Recalls awaiting pickup</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/recalls/recalls_old_queue.pl" title="Inactive recalls">Old recalls</a>
            </li>
        </ul>
        [% END %]

        [% IF Koha.Preference('ArticleRequests') %]
        <h5>Patron request</h5>
        <ul>
            <li>
                <a href="/cgi-bin/koha/circ/article-requests.pl">Article requests</a>
            </li>
        </ul>
        [% END %]

        <h5>Transfers</h5>
        <ul>
        [% IF !Koha.Preference('IndependentBranchesTransfers') || CAN_user_superlibrarian %]
            <li>
                <a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfer</a>
            </li>
        [% END %]
             <li>
                <a href="/cgi-bin/koha/circ/transfers_to_send.pl">Transfers to send</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/circ/transferstoreceive.pl">Transfers to receive</a>
            </li>
        </ul>

        <h5>Overdues</h5>
        <ul>
            [% IF ( CAN_user_circulate_overdues_report ) %]
            <li>
                <a href="/cgi-bin/koha/circ/overdue.pl" title="Warning: This report is very resource intensive on systems with large numbers of overdue items.">Overdues</a>
            </li>
            [% END %]
            <li>
                <a href="/cgi-bin/koha/circ/branchoverdues.pl" title="Limited to your library. See report help for other details.">Overdues with fines</a>
             </li>
        </ul>
    </div>
</div>
