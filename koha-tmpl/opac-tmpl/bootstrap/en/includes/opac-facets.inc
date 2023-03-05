[% USE raw %]
[% USE AuthorisedValues %]
[% USE Languages %]
[% IF ( opacfacets && facets_loop && total ) %]
    <div id="search-facets">
        <h2><a href="#" class="menu-collapse-toggle">Refine your search</a></h2>
        <ul class="menu-collapse">
            [% IF Koha.Preference("SavedSearchFilters") && search_filters.size > 0 %]
            <li id="search-filters">
            <h3 id="filter_facets">Custom search filters</h3>
            <ul>
                [% SET base_url = "/cgi-bin/koha/opac-search.pl?" _ query_cgi _ limit_cgi %]
                [% FOREACH search_filter IN search_filters %]
                <li>
                    [% IF active_filters.${search_filter.id} %]
                        <span class="filter_label">[% search_filter.name | html %]<a href="[% base_url _ '&nolimit=search_filter:' _ search_filter.id | url %]">[x]</a></span>
                    [% ELSE %]
                        <span class="filter_label"><a href="[% base_url _ '&limit=search_filter:' _ search_filter.id | url %]">[% search_filter.name | html %]</a></span>
                    [% END %]
                </li>
                [% END %]
            </ul>
            </li>
            [% END %]
            <li id="availability_facet"><h3 id="facet-availability">Availability</h3>
                <ul>
                    <li>
                        [% IF ( available ) %]
                            <strong>Showing only available items</strong></li><li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi_not_availablity | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]">Show all items</a>
                        [% ELSE %]
                            <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]&amp;limit=available">Limit to currently available items</a>
                        [% END %]
                    </li>
                </ul>
                [% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search | html %][% END %])</li>[% END %]
            </li>

            [% FOREACH facets_loo IN facets_loop %]
                [% IF facets_loo.facets.size > 0 %]
                    <li id="[% facets_loo.type_id | html %]">
                        [% IF facets_loo.type_label_Authors %]<h3 id="facet-authors">Authors</h3>[% END %]
                        [% IF facets_loo.type_label_Titles %]<h3 id="facet-titles">Titles</h3>[% END %]
                        [% IF facets_loo.type_label_Topics %]<h3 id="facet-topics">Topics</h3>[% END %]
                        [% IF facets_loo.type_label_Places %]<h3 id="facet-places">Places</h3>[% END %]
                        [% IF facets_loo.type_label_Series %]<h3 id="facet-series">Series</h3>[% END %]
                        [% IF facets_loo.type_label_ItemTypes %]<h3 id="facet-itemtypes">Item types</h3>[% END %]
                        [% IF facets_loo.type_label_CollectionCodes %]<h3 id="facet-collections">Collections</h3>[% END %]
                        [% IF facets_loo.type_label_Language %]<h3 id="facet-languages">Languages</h3>[% END %]
                        [% UNLESS singleBranchMode %]
                            [% IF ( facets_loo.type_label_HomeLibrary ) %]<h3 id="facet-home-libraries">Home libraries</h3>[% END %]
                            [% IF ( facets_loo.type_label_HoldingLibrary ) %]<h3 id="facet-holding-libraries">Holding libraries</h3>[% END %]
                        [% END %]
                        [% IF facets_loo.type_label_Location %]<h3 id="facet-locations">Locations</h3>[% END %]
                        <ul>
                            [% SET url = "/cgi-bin/koha/opac-search.pl?" _ query_cgi _ limit_cgi %]
                            [% IF ( sort_by ) %]
                              [% url = BLOCK %][% url | $raw %][% "&amp;sort_by=" _ sort_by | url %][% END %]
                            [% END %]
                            [% IF ( results_per_page ) %]
                              [% url = BLOCK %][% url | $raw %][% "&amp;count=" _ results_per_page | url %][% END %]
                            [% END %]
                            [% FOREACH facet IN facets_loo.facets %]
                            [% IF facets_loo.type_label_CollectionCodes %][% SET facet.facet_label_value = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.ccode', authorised_value => facet.facet_label_value, opac =>1 ) || facet.facet_label_value %][% END %]
                            [% IF facets_loo.type_label_Language %][% SET facet.facet_label_value = Languages.GetByISOCode(lang,facet.facet_label_value) || facet.facet_label_value %][% END %]
                            [% IF loop.count > 5 && !facet.active %]
                                <li class="collapsible-facet" style="display:none">
                            [% ELSE %]
                                <li>
                            [% END %]
                                  [% IF facet.active %]
                                    [% local_url = BLOCK %][% url | $raw %][% "&nolimit=" _  facet.type_link_value _ ":" _ facet.facet_link_value | url %][% END %]
                                    <span class="facet-label">[% facet.facet_label_value | html %]</span>
                                    [% IF ( displayFacetCount ) %]
                                      <span class="facet-count-selected">([% facet.facet_count | html %])</span>
                                    [% END %]
                                    [<a href="[% local_url | $raw %]" title="Remove facet [% facet.facet_label_value | html %]">x</a>]
                                  [% ELSE %]
                                    [% local_url = BLOCK %][% url | $raw %][% "&limit=" _  facet.type_link_value _ ":" _ facet.facet_link_value | url %][% END %]
                                    <span class="facet-label"><a href="[% local_url | $raw %]" title="[% facet.facet_title_value | html %]">[% facet.facet_label_value | html %]</a></span>
                                    [% IF ( displayFacetCount ) %]
                                      <span class="facet-count"> ([% facet.facet_count | html %])</span>
                                    [% END %]
                                  [% END %]
                                </li>
                            [% END %]
                            [% IF facets_loo.facets.size > 5 %]
                                <li class="moretoggle">
                                    <a href="#"><strong>Show more</strong></a>
                                </li>
                                <li class="moretoggle" style="display:none">
                                    <a href="#"><strong>Show less</strong></a>
                                </li>
                            [% END %]
                        </ul>
                    </li>
                [% END # / IF facets_loo.facets.size > 0 %]
            [% END # / FOREACH facets_loo  %]
        </ul>
    </div>  <!-- / #search-facets -->

    [% IF ( OPACResultsSidebar ) %]
        <div id="opacresultssidebar">
            [% OPACResultsSidebar | $raw %]
        </div>
    [% END %]
[% END # / IF opacfacets && facets_loop %]
