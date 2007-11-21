<!-- TMPL_IF NAME="PAGE_NUMBERS" --><div class="pages">
    <!-- Row of numbers corresponding to search result pages -->
        <!-- TMPL_IF NAME="previous_page_offset" --><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi" -->&amp;offset=<!-- TMPL_VAR NAME="previous_page_offset" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" --><!-- /TMPL_IF -->">&lt;&lt; Previous</a><!-- /TMPL_IF -->

    <!-- TMPL_LOOP NAME="PAGE_NUMBERS" --><!-- TMPL_IF NAME="highlight" --><span class="current"><!-- TMPL_VAR NAME="pg" --></span><!-- TMPL_ELSE -->        <a class="nav" href="/cgi-bin/koha/catalogue/search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi" -->&amp;offset=<!-- TMPL_VAR NAME="offset" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" --><!-- /TMPL_IF -->"><!-- TMPL_VAR NAME="pg" --></a><!-- /TMPL_IF -->
    <!-- /TMPL_LOOP -->

        <!-- TMPL_IF NAME="next_page_offset" --><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi" -->&amp;offset=<!-- TMPL_VAR NAME="next_page_offset" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" --><!-- /TMPL_IF -->">Next &gt;&gt;</a><!-- /TMPL_IF -->
</div><!-- /TMPL_IF -->
