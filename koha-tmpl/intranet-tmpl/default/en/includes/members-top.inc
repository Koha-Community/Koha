<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Members</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>

<style>
.members {
	background-color: #86c268;
	color:#FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
a.members:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<div id="menubar">
	<span class="koha">KOHA</span>
	<a class="home" href="/cgi-bin/koha/mainpage.pl">Home</a>
	<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Catalogue</a>
	<a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
	<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
	<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
	<a class="about" href="/cgi-bin/koha/about.pl">About</a>
</div>
<div id="submenu">
	<span class="koha">options &gt;&gt;&nbsp;&nbsp;</b></span>
	<a href="/cgi-bin/koha/members/members-home.pl" class="submenu">Member home</a>
	<a href="/cgi-bin/koha/members/memberentry.pl?actionType=Add" class="submenu2">Add member</a>
	<a href="/cgi-bin/koha/members/memberentry.pl?categorycode=I&actionType=Add" class="submenu">Add organisation</a>
</div>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Log In</a> to Koha</p>
<!-- /TMPL_IF -->
