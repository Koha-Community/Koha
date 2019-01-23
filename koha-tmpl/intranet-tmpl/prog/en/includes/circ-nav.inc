[% USE Branches %]
<script type="text/javascript">//<![CDATA[
    $(document).ready(function() {
        var path = location.pathname.substring(1);
        var url = window.location.toString();
        var params = '';
        if ( url.match(/\?(.+)$/) ) {
            params = "?" + RegExp.$1;
        }
        $('#navmenulist a[href$="/' + path + params + '"]').css('font-weight','bold');
    });
//]]>
</script>

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
            [% IF Branches.InIndependentBranchesMode %]
                <li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfer</a></li>
            [% END %]
            [% IF ( AutoLocation ) %][% ELSE %][% IF ( IndependentBranches ) %][% ELSE %]
                <li><a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a></li>
            [% END %][% END %]
            [% IF ( fast_cataloging ) %][% IF ( CAN_user_editcatalogue_fast_cataloging ) %]
                <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=FA">Fast cataloging</a></li>
            [% END %][% END %]
        </ul>

        <h5>Circulation reports</h5>
        <ul>
            <li><a href="/cgi-bin/koha/circ/view_holdsqueue.pl">Holds queue</a></li>
            <li><a href="/cgi-bin/koha/circ/pendingreserves2.pl">Holds to pull</a></li>
            <li><a href="/cgi-bin/koha/circ/waitingreserves.pl">Holds awaiting pickup</a></li>
            <li><a href="/cgi-bin/koha/circ/reserveratios.pl">Hold ratios</a></li>
            <li><a href="/cgi-bin/koha/circ/transferstoreceive.pl">Transfers to receive</a></li>
            [% IF ( CAN_user_circulate_overdues_report ) %]
                <li><a href="/cgi-bin/koha/circ/overdue.pl">Overdues</a></li>
            [% END %]
            <li><a href="/cgi-bin/koha/circ/branchoverdues.pl">Overdues with fines</a></li>
            [% IF Koha.Preference('OnSiteCheckouts') %]
                <li><a href="/cgi-bin/koha/circ/on-site_checkouts.pl">Pending on-site checkouts</a></li>
            [% END %]
        </ul>

    </div>
</div>
