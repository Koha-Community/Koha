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
</li><!-- Display for NPL <li><a href="/reserve_list.php">Reserve List</a></li><li><a href="http://66.213.78.70/secret/reserves/index.cfm">New Title Waiting List</a></li> /Display for NPL --><!-- Hide from NPL --><li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfers</a></li><!-- /Hide from NPL --></ul></li>
				<li><a href="/cgi-bin/koha/members-home.pl">Patrons</a><ul><li><form action="/cgi-bin/koha/member.pl" method="post">
	<label for="member">Search:</label><input id="member" type="text" size="10" name="member" />
	<input type="submit" value="Search" class="submit" />

	</form></li></ul></li>
				<li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=0&amp;type=intranet">Catalog</a><ul><li><form action="/cgi-bin/koha/search.pl" method="post">
		<label for="keyword">Quick Search:</label><input id="keyword" type="text"  size="10" name="keyword" />
		<input type="submit" value="Search" class="submit" />
		</form></li><li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=0&amp;type=intranet">Advanced Search</a></li><!-- Display for NPL <li><a href="/item_report.php">Format Search</a></li> /Display for NPL -->
<li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=1&amp;type=intranet">MARC Search</a></li><!-- Display for NPL <li><a href="http://live.moreforohio.org:8080/vdx/">MORE Search</a></li> /Display for NPL -->
</ul></li>
<li><a href="/cgi-bin/koha/acqui.simple/addbooks.pl">Cataloging</a><ul><!-- Display for NPL <li><a href="/cgi-bin/koha/acqui.simple/addbiblio-simple.pl">Add Temp</a> </li> /Display for NPL --><li><a href="/cgi-bin/koha/acqui.simple/addbiblio.pl">Add MARC</a></li><!-- Hide from NPL --><li><a href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a></li><!-- /Hide from NPL --></ul></li>
<!-- Hide from NPL --><li><a href="/cgi-bin/koha/reports-home.pl">Accounts and Reports</a></li>
<li><a href="/cgi-bin/koha/admin-home.pl">Koha Administration</a>
<ul><li><a href="/cgi-bin/koha/admin-home.pl">System Administration</a></li>
<li><a href="/cgi-bin/koha/admin/systempreferences.pl">System Preferences</a></li></ul>
</li><li><a href="/cgi-bin/koha/about.pl">About Koha</a></li><!-- /Hide from NPL -->
<!-- TMPL_IF NAME="loggedinusername" --><li>
    Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> <ul><li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a></li></ul></li><!-- /TMPL_IF -->
				<!-- Display for NPL <li><h4>Public Web Site</h4></li>
	            <li><a href="http://www.athenscounty.lib.oh.us/index.html">public home</a></li>
    	        <li><a href="http://www.athenscounty.lib.oh.us/library.html">your
                  library</a></li>
        	    <li><a href="http://www.athenscounty.lib.oh.us/kids/index.asp">kids</a></li>
            	<li><a href="http://www.athenscounty.lib.oh.us/teens/index.asp">teens</a></li>
	            <li><a href="http://koha.athenscounty.lib.oh.us/cgi-bin/koha/opac-main.pl">library
                  catalog</a></li>
	            <li><a href="http://www.athenscounty.lib.oh.us/programs.asp">programs</a></li>

	            <li><a href="http://www.athenscounty.lib.oh.us/branch.html">branches</a></li>
	            <li><a href="http://www.athenscounty.lib.oh.us/mobile.asp">the bookmobile</a></li>
	            <li><a href="http://www.oplin.org">OPLIN</a></li>
	            <li><a href="http://www.athenscounty.lib.oh.us/contact.html">contact</a></li> /Display for NPL -->
				</ul>
</div>