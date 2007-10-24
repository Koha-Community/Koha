<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="roadtype_search" class="residentsearch">
	<p class="tip">Rechercher le type de voie :</p>
		<form action="<TMPL_VAR NAME="script_name">" method="post">
		<input type="text" name="road_type" value="<!-- TMPL_VAR NAME="searchfield" -->" size="40" />
		<input type="submit" name="submit" value="OK" class="button" />
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
	<div id="catalog_search" class="residentsearch">
	<p class="tip">Entrer les termes de recherche :</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
                    <input type="text" name="q" id="search-form" size="40" value="" title="Détermine les serveurs Z3950 sur lesquels vous voulez que Koha cherche." class="form-text">
                    <input type="hidden" name="idx" value="kw,wrdl" />
                    <input type="submit" name="op" id="opac-submit" value="Valider" class="form-submit">
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/admin/roadtype.pl#roadtype_search">Rechercher types de voie</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Recherche catalogue</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->