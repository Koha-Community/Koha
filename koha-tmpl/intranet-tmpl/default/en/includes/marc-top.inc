<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Catalogue</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript" type="text/javascript">
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
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/marc-editor.css">
<style type="text/css">
.catalogue {
	background-color:#ad11ad;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
	}
a.catalogue:hover {
	background-color: #ad11ad;
	color: #FFFFFF;
	text-decoration: none;
	}
</style>
</head>

<body>
<!-- MENUS -->
<div id="menubar">
	<span class="koha">KOHA</span>
	<a class="home" href="/cgi-bin/koha/mainpage.pl">Home</a>
	<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a>
	<a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
	<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	<a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a>
	<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
	<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
	<a class="about" href="/cgi-bin/koha/about.pl">About</a>
	<a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</div>
<div id="submenu">
	<span class="koha">options &gt;&gt;&nbsp;&nbsp;</span>
	<a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=1&amp;type=intranet" class="submenu2">search</a>
	<a href="/cgi-bin/koha/bookshelves/shelves.pl" class="submenu">Virtual shelves</a>
	<a href="/cgi-bin/koha/loadmodules.pl?module=addbiblio&amp;type=intranet" class="submenu2">Add biblio</a>
	<a href="/cgi-bin/koha/maint/catmaintain.pl" class="submenu">Cat maintenance</a>
</div>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
<a href="
javascript:(
  function(){
     var newSS;
     newSS=document.getElementById('codepoetry-debug-stylesheet');
     if(newSS){
        newSS.href=null;
        document.documentElement.childNodes[0].removeChild(newSS);
      } else {
        newSS=document.createElement('link');
        newSS.rel='stylesheet';
        newSS.type='text/css';
        newSS.href='http://www.codepoetry.net/stuff/css-debug-2.css';
        newSS.id='codepoetry-debug-stylesheet';
        document.documentElement.childNodes[0].appendChild(newSS);
      }
   }
)()">TOGGLE CSS</a>