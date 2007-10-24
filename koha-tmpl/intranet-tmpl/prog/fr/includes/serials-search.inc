<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="subscription_search" class="residentsearch">
	<p class="tip">Rechercher périodiques :</p>
 <form action="/cgi-bin/koha/serials/serials-home.pl" method="get"><!-- TMPL_IF NAME="routing" --><input type="hidden" name="routing" value="<!-- TMPL_VAR NAME="routing" -->" /><!-- /TMPL_IF --><input type="hidden" name="searched" value="1" /> <label for="ISSN_filter">ISSN : </label> <input type="text" size="10" maxlength="11" name="ISSN_filter" id="ISSN_filter" value="<!-- TMPL_VAR name="ISSN_filter" -->" /> <label for="title_filter">Civilité : </label> <input type="text" size="20" maxlength="40" name="title_filter" id="title_filter" value="<!-- TMPL_VAR name="title_filter" -->" /><input type="submit" value="Rechercher" class="button">
</form>
	</div>
	<div id="circ_search" class="residentsearch">
	<p class="tip">Entrer le n° de carte d'adhérent ou une partie du nom : </p>
	<form action="/cgi-bin/koha/circ/circulation.pl" method="post">
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
			<li><a href="/cgi-bin/koha/serials/serials-home.pl#subscription_search">Rechercher périodique</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Recherche catalogue</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->