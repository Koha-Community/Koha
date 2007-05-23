<div id="masthead">
<h1><!-- TMPL_IF NAME="opacsmallimage" --><img alt="<!-- TMPL_VAR NAME="LibraryName" -->" src="<!-- TMPL_VAR NAME="opacsmallimage" -->" /><!-- /TMPL_IF -->Recherche dans le Catalogue de la bibliothèque</h1>
<div class="menu"><a href="/cgi-bin/koha/opac-main.pl">Recherche simple</a> | <a href="" onclick="openBasket(); return false;" title='Un "panier" pour vos sélections'>Panier<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a></div><br class="clear">
<!-- <!-- TMPL_IF NAME="loggedinusername" -->
<div class="menu"><span class="loggedin">You are logged in as <!-- TMPL_LOOP NAME="USER_INFO" --><a href="/cgi-bin/koha/opac-user.pl"><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --></a><!-- /TMPL_LOOP --></span> | <a class="logout" href="/cgi-bin/koha/opac-logout.pl">Log Out</a></div>
<!-- /TMPL_IF --> -->

<!-- TMPL_IF NAME="loggedinusername" --><div id="members">
	<ul>
		<li>Connecté en tant que <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></li>
		<li><a href="/cgi-bin/koha/opac-shelves.pl">Mes listes de livres</a></li>
		<li><a href="/cgi-bin/koha/opac-user.pl">Mon compte</a></li>
		<li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Déconnexion</a></li>
	</ul>	
</div>
<!-- TMPL_ELSE -->
	<div id="members">
		<a class="card" href="/cgi-bin/koha/opac-user.pl">Se connecter pour accéder<br /> Fonctionnalités pour les détenteurs d'une carte</a>
	</div>
<!-- /TMPL_IF -->
</div>