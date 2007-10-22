
<div id="header_search">
<div id="supplier_search" class="residentsearch">
	<p class="tip">Rechercher fournisseurs :</p>
        <form name="findsupplier" action="/cgi-bin/koha/acqui/booksellers.pl" method="post">
           <input type="text" size="25" name="supplier" id="supplier" class="focus" />
            <input type="submit" value="Rechercher"></form>
</div>
	<div id="orders_search" class="residentsearch">
	<p class="tip">Recherche commande :</p>
	
		<form action="/cgi-bin/koha/acqui/histsearch.pl" method="post">
		<label for="title">Civilité :  </label><input type="text" id="title" name="title" size="15" value="<!-- TMPL_VAR name="title"-->" /> <label for="supplier">Fournisseur : </label> <input type="text" id="supplier" name="name" size="15" value="<!-- TMPL_VAR name="name" -->" />
	<input value="Valider" type="submit"> <a href="/cgi-bin/koha/acqui/histsearch.pl">Avancé</a>
	</form>
	</div>	
			<ul>
			<li><a href="/cgi-bin/koha/acqui/booksellers.pl#supplier_search">Recherche fournisseur</a></li>
			<li><a href="/cgi-bin/koha/acqui/histsearch.pl#orders_search">Recherche sur les commandes</a></li>
			</ul>	
</div>