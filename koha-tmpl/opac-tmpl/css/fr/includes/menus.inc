	<div id="menuline">
		<!-- TMPL_VAR name="opacnav" --> <a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Library home page">Accueil</a> <a class="menu" href="/cgi-bin/koha/opac-search.pl" title="Advanced search">Recherche avancée</a>
		<!-- TMPL_IF NAME="loggedinusername" -->
			<!-- TMPL_IF name="virtualshelves" -->
				<a href="/cgi-bin/koha/opac-shelves.pl" class="menu">Etagères virtuelles</a>
			<!-- /TMPL_IF -->
			<!-- TMPL_IF name="suggestion" -->
				<a href="opac-suggestions.pl" class="menu">Suggestions</a>
			<!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
		<a class="menu" href="/cgi-bin/koha/opac-authorities-home.pl">Autorités</a>
		<!-- TMPL_IF name="opacbookbag" -->
		<a class="menu" href="javascript:openBasket()" title="Panier de notices">Panier de notices <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="loggedinusername" -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="Member Home page">Page personnelle</a> <a class="menu" href="/cgi-bin/koha/opac-main.pl?logout.x=1" title="Logged in as <!-- TMPL_VAR NAME="loggedinusername" -->">Déconnexion</a>
		<!-- TMPL_ELSE -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="S'identifier pour accéder à votre dossier personnel">S'identifier</a>
		<!-- /TMPL_IF -->
	</div>
