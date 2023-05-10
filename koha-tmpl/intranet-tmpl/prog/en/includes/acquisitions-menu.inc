[% USE Koha %]
<div id="navmenu">
    <div id="navmenulist">
        <h5>Acquisitions</h5>
        <ul>
            <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions home</a></li>
            [% IF ( CAN_user_acquisition_order_receive ) %]<li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>[% END %]
            [% IF ( CAN_user_suggestions_suggestions_manage ) %]<li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Suggestions</a></li>[% END %]
            <li><a href="/cgi-bin/koha/acqui/invoices.pl">Invoices</a></li>
            [% IF Koha.Preference('EDIFACT') && CAN_user_acquisition_edi_manage %]
                <li><a href="/cgi-bin/koha/acqui/edifactmsgs.pl">EDIFACT messages</a></li>
            [% END %]
        </ul>
        [% IF ( CAN_user_reports || CAN_user_circulate_circulate_remaining_permissions ) %]
            <h5>Reports</h5>
            <ul>
                [% IF ( CAN_user_reports ) %]
                    <li><a href="/cgi-bin/koha/reports/acquisitions_stats.pl">Acquisitions statistics wizard</a></li>
                    <li><a href="/cgi-bin/koha/reports/orders_by_fund.pl">Orders by fund</a></li>
                [% END %]
                [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                    <li><a href="/cgi-bin/koha/circ/reserveratios.pl">Hold ratios</a></li>
                [% END %]
            </ul>
        [% END %]
        [% IF ( CAN_user_acquisition_period_manage || CAN_user_acquisition_budget_manage || CAN_user_acquisition_currencies_manage || ( Koha.Preference('EDIFACT') && CAN_user_acquisition_edi_manage ) || CAN_user_parameters_manage_additional_fields ) %]
            <h5>Administration</h5>
            <ul>
                [% IF ( CAN_user_acquisition_period_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets</a></li>
                [% END %]
                [% IF ( CAN_user_acquisition_budget_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/aqbudgets.pl">Funds</a></li>
                [% END %]
                [% IF ( CAN_user_acquisition_currencies_manage ) %]
                    <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies</a></li>
                [% END %]
                [% IF Koha.Preference('EDIFACT') && CAN_user_acquisition_edi_manage %]
                    <li><a href="/cgi-bin/koha/admin/edi_accounts.pl">EDI accounts</a></li>
                    <li><a href="/cgi-bin/koha/admin/edi_ean_accounts.pl">Library EANs</a></li>
                [% END %]
                [% IF CAN_user_acquisition_edit_invoices && CAN_user_parameters_manage_additional_fields %]
                    <li>
                        <a href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqinvoices">Manage invoice fields</a>
                    </li>
                [% END %]
                [% IF CAN_user_acquisition_order_manage && CAN_user_parameters_manage_additional_fields %]
                    <li>
                        <a href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqbasket">Manage order basket fields</a>
                    </li>
                [% END %]
            </ul>
        [% END %]
    </div>
</div>
