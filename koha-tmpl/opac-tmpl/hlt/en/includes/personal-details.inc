<table border="0" cellpadding="0" cellspacing="0" width="100%">
 <tr valign="top"><td colspan=3><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="1" height="15" border="0" alt="" /></td>
   </tr>
<tr valign="top"><td width="4"><img src="<TMPL_VAR NAME='themelang'>/images/holder.gif" width="9" height="13" border="0" alt="" /></td><td class="small">
<TMPL_LOOP NAME="USER_INFO">
   <B> <TMPL_VAR NAME="firstname"> <TMPL_VAR NAME="surname"></B>
</td></tr>
<TMPL_IF NAME="emailaddress">
<tr valign="top"><td class="small"></td><td class="sidenav">
    <A HREF='mailto:<TMPL_VAR NAME="emailaddress">'><TMPL_VAR NAME="emailaddress"></A>
</td></tr>
</TMPL_IF>
<TMPL_IF NAME="streetaddress">
<tr valign="top"><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="streetaddress">
</td></tr>
</TMPL_IF>
<TMPL_IF NAME="suburb">
<tr valign="top"><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="suburb">
</td></tr>
</TMPL_IF>
<TMPL_IF NAME="city">
<tr valign="top"><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="city">
</td></tr>
</TMPL_IF>
<TMPL_IF NAME="phone">
<tr valign="top"><td class="small"></td><td class="sidenav">
    <TMPL_VAR NAME="phone">
</td></tr>
</TMPL_IF>
<tr valign="top"><td class="small"></td><td class="small">
 >><A HREF="/cgi-bin/koha/opac-userupdate.pl" class="sidenav">Edit Details</A>
</td></tr>
</table>