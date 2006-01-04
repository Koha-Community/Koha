<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Circulation</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf8">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
function focusOnFirst (){
document.forms[0].elements[0].focus();
}
// end hiding -->
</script>

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>


<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style type="text/css">
.circulation {
	background-color: #be6170;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
	}
a.circulation:hover {
	background-color: #be6170;
	color: #FFFFFF;
	text-decoration: normal;
	}
</style>
</head>

<body onload="javascript:focusOnFirst()">

<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
