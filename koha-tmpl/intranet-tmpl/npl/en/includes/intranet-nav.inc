<div id="nav">
<ul>
				<li><h4>Koha</h4></li>

				<li><a href="/cgi-bin/koha/mainpage.pl">Koha intranet home</a></li>
				<li><a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a><ul><li><a href="/cgi-bin/koha/circ/circulation.pl">Issues</a>	<form method="post" action="/cgi-bin/koha/circ/circulation.pl">
<label for="findborrower">Issue to:</label>
				<input id="findborrower" name="findborrower" type="text" size="10" />
				<input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
				<input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
				<input type="submit" class="submit" value="Submit" />
	</form></li><li><a href="/cgi-bin/koha/circ/returns.pl">Returns</a>
</li><li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfers</a></li></ul></li>
				<li><a href="/cgi-bin/koha/members/members-home.pl">Patrons</a><ul><li><form action="/cgi-bin/koha/members/member.pl" method="post">
	<label for="member">Search:</label><input id="member" type="text" size="10" name="member" />
	<input type="submit" value="Search" class="submit" />

	</form></li></ul></li>
				<li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=0&amp;type=intranet">Catalog</a><ul><li><form action="/cgi-bin/koha/search.pl" method="post">
		<label for="keyword">Quick Search:</label><input id="keyword" type="text"  size="10" name="keyword" />
		<input type="submit" value="Search" class="submit" />
		</form></li><li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=0&amp;type=intranet">Advanced Search</a></li>
<li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=1&amp;type=intranet">MARC Search</a></li><
</ul></li>
<li><a href="/cgi-bin/koha/acqui.simple/addbooks.pl">Cataloging</a><ul><li><a href="/cgi-bin/koha/acqui.simple/addbiblio.pl">Add MARC</a></li> <li><a href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a></li> </ul></li>
 <li><a href="/cgi-bin/koha/reports-home.pl">Accounts and Reports</a></li>
<li><a href="/cgi-bin/koha/admin-home.pl">Koha Administration</a>
<ul><li><a href="/cgi-bin/koha/admin-home.pl">System Administration</a></li>
<li><a href="/cgi-bin/koha/admin/systempreferences.pl">System Preferences</a></li></ul>
</li><li><a href="/cgi-bin/koha/about.pl">About Koha</a></li> 
<!-- TMPL_IF NAME="loggedinusername" --><li>
    Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> <ul><li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a></li></ul></li><!-- /TMPL_IF -->
				</ul>
</div>