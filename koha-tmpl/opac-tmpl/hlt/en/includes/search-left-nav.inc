<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr valign="top"><td width="5"><img src="<TMPL_VAR NAME='themelang'>/images/styles/nav-left-left.gif" width="5" height="63" border="0" alt="" /></td>
  <td width="133"><table border="0" cellpadding="0" cellspacing="0" width="133">
  <tr valign="top"><td colspan="3" background=""><img src="<TMPL_VAR NAME='themelang'>/images/styles/left-top.gif" width="133" height="39" border="0" alt="" /></td></tr>
  <tr valign="top"><td width="9"><img src="<TMPL_VAR NAME='themelang'>/images/styles/left-2ndrow.gif" width="9" height="13" border="0" alt="" /></td>
    <td width="124" colspan="2" class="navhead"><!--+Katipo+start name="leftheading" include="/includes/search-left-nav.inc" lastmod="12 Jun, 2002 at 18:25:21"-->Searching<!--+Katipo+end--></td></tr>

<tr valign="top"><td></td><td width="9"><img height="13" alt="" src="<TMPL_VAR NAME='themelang'>/images/styles/nav-dot.gif" border="0" width="9" /></td><td class="sidenav" width="115"><!--+Katipo+start name="search" include="/includes/search-left-nav.inc"  lastmod="20 Oct, 2002 at 16:38:15"--><a href="/cgi-bin/koha/opac-search.pl">Search the Catalogue</a><!--+Katipo+end--></td></tr>

<tr><td colspan="3"><img height="5" alt="" src="<TMPL_VAR NAME='themelang'>/images/holder.gif" border="0" width="1" /></td></tr>    <tr valign="top"><td></td><td><img height="13" alt="" src="<TMPL_VAR NAME='themelang'>/images/styles/nav-dot.gif" border="0" width="9" /></td>      <td class="sidenav" width="115"><!--+Katipo+start name="historical" include="/includes/search-left-nav.inc" --><a href="http://horowhenuahistory.library.org.nz/">Horowhenua Historical Database</a><!--+Katipo+end--></td></tr>
 
<TMPL_IF NAME="loggedinuser">


  <tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="5" border="0" alt="" /></td></tr>
<tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="5" border="0" alt="" /></td></tr>
  <tr valign="top"><td></td><td><img src="<TMPL_VAR NAME='themelang'>/images/styles/nav-dot.gif" width="9" height="13"
border="0" alt="" /></td>  <td width="115" class="sidenav"><a
href="/cgi-bin/koha/opac-user.pl">My Home</a></td></tr>
<tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="5" border="0" alt="" /></td></tr>
    <tr valign="top"><td></td><td><img src="<TMPL_VAR
NAME='themelang'>/images/styles/nav-dot.gif" width="9" height="13"
border="0" alt="" /></td>  <td width="115" class="sidenav"><a
href="/cgi-bin/koha/opac-account.pl">My Account</a></td></tr>
<tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="5" border="0" alt="" /></td></tr>
  <tr valign="top"><td></td><td><img src="<TMPL_VAR
NAME='themelang'>/images/styles/nav-dot.gif" width="9" height="13"
border="0" alt="" /></td>
    <td width="115" class="sidenav"><a
href="/cgi-bin/koha/opac-readingrecord.pl">Reading Record</a></td></tr>
<tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif"
width="1" height="5" border="0" alt="" /></td></tr>
  <tr valign="top"><td></td><td><img src="<TMPL_VAR
NAME='themelang'>/images/styles/nav-dot.gif" width="9" height="13"
border="0" alt="" /></td>
    <td width="115" class="sidenav"><a
href="/cgi-bin/koha/opac-userdetails.pl">Personal Details</a></td></tr>

 <tr valign="top"><td colspan=3><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="1" height="15" border="0" alt=""
/></td>
   </tr>
   <TMPL_LOOP NAME="USER_INFO">
   <tr valign="top"><td></td><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small">
   <B> <TMPL_VAR NAME="firstname"> <TMPL_VAR NAME="surname"></B>
   </td></tr>
   <TMPL_IF NAME="emailaddress">
   <tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="sidenav">
    <A HREF='mailto:<TMPL_VAR NAME="emailaddress">'><TMPL_VAR
NAME="emailaddress"></A>
</td></tr>
</TMPL_IF>
<TMPL_IF NAME="streetaddress">
<tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="streetaddress">
    </td></tr>
    </TMPL_IF>
    <TMPL_IF NAME="suburb">
    <tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="suburb">
    </td></tr>
</TMPL_IF>
<TMPL_IF NAME="city">
<tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="city">
    </td></tr>
    </TMPL_IF>
    <TMPL_IF NAME="phone">
    <tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="phone">
    </td></tr>
    </TMPL_IF>
    </TMPL_LOOP>
    <tr valign="top"><td><img src="<TMPL_VAR
NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt=""
/></td><td class="small"></td><td class="small">
 >><A HREF="/cgi-bin/koha/opac-userupdate.pl" class="sidenav">Edit Details</A>
 </td></tr>
 <tr><td colspan="3">
 <form action="/cgi-bin/koha/opac-main.pl" method="post">
   <input type="image" name="logout" src="<TMPL_VAR
NAME='themelang'>/images/styles/logout-button.gif" alt="Log Out"
align="absmiddle" border="0" />
</form>
</td></tr>
<TMPL_ELSE>
<tr><td colspan="3">
<form action="/cgi-bin/koha/opac-user.pl" method="post">
  <div class="main">Members can sign in here:
    <br />Cardnumber:
      <br /><input type="text" name="userid" size="10" />
        <br />Password:
	  <br /><input type="password" name="password" size="10" />&nbsp;&nbsp;
	    <input type="image" name="Go" src="<TMPL_VAR
NAME='themelang'>/images/styles/home-go-button.gif" alt="Go"
align="absmiddle" border="0" /></div>
</form>
</td></tr>

</TMPL_IF>

  <tr><td colspan="3"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="10" border="0" alt="" /></td></tr>
  </table>
