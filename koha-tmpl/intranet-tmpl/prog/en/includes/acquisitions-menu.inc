<ul>
	<li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>
	[% IF ( suggestion ) %]<li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Suggestions</a></li>[% ELSE %][% END %]
    <li><a href="/cgi-bin/koha/acqui/invoices.pl">Invoices</a></li>
    [% IF ( CAN_user_acquisition_budget_manage ) %]
    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets</a></li>
    <li><a href="/cgi-bin/koha/admin/aqbudgets.pl">Funds</a></li>
    [% END %]
    [% IF ( CAN_user_parameters ) %]
     <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies</a></li>
    [% END %]
    [% IF CAN_user_acquisition_edi_manage %]
     <li><a href="/cgi-bin/koha/acqui/edifactmsgs.pl">EDIFACT messages</a></li>
     <li><a href="/cgi-bin/koha/admin/edi_accounts.pl">EDI accounts</a></li>
     <li><a href="/cgi-bin/koha/admin/edi_ean_accounts.pl">Library EANs</a></li>
    [% END %]
</ul>
