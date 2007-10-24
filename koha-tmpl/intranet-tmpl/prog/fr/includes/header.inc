<div id="header">
	
<div id="toplevelnav">
<ul id="toplevelmenu">
	<!-- TMPL_IF NAME="CAN_user_circulate" --><li><a href="/cgi-bin/koha/circ/circulation-home.pl">Circulation</a></li><!-- /TMPL_IF -->
	 <!-- TMPL_IF NAME="CAN_user_borrowers" --><li><a href="/cgi-bin/koha/members/members-home.pl">Adhérents</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_catalogue" --><li><a href="/cgi-bin/koha/catalogue/search.pl">Catalogue</a></li><!-- /TMPL_IF -->
	<!-- TMPL_VAR name="IntranetNav" -->
	<li class="more"><a href="/cgi-bin/koha/mainpage.pl">Plus</a><ul>
	<li><a href="/cgi-bin/koha/virtualshelves/shelves.pl">Étagères virtuelles</a></li>
	<!-- TMPL_IF NAME="CAN_user_editcatalogue" --><li><a href="/cgi-bin/koha/cataloguing/addbooks.pl">Catalogage</a></li>
	<li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a></li>
	<li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Autorités</a></li>
	<li><a href="/cgi-bin/koha/serials/serials-home.pl">Périodiques</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_reports" --><li><a href="/cgi-bin/koha/reports/reports-home.pl">Bilans et statistiques</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_tools" --><li><a href="/cgi-bin/koha/tools/tools-home.pl">Outils</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters" --><li><a href="/cgi-bin/koha/admin/admin-home.pl">Administration</a></li><!-- /TMPL_IF -->
	<li><a href="/cgi-bin/koha/about.pl">A propos de Koha</a></li></ul></li>
</ul>
</div>
	
<div id="login"> <!-- TMPL_IF NAME="AutoLocation" --><strong><!-- TMPL_VAR NAME="LoginBranchname" --></strong><!-- TMPL_ELSE --><strong><!-- TMPL_VAR NAME="LoginBranchname" --></strong> (<a href="/cgi-bin/koha/circ/selectbranchprinter.pl">choisir</a>) <!-- /TMPL_IF --> <!-- TMPL_IF NAME="loggedinusername" --><span class="loggedinusername"><!-- TMPL_VAR NAME="loggedinusername" --></span> (<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Déconnecter</a>) <!-- TMPL_ELSE -->Vous n'êtes pas connecté | <!-- /TMPL_IF --><a href="/cgi-bin/koha/help.pl" id="helper" onclick="window.open('/cgi-bin/koha/help.pl','Koha_Help','width=600,height=600,toolbar=false,scrollbars=yes'); return false;">[ ? ]</a></div></div>
