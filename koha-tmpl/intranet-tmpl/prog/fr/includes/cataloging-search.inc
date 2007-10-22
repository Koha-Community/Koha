<!-- Begin Circulation Resident Search Box -->
<div id="header_search">
<div id="addbooks_search" class="residentsearch">
	<p class="tip">Recherche dans le catalogue et le réservoir :</p>
	<form name="search" action="addbooks.pl">
        <input type="text" name="q"  size="40" class="focus" />
        <input type="submit" value="Rechercher">
	</form>
</div>
	<div id="circ_search" class="residentsearch">
	<p class="tip">Entrer le n° de carte d'adhérent ou une partie du nom : </p>
	<form action="/cgi-bin/koha/circ/circulation.pl" method="post">
			<label for="findborrower"> </label>
    <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
	<input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
    <input name="printer" value="" type="hidden" />
	<input value="Valider" type="submit">
	</form>
	</div>	
			<ul>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#addbooks_search">Recherche catalogue</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
			</ul>	
</div>
<!-- End Circulation Resident Search Box -->