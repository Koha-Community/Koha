<!-- Begin Circulation Resident Search Box -->
<div id="header_search">
	<div id="circ_search" class="residentsearch">
	<p class="tip">Entrer le n° de carte d'adhérent ou une partie du nom : </p>
	<form action="/cgi-bin/koha/circ/circulation.pl" method="post">
    <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
	<input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
    <input name="printer" value="" type="hidden" />
	<input value="Valider" type="submit">
	</form>
	</div>	
	<div id="checkin_search" class="residentsearch">
	<p class="tip">Scanner un code à barre pour le retour</p>
	<form method="post" action="/cgi-bin/koha/circ/returns.pl">
		<input name="barcode" id="ret_barcode" size="40" maxlength="14" />
	    <input value="Valider" type="submit">
    </form>
	</div>
	<div id="catalog_search" class="residentsearch">
	<p class="tip">Entrer les termes de recherche :</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
                    <input type="text" name="q" id="search-form" size="40" />
                    <input type="hidden" name="idx" value="kw,wrdl" />
                    <input type="submit" name="op" id="opac-submit" value="Valider" class="form-submit">
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
			<li><a href="/cgi-bin/koha/circ/returns.pl#checkin_search">Retours</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Recherche catalogue</a></li>
			</ul>	
</div>
<!-- End Circulation Resident Search Box -->