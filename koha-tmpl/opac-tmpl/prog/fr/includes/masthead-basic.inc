<div id="masthead">

<h1 id="libraryname"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1>
<div id="members">
	<ul><!-- TMPL_IF NAME="opacbookbag" --><li><a href="/cgi-bin/koha/opac-basket.pl" onclick="openBasket(); return false;" title='Un "panier" pour vos sélections'><img border="0" src="<!-- TMPL_VAR NAME="themelang">/images/cart-small.gif"> Panier<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a></li><!-- /TMPL_IF --><!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Vos étagères virtuelles</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><a href="/cgi-bin/koha/opac-user.pl">Votre compte</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><span class="members">Connecté en tant que <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></span></li><li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Déconnexion</a></li><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Votre compte</a></li><!-- /TMPL_IF -->
	</ul>	
</div>
<div class="menu">
</div>
</div>

<!-- TMPL_IF NAME="opaclanguagesdisplay" --><div id="languages">
	<ul>
		<!-- TMPL_LOOP NAME="languages" --><li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language" -->"><!-- TMPL_VAR NAME="label" --></a> </li><!-- /TMPL_LOOP -->
	</ul></div><!-- /TMPL_IF -->