<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Katalog</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
// end hiding -->
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style>
.catalogue {
	background-color:#ad11ad;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
	font-weight: bold;
	}
a.catalogue:hover {
	background-color: #ad11ad;
	color: #FFFFFF;
	text-decoration: none;
	font-weight: normal;
	font-weight: bold;
	}
</style>
</head>
<body>
<!------------------------MENUS-------------------------------->
<div id="menubar">
	<span class="koha">KOHA</span>
	<a class="home" href="/cgi-bin/koha/mainpage.pl">Początek</a> <a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Katalog</a> <a class="members" href="/cgi-bin/koha/members/members-home.pl">Członkowie</a> <a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Gromadzenie</a> <a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Wypożyczalnia</a> <a class="reports" href="/cgi-bin/koha/reports-home.pl">Raporty</a> <a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parametry</a> <a class="about" href="/cgi-bin/koha/about.pl">O nas</a>
</div>
<div id="submenu">
	<span class="koha">opcje &gt;&gt;&nbsp;&nbsp;</span>
	<a href="/cgi-bin/koha/loadmodules.pl?module=search&marc=0&type=intranet" class="submenu">Szybkie wyszukiwanie</a> <a href="/cgi-bin/koha/loadmodules.pl?module=search&marc=1&type=intranet" class="submenu2">Wyszukiwanie MARC</a> <a href="/cgi-bin/koha/bookshelves/shelves.pl" class="submenu">Półki wirtualne</a> <a href="/cgi-bin/koha/loadmodules.pl?module=addbiblio&type=intranet" class="submenu2">Dodaj opis</a> <a href="/cgi-bin/koha/maint/catmaintain.pl" class="submenu">Porzątkowanie katalogu</a>
</div>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Zalogowano jako: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Wyloguj</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Zaloguj do</a> Systemu Koha</p>
<!-- /TMPL_IF -->
