<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: OPAC Catalogue Search</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/opac.css">
</head>

<body>



<!-- MENUS -->

<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#339999">

	<td width="7%">
		<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" height="50" border="0" alt=""><b>KOHA</b>
	</td>
        <td width="10%">
		<a href="/cgi-bin/koha/opac-search.pl" title="Search the catalogue" class="white">
			Search
		</a>
	</td>
        <td width="10%">
		<a href="/cgi-bin/koha/opac-user.pl" title="Join the library" class="white">
			Join
		</a>
	</td>
	<td align="left" width="10%">
		<a href="/cgi-bin/koha/opac-main.pl" title="home page" class="white">Home</a>
	</td>
	<td width="60%">
		&nbsp;
	</td>
        </tr>
</table>

<!-- MAIN BODY OF PAGE -->

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/opac-user.pl">Members Home</a>][<a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->

