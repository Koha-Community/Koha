<!-- Included File: top.inc -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Koha: Integrated Library System</title>

<link href="/intranet-tmpl/ccfls/en/includes/styles.css" rel="stylesheet" type="text/css" />
</head>

<body>
<div id="logo">
	<img src="/intranet-tmpl/ccfls/images/ccfls-logo.png" width="485" height="70" />
</div>

<map name="tabsMap" id="tabsMap">
			<area shape="rect" coords="812,12,930,40" href="/cgi-bin/koha/admin-home.pl" target="_self" alt="Parameters" />
			<area shape="rect" coords="681,12,799,40" href="/cgi-bin/koha/authorities/authorities-home.pl" target="_self" alt="Authorities" />
			<area shape="rect" coords="549,12,667,40" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions" target="_self" alt="Aquisitions" />
			<area shape="rect" coords="277,2,399,40" href="/cgi-bin/koha/members/members-home.pl" target="_self" alt="Patrons" /><area shape="rect" coords="415,12,533,40" href="/cgi-bin/koha/reports-home.pl" target="_self" alt="Reports" />
			<area shape="rect" coords="143,2,265,40" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet" target="_self" alt="Catalog" />
			<area shape="rect" coords="8,3,130,41" href="/cgi-bin/koha/circ/circulation.pl" target="_self" alt="Circulation" />
  	</map>


<div id="issues-count"><img src="/intranet-tmpl/ccfls/images/issues-count.png" width="255" height="72" /></div>
<div id="issues-count-text">Issues Today: 42<br />Issues YTD: 23433</div>
<div id="logged-in-as"><img src="/intranet-tmpl/ccfls/images/logged-in-as.png" width="220" height="29" /></div>

<div id="logged-in-as-text">
<!-- TMPL_IF NAME="loggedinusername" -->
    Logged in as: 
<!-- TMPL_VAR NAME="loggedinusername" --><!-- TMPL_ELSE -->
    <a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha
<!-- /TMPL_IF -->
</div>

<div id="button-help"><a href="/cgi-bin/koha/help.pl"><img src="/intranet-tmpl/ccfls/images/help.png" width="43" height="36" border="0" /></a></div>

<div id="button-about"><a href="/cgi-bin/koha/about.pl"><img src="/intranet-tmpl/ccfls/images/about.png" width="43" height="36" border="0" /></a></div>

<div id="button-logout"><a href="/cgi-bin/koha/mainpage.pl?logout.x=1"><img src="/intranet-tmpl/ccfls/images/logout.png" width="43" height="36" border="0" /></a></div>

<div id="header-background"><img src="/intranet-tmpl/ccfls/images/header-background.png" width="1200" height="140" /></div>

<div id="patronSearch">
<form action="patronSearch" method="post" name="patronSearch">
	<strong>Patron Search:</strong>
	<input name="patronSearch" type="text" size="20" />
	<input name="submit" type="button" value="Search" />
</form>
</div>

<div id="catalogSearch">
<form action="bookSearch" method="post" name="catalogSearch">
	<strong>Catalog Search:</strong>
	<input name="catalogSearch" type="text" size="20" />
	<input name="submit" type="button" value="Search" />
</form>
</div>