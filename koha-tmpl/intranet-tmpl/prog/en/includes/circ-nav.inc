[% USE Koha %]
[% USE Branches %]
<div id="navmenu">
    <div id="navmenulist">

        <ul>
            <li><a href="/cgi-bin/koha/circ/circulation-home.pl">Circulation home</a></li>
        </ul>

        <h5>Circulation</h5>
        <ul>
            <li><a href="/cgi-bin/koha/circ/circulation.pl">Check out</a></li>
            <li><a href="/cgi-bin/koha/circ/returns.pl">Check in</a></li>
            <li><a href="/cgi-bin/koha/circ/renew.pl">Renew</a></li>
            [% IF !Koha.Preference('IndependentBranchesTransfers') || CAN_user_superlibrarian %]
                <li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfer</a></li>
            [% END %]
            [% IF !( Koha.Preference('IndependentBranches') && !CAN_user_superlibrarian && !CAN_user_editcatalogue_edit_catalogue ) %]
                [% IF Koha.Preference('UseCirculationDesks') %]
                <li><a href="/cgi-bin/koha/circ/set-library.pl">Set library and desk</a></li>
                [% ELSE %]
                <li><a href="/cgi-bin/koha/circ/set-library.pl">Set library</a></li>
                [% END %]
            [% ELSIF Koha.Preference('UseCirculationDesks') %]
                <li><a href="/cgi-bin/koha/circ/set-library.pl">Set desk</a></li>
            [% END %]
            [% IF ( fast_cataloging ) %][% IF ( CAN_user_editcatalogue_fast_cataloging ) %]
                <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=FA">Fast cataloging</a></li>
            [% END %][% END %]
            [% IF Koha.Preference('AllowCheckoutNotes') && CAN_user_circulate_manage_checkout_notes %]
                <li><a href="/cgi-bin/koha/circ/checkout-notes.pl">Checkout notes</a> [% IF pending_checkout_notes.count %]<span class="number_box"><a href="/cgi-bin/koha/circ/checkout-notes.pl">[% pending_checkout_notes.count | html %]</a></span>[% END %]</li>
            [% END %]
        </ul>

        [% IF Koha.Preference('ArticleRequests') %]
        <h5>Patron request</h5>
        <ul>
            <li><a href="/cgi-bin/koha/circ/article-requests.pl">Article requests</a></li>
        </ul>
        [% END %]

        <h5>Circulation reports</h5>
        <ul>
            <li><a href="/cgi-bin/koha/circ/view_holdsqueue.pl">Holds queue</a></li>
            <li><a href="/cgi-bin/koha/circ/pendingreserves.pl">Holds to pull</a></li>
            <li><a href="/cgi-bin/koha/circ/waitingreserves.pl">Holds awaiting pickup</a></li>
            [% IF ( Koha.Preference('CurbsidePickup') && CAN_user_circulate_manage_curbside_pickups ) %]
                <li><a href="/cgi-bin/koha/circ/curbside_pickups.pl">Curbside pickups</a></li>
            [% END %]
            <li><a href="/cgi-bin/koha/circ/reserveratios.pl">Hold ratios</a></li>
            <li><a href="/cgi-bin/koha/circ/transferstoreceive.pl">Transfers to receive</a></li>
            [% IF ( CAN_user_circulate_overdues_report ) %]
                <li><a href="/cgi-bin/koha/circ/overdue.pl">Overdues</a></li>
            [% END %]
            <li><a href="/cgi-bin/koha/circ/branchoverdues.pl">Overdues with fines</a></li>
            [% IF Koha.Preference('OnSiteCheckouts') %]
                <li><a href="/cgi-bin/koha/circ/on-site_checkouts.pl">Pending on-site checkouts</a></li>
            [% END %]

            [% IF Koha.Preference('UseRecalls') and CAN_user_recalls %]
                <li><a href="/cgi-bin/koha/recalls/recalls_queue.pl" title="All active recalls">Recalls queue</a></li>
                <li><a href="/cgi-bin/koha/recalls/recalls_to_pull.pl" title="Recalls that could be filled but have not been set waiting">Recalls to pull</a></li>
                <li><a href="/cgi-bin/koha/recalls/recalls_overdue.pl" title="Recalled items that are overdue to be returned">Overdue recalls</a></li>
                <li><a href="/cgi-bin/koha/recalls/recalls_waiting.pl" title="Recalled items awaiting pickup">Recalls awaiting pickup</a></li>
                <li><a href="/cgi-bin/koha/recalls/recalls_old_queue.pl" title="Inactive recalls">Old recalls</a></li>
            [% END %]
        </ul>

    </div>
</div>
