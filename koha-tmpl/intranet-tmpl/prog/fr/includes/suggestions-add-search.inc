<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="suggestions_search" class="residentsearch">
	<p class="tip">Rechercher suggestions</p>
	<form action="/cgi-bin/koha/acqui/newordersuggestion.pl" method="get">
	<label for="searchtitle">Civilité : </label> <input type="text" id="searchtitle" name="title" value="<!-- TMPL_VAR NAME="title"-->" />
    <label for="searchauthor">Auteur : </label> <input type="text" id="searchauthor" name="author" value="<!-- TMPL_VAR NAME="author" -->" />
    <label for="searchpublishercode">Editeur : </label> <input type="text" id="searchpublishercode" name="publishercode" value="<!-- TMPL_VAR NAME="publishercode"-->" />
    <input type="submit" class="button" value="Rechercher suggestions">
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
			<li><a href="/cgi-bin/koha/acqui/newordersuggestion.pl?booksellerid=<!-- TMPL_VAR NAME="supplierid" -->&amp;basketno=<!-- TMPL_VAR NAME="basketno" -->#suggestions_search">Rechercher imprimantesinternet</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Recherche catalogue</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->