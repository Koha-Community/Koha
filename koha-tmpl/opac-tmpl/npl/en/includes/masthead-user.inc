<div id="masthead">
<h1>Library Catalog Search</h1>
<div class="menu"><form action="/cgi-bin/koha/opac-search.pl" method="post">
<p><a href="/cgi-bin/koha/opac-main.pl">Search Home</a> | <a href="" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag</a></p> <p><label for="value">Search the Catalog</label>
  <input type="hidden" name="op" value="do_search" />
			<input type="hidden" name="type" value="opac" />
			<input type="hidden" name="marclist" value="" />
			<input type="hidden" name="and_or" value="and" />
			<input type="hidden" name="excluding" value="" />
			<input type="hidden" name="operator" value="contains" />
			<input type="text" size="12" name="value" id="value" />&nbsp;<input type="submit"  class="submit" name="Go" value="Search" /></form></p></div>
<!-- <div class="menu"><a href="/cgi-bin/koha/opac-user.pl">your library home</a> |   
	<a href="/cgi-bin/koha/opac-userdetails.pl">your personal details</a> | <a href="/cgi-bin/koha/opac-shelves.pl">My Book Lists</a> | <a class="logout" href="/cgi-bin/koha/opac-logout.pl">log out</a>
  </ul>
</div> -->
<!-- TMPL_IF NAME="loggedinusername" --><div id="members">
	<ul>
		<li>Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></li>
		<li><a href="/cgi-bin/koha/opac-shelves.pl">My Book Lists</a></li>
		<li><a href="/cgi-bin/koha/opac-user.pl">My Account</a></li>
		<li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Log Out</a></li>
	</ul>	
</div>
<!-- TMPL_ELSE -->
	<div id="members">
		<a class="card" href="/cgi-bin/koha/opac-user.pl">Log in to access<br /> cardholder features</a>
	</div>
<!-- /TMPL_IF -->
</div>