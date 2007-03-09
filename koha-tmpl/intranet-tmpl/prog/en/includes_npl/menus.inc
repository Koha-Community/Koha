<script language="JavaScript" type="text/javascript">
function _(s) { return s } // dummy function for gettext
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>
<div id="nav">
<ul>
    <li><h4>Koha</h4></li>
    <li><a href="/cgi-bin/koha/mainpage.pl">Koha intranet home</a></li>
    <li><a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
    <ul>
        <li><a href="/cgi-bin/koha/circ/circulation.pl">Issues</a>
            <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
                <label for="navfindborrower">Iss<span class="accesskey">u</span>e to:</label>
                <input id="navfindborrower" name="findborrower" type="text" size="10" accesskey="u" />
                <input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
                <input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
                <input type="submit" class="submit" value="Submit" />
            </form>
        </li>
        <li>
            <a accesskey="r" href="/cgi-bin/koha/circ/returns.pl"><span class="accesskey">R</span>eturns</a>
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/reserve.pl">Reserve List</a>
        </li>
        <li>
            <a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfers</a>
        </li>
    </ul>
    </li>
    <li>
        <a href="/cgi-bin/koha/members/members-home.pl">Patrons</a>
        <ul>
            <li>
                <form action="/cgi-bin/koha/members/member.pl" method="post">
                    <label for="navmember">Search:</label><input id="navmember" type="text" size="10" name="member" />
                    <input type="submit" value="Search" class="submit" />
                </form>
            </li>
        </ul>
    </li>
    <li>
        <a href="/cgi-bin/koha/catalogue/search.pl">Catalog</a>
        <ul>
            <li>
                <form method="post" action="/cgi-bin/koha/catalogue/search.pl">
                    <input type="hidden" name="op" value="do_search" />
                    <input type="hidden" name="type" value="intranet" />
                    <input type="hidden" name="nbstatements" value="3" />
                    <label for="navkeyword"><span class="accesskey">Q</span>uick Search:</label>
                    <input type="hidden" name="marclist" value="" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <input type="hidden" name="operator" value="contains" />
                    <input type="text" id="navkeyword" name="value" size="10" accesskey="q" />
                    <input type="submit" value="Start search" class="submit" />
                </form>
            </li>
        </ul>
    </li>
    <li><a href="/cgi-bin/koha/acqui.simple/addbooks.pl">Cataloging</a>
        <ul>
            <li><a href="/cgi-bin/koha/acqui.simple/addbiblio.pl">Add MARC</a></li>
            <li><a href="/cgi-bin/koha/acqui/acqui-home.pl>Acquisitions</a></li>
            <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a></li>
            <li><a href="/cgi-bin/koha/bull-home.pl">Serials</a></li>
            <li><a href="/cgi-bin/koha/bookshelves/shelves.pl">Virtual Shelves</a></li>
        </ul>
    </li>
    <li><a href="/cgi-bin/koha/reports-home.pl">Accounts and Reports</a></li>
    <li><a href="/cgi-bin/koha/admin-home.pl">Koha Administration</a>
        <ul>
            <li><a href="/cgi-bin/koha/admin-home.pl">System Administration</a></li>
            <li><a href="/cgi-bin/koha/admin/systempreferences.pl">System Preferences</a></li>
        </ul>
    </li>
    <li><a href="/cgi-bin/koha/about.pl">About Koha</a></li>
    <!-- TMPL_IF NAME="loggedinusername" -->
    <li>Logged in as: <!-- TMPL_VAR NAME="loggedinusername" -->, from <!-- TMPL_VAR name="branchname" -->
        <ul>
            <li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a></li>
        </ul>
    </li><!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="IntranetNav" -->
        <!-- TMPL_VAR NAME="IntranetNav" -->
    <!-- /TMPL_IF -->
</ul>
</div>
