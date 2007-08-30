<div id="header"><div id="title">
    <h1><a href="/cgi-bin/koha/mainpage.pl">Koha Staff Client</a></h1>
</div>
	
<div id="toplevelnav">
<ul>
	<li><a href="/cgi-bin/koha/mainpage.pl">Home</a></li>
	<li><a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a></li>
	<li><a href="/cgi-bin/koha/members/members-home.pl">Patrons</a></li>
	<li><a href="/cgi-bin/koha/catalogue/advsearch.pl">Catalogue</a></li>
</ul>
</div>
	
<div id="login"><p><!-- TMPL_IF NAME="loggedinusername" --><span class="loggedinusername"><!-- TMPL_VAR NAME="loggedinusername" --></span></p> <p><!-- TMPL_IF NAME="AutoLocation" --><strong><!-- TMPL_VAR NAME="LoginBranchname" --></strong><!-- TMPL_ELSE --><a href="/cgi-bin/koha/circ/selectbranchprinter.pl"><strong><!-- TMPL_VAR NAME="LoginBranchname" --></strong></a><!-- /TMPL_IF --></p> <p><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a> | <!-- TMPL_ELSE -->You are not logged in | <!-- /TMPL_IF --><a href="/cgi-bin/koha/help.pl" id="helper" onclick="window.open('/cgi-bin/koha/help.pl','Koha_Help','width=600,height=600,toolbar=false,scrollbars=yes');">[ ? ]</a></p></div></div>
