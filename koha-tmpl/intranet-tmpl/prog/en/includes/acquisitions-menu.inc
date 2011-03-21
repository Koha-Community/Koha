<ul>
	<li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>
	<!-- TMPL_IF NAME="suggestion" --><li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Suggestions</a></li><!-- TMPL_ELSE --><!-- /TMPL_IF -->
    <!-- TMPL_IF name="CAN_user_acquisition_budget_manage" -->
	<li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets &amp; Funds</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF name="CAN_user_parameters" -->
     <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies</a></li>
    <!-- /TMPL_IF -->
</ul>
