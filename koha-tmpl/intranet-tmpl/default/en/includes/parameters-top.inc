<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 12:24 12/01/00-->

<html>
<head>
<title>KOHA: INTRANET: Catalogue</title>


<style type="text/css">
<!--
select,option {font-size:12px}
-->

</style>

<SCRIPT LANGUAGE="JavaScript">
<!--

// go to page selected from options menu

function leapto(form) {
var myindex=form.dest.selectedIndex
parent.location.href=(form.dest.options[myindex].value);
}

function focusinput() {
    window.onerror=null;
    if (document.forms[0]) {
	document.forms[0].elements[0].focus();
    }
}

if (document.images){

menu=new Image;
menu.src ="/images/cat-cat.gif"

}

function messenger(url){
  window1=window.open(url,"window1","height=250,width=350,left=150,top=50,350,screenY=50");

}

//-->

</script>

</head>
<body text="black" bgcolor="white" link="#0000ff"
vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0
onLoad=focusinput()>




<!--HDL Colours

	Yellow = ffcc00
	light blue = ccccff
	bright blue links = 0000ff
	aubergine = 663266
	light green/grey = cccc99


-->

<!------------------------MENUS-------------------------------->

<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr bgcolor=663266 >

	<td  valign=top>
	<table cellpadding=0 cellspacing=0  border=0 height=29>
	<tr valign=top bgcolor=663266 >
	<td background="/images/catalogue-spot-1.gif" width="224"
	height="29"><font size=1 face="arial"><img src="/images/holder.gif" width=210 height=4 alt=" " hspace=0 vspace=0><br>
	<img src="/images/holder.gif"
	width=35 height=21 align=left alt=" " hspace=0 vspace=0><font size="+1">KOHA: <a href="/cgi-bin/koha/mainpage.pl">Main Menu</a></font><br>
	<img src="/images/holder.gif" width=210 height=1 alt=" " hspace=0 vspace=0></FONT></td>

	</TR></TABLE> </td>


	<td  valign=bottom align=right>
<img src="/images/holder.gif"  WIDTH=1  HEIGHT=38 HSPACE=0 vspace=0></td>
<td  valign=bottom align=right>
	<table cellpadding=0 cellspacing=0  border=0 height=29><tr><td>
<img src=/images/cat-cat.gif border="0" name=menu usemap="#map" HSPACE=0 vspace=0 ></td>

	</TR></TABLE></TD>
</tr>

</tr>
<TR VALIGN=TOP BGCOLOR="000000"><TD  COLSPAN=3><img src="/images/blackdot.gif"  WIDTH=1  HEIGHT=2  HSPACE=0 vspace=0></TD></TR>

</table>


<map name="map">
<area shape="rect" coords="18,8,84,27" href="/cgi-bin/koha/catalogue-home.pl" alt="Catalogue" onMouseOver="if(document.images)document.menu.src='/images/cat-cat.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">

<area shape="rect" coords="94,8,149,28" href="/cgi-bin/koha/members-home.pl" alt="Members" onMouseOver="if(document.images)document.menu.src='/images/cat-mem.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">

<area shape="rect" coords="154,9,212,29" alt="Acquisitions"   href="/cgi-bin/koha/loadmodules.pl?module=acquisitions" onMouseOver="if(document.images)document.menu.src='/images/cat-acq.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">

<area  shape="rect"alt="Reports"  coords="217,7,289,27"href="/cgi-bin/koha/reports-home.pl" onMouseOver="if(document.images)document.menu.src='/images/cat-rep.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">

<area shape="rect" coords="306,8,352,27" href="/cgi-bin/koha/circ/circulation.pl" alt="Circulation" onMouseOver="if(document.images)document.menu.src='/images/cat-crc.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">

<area  shape="rect" alt="Home" coords="374,9,419,29" href="/cgi-bin/koha/mainpage.pl" onMouseOver="if(document.images)document.menu.src='/images/cat-hom.gif'" onMouseOut="if(document.images)document.menu.src='/images/cat-cat.gif'">
<area shape="default" nohref>
</map>



<BLOCKQUOTE>
