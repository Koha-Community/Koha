<ul>
	<li><a href="/cgi-bin/koha/acqui/lateorders.pl">Late orders</a></li>
    <li><!-- TMPL_IF name="suggestion" --> <a href="/cgi-bin/koha/suggestion/suggestion.pl"><!--TMPL_VAR NAME="suggestion" --> suggestions waiting</a>
        <!-- TMPL_ELSE --> <a href="/cgi-bin/koha/suggestion/suggestion.pl">No suggestions waiting</a> <!-- /TMPL_IF -->
    </li>
	<li><a href="/cgi-bin/koha/suggestion/suggestion.pl">Manage suggestions</a></li>
    <!-- TMPL_IF name="CAN_user_acquisition_budget_manage" -->
	<li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets</a></li>
	<li><a href="/cgi-bin/koha/admin/aqbudgets.pl">Funds</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF name="CAN_user_parameters" -->
     <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies</a></li>
    <!-- /TMPL_IF -->
</ul>
