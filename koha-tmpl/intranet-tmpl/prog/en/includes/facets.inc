[% USE raw %]
[% USE AuthorisedValues %]
[% USE Branches %]
[% USE Languages %]

[% IF ( opacfacets ) %]
    [% IF ( facets_loop ) %]
        <div id="search-facets">
            <h4>Refine your search</h4>
            <ul>
                [% IF Koha.Preference("SavedSearchFilters") && search_filters.count > 0 %]
                    <li id="search-filters">
                        <span id="filter_facets">Custom search filters</span>
                        <ul>
                            [% SET base_url = "/cgi-bin/koha/catalogue/search.pl?" _ query_cgi _ limit_cgi %]
                            [% FOREACH search_filter IN search_filters %]
                                [% SET search_filter_id = search_filter.id | uri %]
                                <li>
                                    [% IF active_filters.${search_filter.id} %]
                                        <span class="filter_label">[% search_filter.name | html %]<a href="[% base_url _ '&nolimit=search_filter:' _ search_filter_id | $raw %]">[x]</a></span>
                                    [% ELSE %]
                                        <span class="filter_label"><a href="[% base_url _ '&limit=search_filter:' _ search_filter_id | $raw %]">[% search_filter.name | html %]</a></span>
                                    [% END %]
                                </li>
                            [% END # /FOREACH search_filter %]
                        </ul>
                    </li>
                [% END # /IF SavedSearchFilters %]
                <li id="availability_facet">
                    Availability
                    <ul>
                        [% IF ( available ) %]
                            <li>
                                <strong>Showing only records with available items</strong>
                            </li>
                            <li>
                                <a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi_not_availablity | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Show all records</a>
                            </li>
                        [% ELSE %]
                            <li>
                                <a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]&amp;limit=available"
                                    >Limit to records with available items</a
                                >
                            </li>
                        [% END # /IF available %]
                    </ul>
                    [% IF ( related ) %]
                        <li> (related searches: [% FOREACH relate IN related %][% relate.related_search | html %][% END %]) </li>
                    [% END %]
                </li>
                <!-- /#availability_facet -->

                [% FOREACH facets_loo IN facets_loop %]
                    [% IF facets_loo.facets.size > 0 %]
                        <li id="[% facets_loo.type_id | html %]">
                            [% SWITCH facets_loo.label %]
                            [% CASE 'Authors' %]
                                <span id="facet-authors">Authors</span>
                            [% CASE 'Titles' %]
                                <span id="facet-titles">Titles</span>
                            [% CASE 'Topics' %]
                                <span id="facet-topics">Topics</span>
                            [% CASE 'Places' %]
                                <span id="facet-places">Places</span>
                            [% CASE 'Series' %]
                                <span id="facet-series">Series</span>
                            [% CASE 'Item types' %]
                                <span id="facet-itemtypes">Item types</span>
                            [% CASE 'Home libraries' %]
                                <span id="facet-home-libraries">Home libraries</span>
                            [% CASE 'Holding libraries' %]
                                <span id="facet-holding-libraries">Holding libraries</span>
                            [% CASE 'Location' %]
                                <span id="facet-locations">Locations</span>
                            [% CASE 'Collections' %]
                                <span id="facet-collections">Collections</span>
                            [% CASE 'Languages' %]
                                <span id="facet-languages">Languages</span>
                            [% CASE %]
                                <span id="facet-[% facets_loo.type_link_value | html %]">[% facets_loo.label | html %]</span>
                            [% END %]
                            <ul>
                                [% SET url = "/cgi-bin/koha/catalogue/search.pl?" _ query_cgi _ limit_cgi %]
                                [% IF ( sort_by ) %]
                                    [% url = BLOCK %][% url | $raw %][% "&sort_by=" _ sort_by | url %][% END %]
                                [% END %]
                                [% IF ( results_per_page ) %]
                                    [% url = BLOCK %][% url | $raw %][% "&count=" _ results_per_page | url %][% END %]
                                [% END %]
                                [% FOREACH facet IN facets_loo.facets %]
                                    [% IF facets_loo.label == 'Collections' %]
                                        [% SET facet.facet_label_value = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.ccode', authorised_value => facet.facet_label_value ) || facet.facet_label_value %]
                                    [% END %]
                                    [% IF facets_loo.label == 'Languages' %]
                                        [% SET facet.facet_label_value = Languages.GetByISOCode(lang,facet.facet_label_value) || facet.facet_label_value %]
                                    [% END %]
                                    [% SET li_class = '' %]
                                    [% SET li_style = '' %]
                                    [% IF loop.count > 5 && !facet.active %]
                                        [% li_class = 'collapsible-facet' %]
                                        [% li_style = 'display: none;' %]
                                    [% END %]
                                    <li class="[% li_class | html %]" style="[% li_style | html %]">
                                        [% SET facet_is_current_library = ( facets_loo.label == 'Home libraries' || facets_loo.label == 'Holding libraries' ) && !singleBranchMode && facet.facet_title_value == Branches.GetLoggedInBranchcode %]
                                        [% SET facet_label_class = facet_is_current_library ? 'facet-label currentlibrary' : 'facet-label' %]
                                        [% IF facet.active %]
                                            [% local_url = BLOCK %][% url | $raw %][% "&nolimit=" _  facet.type_link_value _ ":" _ facet.facet_link_value | url %][% END %]
                                            <span class="[% facet_label_class | html %]">[% facet.facet_label_value | html %]</span>
                                            <span class="facet-count"> ([% facet.facet_count | html %]) </span>
                                            [<a href="[% local_url | $raw %]" title="Remove facet [% facet.facet_label_value | html %]">x</a>]
                                        [% ELSE %]
                                            [% local_url = BLOCK %][% url | $raw %][% "&limit=" _  facet.type_link_value _ ":" _ facet.facet_link_value | url %][% END %]
                                            <span class="[% facet_label_class | html %]"><a href="[% local_url | $raw %]" title="[% facet.facet_title_value | html %]">[% facet.facet_label_value | html %]</a></span>
                                            [% IF ( displayFacetCount ) %]
                                                <span class="facet-count"> ([% facet.facet_count | html %])</span>
                                            [% END %]
                                        [% END # /IF facet.active %]
                                    </li>
                                [% END # /FOREACH facet %]
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
                    [% END # /IF facets_loo.facets.size %]
                [% END # /FOREACH facets_loo %]
            </ul>
        </div>
        <!-- /#search-facets -->
    [% END # /IF ( facets_loop ) %]
[% END # /IF ( opacfacets ) %]
