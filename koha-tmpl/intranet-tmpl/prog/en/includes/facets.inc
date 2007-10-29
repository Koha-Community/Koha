<!-- TMPL_IF NAME="opacfacets" -->
<ul id="search_facets">
<li><h4>Refine Your Search</h4></li>
<!-- TMPL_LOOP NAME="facets_loop" -->
<li id="<!-- TMPL_VAR NAME="type_id" -->"><!-- TMPL_VAR NAME="type_label" --><ul>
        <!-- TMPL_LOOP NAME="facets" --><li><a href="/cgi-bin/koha/catalogue/search.pl?q=<!-- TMPL_VAR NAME="searchdesc" -->&amp;limit=<!-- TMPL_VAR NAME="type_link_value" -->:<!-- TMPL_VAR NAME="facet_link_value" -->" title="<!-- TMPL_VAR NAME="facet_title_value" -->"><!-- TMPL_VAR NAME="facet_label_value" --></a> (<!-- TMPL_VAR NAME="facet_count" -->)</li><!-- /TMPL_LOOP --><!-- TMPL_IF NAME="expandable" -->
        <li class="showmore"><a href="/cgi-bin/koha/catalogue/search.pl?q=<!-- TMPL_VAR NAME="searchdesc" -->&amp;expand=<!-- TMPL_VAR NAME="expand" -->#<!-- TMPL_VAR NAME="type_id" -->">Show More</a></li>
<!-- /TMPL_IF -->
</ul></li>
<!-- /TMPL_LOOP -->
</ul>
<!-- /TMPL_IF -->
