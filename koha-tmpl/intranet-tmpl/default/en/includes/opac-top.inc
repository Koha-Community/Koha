<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 10:46 24/12/99-->

<html>
<head>
<title>KOHA: OPAC Catalogue Search</title>

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 >



<!--HDL Colours

        Yellow = ffcc00 
        light blue = ccccff
        bright blue links = 0000ff
        aubergine = 663266
        light green/grey = cccc99


-->

<!------------------------MENUS-------------------------------->

<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr BGCOLOR="#339999" >

        <td valign=bottom><img src="/images/inside-top-search.gif" 
	width=349 height=50 alt="KOHA: Catalogue Search" hspace=0 vspace=0 border=0></td>


        <td align=right><a href="/cgi-bin/koha/loadmodules.pl?module=search&type=opac" 		onMouseOver="document.mouseover.src='/images/mouseover-search.gif'" 		onMouseOut="document.mouseover.src='/images/holder.gif'"><img 
	src="/images/menu-search.gif" 
	width=71 height=30 alt="Search" hspace=0 vspace=0 border=0 name="menu-search"></a>
	
<!--	<a href="/member/"
	onMouseOver="document.mouseover.src='/images/mouseover-member.gif'" 			onMouseOut="document.mouseover.src='/images/holder.gif'"><img src="/images/menu-login.gif" 
	width=111 height=30 alt="Member Login" hspace=0 vspace=0 border=0 name="menu-login"></a>
-->
	<TMPL_IF NAME=loggedinuser>
	    <a href="/cgi-bin/koha/userpage.pl"
	    onMouseOver="document.mouseover.src='/images/mouseover-mysettings.gif'" 		onMouseOut="document.mouseover.src='/images/holder.gif'">
	    <img src="/images/menu-mysettings.gif"
	    width=90 height=30 alt="My Settings" hspace=0 vspace=0 border=0 name="menu-mysettings"></a>
	<TMPL_ELSE>
	    <a href="/join.html"
	    onMouseOver="document.mouseover.src='/images/mouseover-join.gif'" 		onMouseOut="document.mouseover.src='/images/holder.gif'">
	    <img src="/images/menu-join.gif"
	    width=54 height=30 alt="Join" hspace=0 vspace=0 border=0 name="menu-join"></a>
	</TMPL_IF>

	<a href="/cgi-bin/koha/mainpage.pl"
	onMouseOver="document.mouseover.src='/images/mouseover-home.gif'" 		onMouseOut="document.mouseover.src='/images/holder.gif'"><img src="/images/menu-home.gif"
	width=60 height=30 alt="Home" hspace=0 vspace=0 border=0 name="menu-home"></a></td>

        </TR>


<tr valign=top>

        <td><img src="/images/inside-koha-bottom.gif"
	width=69 height=44 alt="KOHA" hspace=0 vspace=0 border=0 ></td>

        <td align=right><img src="/images/holder.gif"
	width=300 height=48 alt="" hspace=0 vspace=0 name="mouseover" ></a></td>

        </TR>



</TABLE>



<!-------------------------MAIN BODY OF PAGE-------------------------->
<BLOCKQUOTE>
