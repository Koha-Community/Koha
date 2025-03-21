[% USE Koha %]
<div id="acquisitions-menu" class="sidebar_menu">
    <h5>Acquisitions</h5>
    <ul>
        <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions home</a></li>
        <li><a href="/cgi-bin/koha/acqui/histsearch.pl">Advanced search</a></li>
        [% IF ( CAN_user_acquisition_order_receive ) %]<li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>[% END %]
        [% IF CAN_user_suggestions_suggestions_create || CAN_user_suggestions_suggestions_manage || CAN_user_suggestions_suggestions_delete %]<li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Suggestions</a></li>[% END %]
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
    [% IF ( CAN_user_acquisition_period_manage || CAN_user_acquisition_budget_manage || CAN_user_acquisition_currencies_manage || ( Koha.Preference('EDIFACT') && CAN_user_acquisition_edi_manage ) || CAN_user_parameters_manage_additional_fields ) || ( Koha.Preference('MarcOrderingAutomation') && CAN_user_acquisition_marc_order_manage ) %]
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
            [% IF Koha.Preference('MarcOrderingAutomation') && CAN_user_acquisition_marc_order_manage %]
                <li><a href="/cgi-bin/koha/admin/marc_order_accounts.pl">MARC order accounts</a></li>
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
                <li>
                    <a href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqorders">Manage order line fields</a>
                </li>
            [% END %]
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
