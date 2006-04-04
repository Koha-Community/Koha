	<div id="menuline">
		<!-- TMPL_VAR name="opacnav" -->
		<a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Library home page">Catalogue home</a>
		<a class="menu" href="/cgi-bin/koha/opac-search.pl" title="Advanced search">Advanced search</a>
		<!-- TMPL_IF NAME="loggedinusername" -->
			<!-- TMPL_IF name="virtualshelves" -->
				<a href="/cgi-bin/koha/opac-shelves.pl" class="menu">Virtual shelves</a>
			<!-- /TMPL_IF -->
			<!-- TMPL_IF name="suggestion" -->
				<a href="opac-suggestions.pl" class="menu">Suggestions</a>
			<!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
		<a class="menu" href="/cgi-bin/koha/opac-authorities-home.pl">Authorities Headings</a>
		<a class="menu" href="javascript:openBasket()" title="Biblio basket">Biblio basket <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
		<!-- TMPL_IF NAME="loggedinusername" -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="Member Home page">Personal page</a>
			<a class="menu" href="/cgi-bin/koha/opac-main.pl?logout.x=1" title="Logged in as <!-- TMPL_VAR NAME="loggedinusername" -->">Log Out</a>
		<!-- TMPL_ELSE -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="log in for personal options">Log in</a>
		<!-- /TMPL_IF -->
	</div>
