<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Parametry</title>
<link rel="stylesheet" type="text/css" href="<TMPL_VAR name="themelang">/includes/common-style.css">

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<style>

a.about {
	background-color: #86c268;
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color: #FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.about:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="45">
	<td valign="bottom" align="left">
		<table bgcolor="dddddd" width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width=70%>
				<tr>
					<td class="koha"><b>KOHA</b></td>
					<td>
						<a class="home" href="/cgi-bin/koha/mainpage.pl">Pocz±tek</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Katalog</a>
					</td>
					<td>
						<a class="members" href="/cgi-bin/koha/members-home.pl">Cz³onkowie</a>
					</td>
					<td>
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Akwizycje</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Cyrkulacja</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reporty</a>
					</td>
					<td>
						<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parametry</a>
					</td>
					<td>
						<a class="about" href="/cgi-bin/koha/about.pl">About</a>
					</td>
				</TR>
			</TABLE>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<TMPL_IF NAME="loggedinusername">
    <p align=left>Zalogowany jako: <TMPL_VAR NAME="loggedinusername"> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Log Out</a>]</p>
<TMPL_ELSE>
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Zaloguj siê</a> do Koha</p>
</TMPL_IF>
