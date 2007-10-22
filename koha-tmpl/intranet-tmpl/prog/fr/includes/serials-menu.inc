<!-- TMPL_IF NAME="subscriptionid" -->
<ul>
<li><a href="serials-collection.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Etat de collection</a></li>
	<!-- TMPL_IF NAME="routing" --><li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->">Modifier la liste de circulation</a></li><!-- TMPL_ELSE -->
	<li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->&amp;op=new">Créer une liste de circulation</a></li><!-- /TMPL_IF -->
</ul>
<!-- /TMPL_IF -->

<ul>
	<li><a href="/cgi-bin/koha/serials/claims.pl">Réclamations</a></li>
	<li><a href="/cgi-bin/koha/serials/checkexpiration.pl">Vérificater dates d'expiration</a></li>
</ul>