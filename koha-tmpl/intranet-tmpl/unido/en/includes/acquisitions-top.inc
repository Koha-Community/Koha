<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Acquisitions</title>
<link rel="stylesheet" type="text/css" href="<TMPL_VAR name="themelang">/includes/main.css">

</head>
<body>



<!--

TOPMENU

the top menu has 2 columns, the first is for the site name 
(usually Koha) the second is for the menu items - which aligns 
them right as a group.  The section you are in has a "selected" class
so you need a new menu for each section.

-->



<table class="top-menu" width="100%" border="0">
	<tr>

	<td><a href="/cgi-bin/koha/mainpage.pl" class="logo"><h1 

class="logo">Koha</h1></A></td>
	
	<td class="top-menuitems">
	<a

href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Catalogue</a>
	|
	<a class="menu" href="/cgi-bin/koha/members-home.pl">Patrons</a>
	|
	<a class="menu" href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	|
	<a  class="selected"  href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Add New 

Items</a>
	|
	<a class="menu" href="/cgi-bin/koha/admin-home.pl">Administration</a>
	|
	<a class="menu" href="/cgi-bin/koha/reports-home.pl">Reports</a> 
	|
	<a class="menu" href="/cgi-bin/koha/mainpage.pl">Home</a>
							
	</td>
				
	</TR>
</TABLE>

		

<!--
MAIN TABLE

The main table sets up a left hand colun for the sub menu and the layout of the rest of the 

page.  
We are using 2 and 3 column display tables, and there is a different set of includes for each.  


-->

<p>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr valign="top"><td class="sidenav-box">

<p>&nbsp;</p>

<h4>ACQUISITIONS</h4>

<UL class="sidenav">

<LI class="selected" > <a 

href="/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl">Add New Items</a>
<li> <a 

href="/cgi-bin/koha/acqui.simple/">Add Periodical</a>
						
</ul>

<h4>MAINTENANCE</h4>
<UL class="sidenav">

<li> <a href="/cgi-bin/koha/catalogue-home.pl">Edit Catalogue Record</a>

</ul>



<TMPL_IF NAME="loggedinusername">
You are Logged in as: <TMPL_VAR NAME="loggedinusername"> 

<UL class="sidenav">
<li>
<a href=/cgi-bin/koha/mainpage.pl?logout.x=1 class="logout">Log Out</a>
</ul>
<TMPL_ELSE>
<UL class="sidenav">
<li><a href=/cgi-bin/koha/opac-user.pl class="login">Log In</a>
</ul>
</TMPL_IF>


<p>



</td>


 <td width="32"><img src="/images/holder.gif" width="40" height="1" border="0" alt="" /></td>

<td>
