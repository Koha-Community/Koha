<!-- TMPL_IF NAME="biblionumber" -->
	<div class="biblioinfo">
	<h5><!-- TMPL_VAR NAME="title" --></h5>	
	<!-- TMPL_IF NAME="author" --><!-- TMPL_VAR NAME="author" --><!-- /TMPL_IF -->
	</div>
<!-- /TMPL_IF -->

<ul>
	<li><a href="/cgi-bin/koha/catalogue/search.pl">Advanced Search</a></li>
	<li><a href="/cgi-bin/koha/virtualshelves/shelves.pl">Virtual Shelves</a></li>
</ul>