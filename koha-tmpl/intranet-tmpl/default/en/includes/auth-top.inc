<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Authorities</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
// end hiding -->
</script>

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}

function addauthority() {
	X = document.forms[0].authtype.value;
	window.location="/cgi-bin/koha/authorities/authorities.pl?authtypecode="+X;
}
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style type="text/css">
.authority {
	background-color: #6b7cbe;
	color:#FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	background-image:none;
	}
a.authority:hover {
	background-color: #6b7cbe;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>
</head>

<body>
<!-- MENUS -->
<form>
<div id="menubar">
	<span class="koha"><a class="home" href="/cgi-bin/koha/mainpage.pl">Koha</a></span>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
	<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a>
	<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	<a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>
	<a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a>
	<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
	<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
	<a class="about" href="/cgi-bin/koha/about.pl">About</a>
	<a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</div>
<div id="submenu">
	<span class="koha">options &gt;&gt;&nbsp;&nbsp;</span>
	<select name="authtype">
		<!-- TMPL_LOOP name="authtypesloop" -->
			<option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->>
				<!-- TMPL_VAR name="authtypetext" -->
			</option>
		<!-- /TMPL_LOOP -->
	</select>
	<a href="javascript:addauthority()" class="submenu2">
		Add authority</a>
</div>
</form>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
