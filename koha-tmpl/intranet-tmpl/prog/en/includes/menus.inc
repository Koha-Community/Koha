<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>
<p>
	<a href="/cgi-bin/koha/mainpage.pl">Koha</a>
	<a href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
	<a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a>
	<a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	<a href="/cgi-bin/koha/members/members-home.pl">Members</a>
	<a href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a>
	<a href="/cgi-bin/koha/reports-home.pl">Reports</a>
	<a href="/cgi-bin/koha/admin/admin-home.pl">Parameters</a>
	<a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a>
	<a href="/cgi-bin/koha/about.pl">About</a>
	<a href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</p>

<div id="librarian_information">
<p><!-- TMPL_VAR name="loggedinusername" -->, from <!-- TMPL_VAR name="branchname" --></p>
</div>