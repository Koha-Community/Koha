<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: OPAC Wyszukiwanie w Katalogu</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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
		<a href="/cgi-bin/koha/opac-search.pl" title="Szukaj w Katalogu" class="white">
			Szukaj
		</a>
	</td>
        <td width="10%">
		<a href="/cgi-bin/koha/opac-user.pl" title="Zapisz się do biblioteki" class="white">
			Zapisy
		</a>
	</td>
	<td align="left" width="10%">
		<a href="/cgi-bin/koha/opac-main.pl" title="strona domowa" class="white">Początek</a>
	</td>
	<td width="60%">
		&nbsp;
	</td>
        </tr>
</table>

<!-- MAIN BODY OF PAGE -->

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Zalogowano jako: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/opac-user.pl">Twoje Konto</a>][<a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Wyloguj</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Zaloguj</a> do Koha</p>
<!-- /TMPL_IF -->

