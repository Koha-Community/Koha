<div id="navmenu">
    <div id="navmenulist">
        <h5>Acquisitions</h5>
        <ul>
            <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions home</a></li>
            <li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>
            [% IF ( suggestion ) %]<li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Suggestions</a></li>[% END %]
                <li><a href="/cgi-bin/koha/acqui/invoices.pl">Invoices</a></li>
            [% IF CAN_user_acquisition_edi_manage %]
                <li><a href="/cgi-bin/koha/acqui/edifactmsgs.pl">EDIFACT messages</a></li>
            [% END %]
        </ul>
        [% IF ( CAN_user_acquisition_period_manage || CAN_user_acquisition_budget_manage || CAN_user_parameters || CAN_user_acquisition_edi_manage ) %]
            <h5>Administration</h5>
            <ul>
                <li><a href="/cgi-bin/koha/admin/admin-home.pl">Administration home</a></li>
                [% IF ( CAN_user_acquisition_period_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets</a></li>
                [% END %]
                [% IF ( CAN_user_acquisition_budget_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/aqbudgets.pl">Funds</a></li>
                [% END %]
                [% IF ( CAN_user_acquisition_currencies_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies</a></li>
                [% END %]
                [% IF CAN_user_acquisition_edi_manage %]
                    <li><a href="/cgi-bin/koha/admin/edi_accounts.pl">EDI accounts</a></li>
                    <li><a href="/cgi-bin/koha/admin/edi_ean_accounts.pl">Library EANs</a></li>
                [% END %]
            </ul>
        [% END %]
    </div>
</div>
