<div class="navhead"><a href="/membership/">Membership</a></div>
<div class="sidenav">

<TMPL_IF NAME="loggedinuser">
<ul>
<li><a href="/cgi-bin/koha/opac-user.pl">My Home</a></li>

<li><a href="/cgi-bin/koha/opac-account.pl">My Account</a></li>

<li><a href="/cgi-bin/koha/opac-readingrecord.pl">Reading Record</a></li>

<li><a href="/cgi-bin/koha/opac-userdetails.pl">Personal Details</a></li>
</ul>

<p>&nbsp;<p>
<TMPL_LOOP NAME="USER_INFO">

   <B> <TMPL_VAR NAME="firstname"> <TMPL_VAR NAME="surname"></B></br>

<TMPL_IF NAME="emailaddress">

    <A HREF='mailto:<TMPL_VAR NAME="emailaddress">'><TMPL_VAR NAME="emailaddress"></A></br>

</TMPL_IF>
<TMPL_IF NAME="streetaddress">
    <TMPL_VAR NAME="streetaddress"></br>

</TMPL_IF>
<TMPL_IF NAME="suburb">
    <TMPL_VAR NAME="suburb"></br>

</TMPL_IF>
<TMPL_IF NAME="city">
    <TMPL_VAR NAME="city"></br>

</TMPL_IF>
<TMPL_IF NAME="phone">
    <TMPL_VAR NAME="phone"></br>

</TMPL_IF>
</TMPL_LOOP>

 >><A HREF="/cgi-bin/koha/opac-userupdate.pl" class="sidenav">Edit Details</A>

</div>

<form action="/cgi-bin/koha/opac-main.pl" method="post">
  <input type="hidden" name="logout.x" value="1">
  <input type="submit" name="logout" value="logout" class="submit" />
</form>

<TMPL_ELSE>

<form action="/cgi-bin/koha/opac-user.pl" method="post">
  <div class="main">Members can sign in here:
  <br />Cardnumber:
  <br /><input type="text" name="userid" size="10" />
  <br />Password:
  <br /><input type="password" name="password" size="10" />&nbsp;&nbsp;
  <input type="image" name="Go" src="<TMPL_VAR NAME='themelang'>/images/styles/home-go-button.gif" alt="Go" align="absmiddle" border="0" /></div>
</form>


</TMPL_IF>
