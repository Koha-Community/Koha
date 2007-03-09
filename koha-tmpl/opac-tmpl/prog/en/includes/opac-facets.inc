<div id="nav">

<!-- TMPL_IF NAME="opacfacets" -->
<h6>Refine Your Search</h6>
<ul id="facets">
<!-- TMPL_LOOP NAME="facets_loop" -->
<li id="<!-- TMPL_VAR NAME="type_id" -->"><!-- TMPL_VAR NAME="type_label" --><ul>
	<!-- TMPL_LOOP NAME="facets" -->
		<li><a href="/search?q=<!-- TMPL_VAR NAME="searchdesc" --> and <!-- TMPL_VAR NAME="type_link_value" -->:<!-- TMPL_VAR NAME="facet_link_value" -->" title="<!-- TMPL_VAR NAME="facet_title_value" -->"><!-- TMPL_VAR NAME="facet_label_value" --></a> (<!-- TMPL_VAR NAME="facet_count" -->)</li>
	<!-- /TMPL_LOOP -->
<!-- TMPL_IF NAME="expandable" -->
	<li class="showmore"><a href="/search?q=<!-- TMPL_VAR NAME="searchdesc" -->&amp;expand=<!-- TMPL_VAR NAME="expand" -->#<!-- TMPL_VAR NAME="type_id" -->">Show More</a></li>
<!-- /TMPL_IF -->
</ul></li>
<!-- /TMPL_LOOP -->
</ul>
<!-- /TMPL_IF -->
</div>
