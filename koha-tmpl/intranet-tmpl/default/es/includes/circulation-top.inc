<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 11:53 19/11/99-->
<!--updated by rachel@katipo.co.nz 04:09 28/12/99-->
<!--updated by rachel@katipo.co.nz 10:01 1/02/2001-->


<html>
<head>
<title>KOHA: INTRANET: Circulation</title>

<style type="text/css">
<!--
select,option {font-size:12px}
-->

</style>

<SCRIPT LANGUAGE="JavaScript">
<!--// go to page selected from options menu

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
function messenger(url, x, y){
        window1=window.open(url,"window1","height"+x+",width="+y+",left=150,top=50,350,screenY=50");
}
function popup(message, x, y){
	win2=window.open("","update","height="+x+",width="+y+",left=150,top=50,screenX=150,screenY=50,resizable");
	win2.focus();
	win2.document.write(message);
	win2.document.close();
}




if (document.images){

menu=new Image;
menu.src ="/images/crc-crc.gif"

}

 //-->
	
	
</script>

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 
onLoad=focusinput()>




<!--HDL Colours

	Yellow = ffcc00 
	light blue = ccccff
	bright blue links = 0000ff
	aubergine = 663266 
	light green/grey = cccc99
	dark red = 990000 
	light red = cc9999 
	mid green = #339933 
	ligth green = #CCFF99 

-->

<!------------------------MENUS-------------------------------->

<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr bgcolor="#990000">

	<td  valign=top>
	<table cellpadding=0 cellspacing=0  border=0 height=29>
	<tr valign=top bgcolor="#990000">
	<td background="/images/catalogue-spot-1.gif" width="224" 
	height="29"><font size=1 face="arial"><img src="/images/holder.gif" width=210 height=4 alt=" " 	hspace=0 vspace=0><br>
	<img src="/images/holder.gif"
	width=35 height=21 align=left alt=" " hspace=0 vspace=0><font size="+1">KOHA: <A HREF="/cgi-bin/koha/mainpage.pl">Main Menu</A></font><br>
	<img src="/images/holder.gif" width=210 height=1 alt=" " hspace=0 vspace=0></FONT></td>

	</TR></TABLE></TD>



	<td  valign=bottom align=right><img src="/images/holder.gif"
	  WIDTH=1  HEIGHT=38 HSPACE=0 vspace=0></td>

	<td  valign=bottom align=right>
	<table cellpadding=0 cellspacing=0  border=0 height=29><tr><td><img src=/images/crc-crc.gif 	border="0" name=menu usemap="#map" HSPACE=0 vspace=0 ></td>

	</TR></TABLE></TD>
</tr>

<TR VALIGN=TOP BGCOLOR="000000"><TD  COLSPAN=3><img src="/images/blackdot.gif"  WIDTH=1  HEIGHT=2  HSPACE=0 vspace=0></TD></TR>

</table>


<map name="map">
<area shape="rect" coords="18,8,84,27" href="/cgi-bin/koha/catalogue-home.pl" alt="Catalogo" onMouseOver="if(document.images)document.menu.src='/images/crc-cat.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">

<area shape="rect" coords="94,8,154,28" href="/cgi-bin/koha/members-home.pl" alt="Socios" onMouseOver="if(document.images)document.menu.src='/images/crc-mem.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">

<area shape="rect" coords="165,9,233,29" alt="Adquisiciones"   href="/cgi-bin/koha/loadmodules.pl?module=acquisitions" onMouseOver="if(document.images)document.menu.src='/images/crc-acq.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">

<area  shape="rect"alt="Informes"  coords="237,7,296,27"href="/cgi-bin/koha/reports-home.pl" onMouseOver="if(document.images)document.menu.src='/images/crc-rep.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">


<area shape="poly" alt="Circulación" coords="319,26,314,12,303,7,324,2,350,2,374,11,383,19,386,29" href="/cgi-bin/koha/circ/circulation.pl" onMouseOver="if(document.images)document.menu.src='/images/crc-crc.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">


<area shape="poly" alt="Inicio" coords="373,7,399,0,422,0,443,9,455,19,457,27,389,27,381,11,372,8,373,8,373,8,372,6" href="/cgi-bin/koha/mainpage.pl" onMouseOver="if(document.images)document.menu.src='/images/crc-hom.gif'" onMouseOut="if(document.images)document.menu.src='/images/crc-crc.gif'">


<area shape="default" nohref>
</map>

<blockquote>
