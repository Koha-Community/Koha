<div id="toolbar">
	<ul class="toolbar">
		<li><a href="/cgi-bin/koha/acqui/supplier.pl?op=enter">Nouveau fournisseur</a></li>
		<!-- TMPL_IF NAME="id" -->
		<li><a href="/cgi-bin/koha/acqui/basket.pl?supplierid=<!-- TMPL_VAR NAME="id" -->">Nouvelle commande</a></li>
		<li><a href="/cgi-bin/koha/acqui/supplier.pl?supplierid=<!--TMPL_VAR Name="id"-->&amp;op=enter">Modifier</a></li>
		<li><a href="/cgi-bin/koha/acqui/booksellers.pl?supplier=<!--TMPL_VAR Name="id"-->">Gérer les commandescommentaire</a></li>
		<li><a href="/cgi-bin/koha/acqui/parcels.pl?supplierid=<!--TMPL_VAR Name="id"-->">Réceptionner un colis</a></li>
		<!-- /TMPL_IF -->
	</ul>
<br clear="all" />
</div>