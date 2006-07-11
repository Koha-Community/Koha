<div id="masthead">
<h1><!-- TMPL_IF NAME="opacsmallimage" --><img alt="<!-- TMPL_VAR NAME="LibraryName" -->" src="<!-- TMPL_VAR NAME="opacsmallimage" -->" /><!-- /TMPL_IF -->Library Catalog Search</h1>
<div class="menu">

<form style="margin:0px;" name="searchform" method="get" action="/cgi-bin/koha/opac-zoomsearch.pl" id="searchform">
<input type="hidden" name="op" value="get_results" />
<input name="ccl_query" type="text"/>
<input type="submit" value="Search" class="submit" />
</form>

<p><a href="/cgi-bin/koha/opac-zoomsearch.pl">Search Home</a> <!-- TMPL_IF NAME="opacbookbag" -->| <a href="/cgi-bin/koha/opac-basket.pl" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a><!-- /TMPL_IF --></p> <p><label for="value">Search the Catalog</label></p>


<!-- TMPL_IF NAME="opacuserlogin" --><!-- TMPL_IF NAME="loggedinusername" --><div id="members">
	<ul>
		<li>Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></li>
		<!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">My Virtual Shelves</a></li><!-- /TMPL_IF -->
		<li><a href="/cgi-bin/koha/opac-user.pl">My Account</a></li>
		<li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Log Out</a></li>
	</ul>	
</div>
<!-- TMPL_ELSE -->
	<div id="members">
		<a class="card" href="/cgi-bin/koha/opac-user.pl">Log in to access<br /> cardholder features</a>
	</div>
<!-- /TMPL_IF -->
<br class="clear" /><!-- /TMPL_IF -->
</div>
