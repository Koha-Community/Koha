<div id="masthead">
<h1>Library Catalog Search</h1>
<div class="menu"><a href="/cgi-bin/koha/opac-main.pl">Search Home</a> | <a href="" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a></div>
<TMPL_IF NAME="loggedinusername">
<div class="menu"><span class="loggedin">You are logged in as <TMPL_LOOP NAME="USER_INFO"><a href="/cgi-bin/koha/opac-user.pl"><TMPL_VAR NAME="title"> <TMPL_VAR NAME="firstname"> <TMPL_VAR NAME="surname"></a></TMPL_LOOP></span> | <a class="logout" href="/cgi-bin/koha/opac-logout.pl">Log Out</a></div>
</TMPL_IF>
</div>