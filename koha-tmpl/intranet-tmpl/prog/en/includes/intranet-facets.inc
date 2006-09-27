<div id="facetsmenu">
<a href="/cgi-bin/koha/mainpage.pl">KOHA Home</a>
<h6>Refine Your Search</h6>

<!-- TMPL_LOOP NAME="facets_loop" -->
<ul><!-- TMPL_VAR NAME="type_label" -->
	<!-- TMPL_LOOP NAME="facets" -->
		<li><a href="/cgi-bin/koha/catalogue/catalogue-search.pl?op=do_search&and_or=@and&<!-- TMPL_VAR NAME="type_link_value" ESCAPE="URL"-->&value=<!-- TMPL_VAR NAME="facet_link_value" -->&zoom=1<!-- TMPL_VAR NAME="facetsdesc" ESCAPE="URL"-->"  title="<!-- TMPL_VAR NAME="facet_title_value" -->"><!-- TMPL_VAR NAME="facet_label_value" --> (<!-- TMPL_VAR NAME="facet_count" -->)</a></li>
	<!-- /TMPL_LOOP -->
<!-- TMPL_IF NAME="expandable" -->
	<li class="showmore"><a href="/cgi-bin/koha/catalogue/catalogue-search.pl?q=<!-- TMPL_VAR NAME="forminputs" -->&amp;expand=<!-- TMPL_VAR NAME="expand" -->#<!-- TMPL_VAR NAME="type_id" -->">Show More</a></li>
<!-- /TMPL_IF -->
</li></ul>
<!-- /TMPL_LOOP -->



</div>
