[% USE raw %]
[% USE AuthorisedValues %]
[% USE Languages %]
[% PROCESS 'i18n.inc' %]
[% USE AdditionalContents %]
[% SET OPACResultsSidebar = AdditionalContents.get( location => "OPACResultsSidebar", lang => lang, library => logged_in_user.branchcode || default_branch ) %]
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
                            [% SET search_filter_id = search_filter.id | uri %]
                            <li>
                                [% IF active_filters.${search_filter.id} %]
                                    <span class="filter_label">[% search_filter.name | html %]<a href="[% base_url _ '&nolimit=search_filter:' _ search_filter_id | $raw %]">[x]</a></span>
                                [% ELSE %]
                                    <span class="filter_label"><a href="[% base_url _ '&limit=search_filter:' _ search_filter_id | $raw %]">[% search_filter.name | html %]</a></span>
                                [% END %]
                            </li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
            <li id="availability_facet"
                ><h3 id="facet-availability">Availability</h3>
                <ul>
                    [% IF ( available ) %]
                        <li><strong>Showing only records with available items</strong></li
                        ><li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi_not_availablity | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]">Show all records</a> </li>
                    [% ELSE %]
                        <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]&amp;limit=available">Limit to records with available items</a></li>
                    [% END %]
                </ul>
                [% IF ( related ) %]<li>(related searches: [% FOREACH relate IN related %][% relate.related_search | html %][% END %])</li>[% END %]
            </li>

            [% FOREACH facets_loo IN facets_loop %]
                [% IF facets_loo.facets.size > 0 %]
                    <li id="[% facets_loo.type_id | html %]">
                        [% SWITCH facets_loo.label %]
                        [% CASE 'Authors' %]
                            <h3 id="facet-authors">Authors</h3>
                        [% CASE 'Titles' %]
                            <h3 id="facet-titles">Titles</h3>
                        [% CASE 'Topics' %]
                            <h3 id="facet-topics">Topics</h3>
                        [% CASE 'Places' %]
                            <h3 id="facet-places">Places</h3>
                        [% CASE 'Series' %]
                            <h3 id="facet-series">Series</h3>
                        [% CASE 'Item types' %]
                            <h3 id="facet-itemtypes">Item types</h3>
                        [% CASE 'Home libraries' %]
                            <h3 id="facet-home-libraries">Home libraries</h3>
                        [% CASE 'Holding libraries' %]
                            <h3 id="facet-holding-libraries">Holding libraries</h3>
                        [% CASE 'Location' %]
                            <h3 id="facet-locations">Locations</h3>
                        [% CASE 'Collections' %]
                            <h3 id="facet-collections">Collections</h3>
                        [% CASE 'Languages' %]
                            <h3 id="facet-languages">Languages</h3>
                        [% CASE %]
                            <h3 id="facet-[% facets_loo.type_link_value | html %]">[% facets_loo.label | html %]</h3>
                        [% END %]
                        <ul>
                            [% SET url = "/cgi-bin/koha/opac-search.pl?" _ query_cgi _ limit_cgi %]
                            [% IF ( sort_by ) %]
                                [% url = BLOCK %][% url | $raw %][% "&amp;sort_by=" _ sort_by | url %][% END %]
                            [% END %]
                            [% IF ( results_per_page ) %]
                                [% url = BLOCK %][% url | $raw %][% "&amp;count=" _ results_per_page | url %][% END %]
                            [% END %]
                            [% FOREACH facet IN facets_loo.facets %]
                                [% IF facets_loo.label == 'Collections' %][% SET facet.facet_label_value = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.ccode', authorised_value => facet.facet_label_value, opac =>1 ) || facet.facet_label_value %][% END %]
                                [% IF facets_loo.label == 'Languages' %][% SET facet.facet_label_value = Languages.GetByISOCode(lang,facet.facet_label_value) || facet.facet_label_value %][% END %]
                                [% SET li_class = '' %]
                                [% SET li_style = '' %]
                                [% IF loop.count > 5 && !facet.active %]
                                    [% li_class = "collapsible-facet" %]
                                    [% li_style = "display:none" %]
                                [% END %]
                                <li class="[% li_class | html %]" style="[% li_style | html %]">
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
                                    [% SET aria_label = t("Show more") %]
                                    [% SWITCH facets_loo.label %]
                                    [% CASE 'Authors' %]
                                        [% aria_label = t("Show more authors") %]
                                    [% CASE 'Titles' %]
                                        [% aria_label = t("Show more titles") %]
                                    [% CASE 'Topics' %]
                                        [% aria_label = t("Show more topics") %]
                                    [% CASE 'Places' %]
                                        [% aria_label = t("Show more places") %]
                                    [% CASE 'Series' %]
                                        [% aria_label = t("Show more series") %]
                                    [% CASE 'Item types' %]
                                        [% aria_label = t("Show more item types") %]
                                    [% CASE 'Home libraries' %]
                                        [% aria_label = t("Show more home libraries") %]
                                    [% CASE 'Holding libraries' %]
                                        [% aria_label = t("Show more holding libraries") %]
                                    [% CASE 'Location' %]
                                        [% aria_label = t("Show more locations") %]
                                    [% CASE 'Collections' %]
                                        [% aria_label = t("Show more collections") %]
                                    [% CASE 'Languages' %]
                                        [% aria_label = t("Show more languages") %]
                                    [% END %]

                                    <a href="#" aria-label="[% aria_label | html | trim %]"><strong>Show more</strong></a>
                                </li>
                                <li class="moretoggle" style="display:none">
                                    [% SET aria_label = t("Show more") %]
                                    [% SWITCH facets_loo.label %]
                                    [% CASE 'Authors' %]
                                        [% aria_label = t("Show fewer authors") %]
                                    [% CASE 'Titles' %]
                                        [% aria_label = t("Show fewer titles") %]
                                    [% CASE 'Topics' %]
                                        [% aria_label = t("Show fewer topics") %]
                                    [% CASE 'Places' %]
                                        [% aria_label = t("Show fewer places") %]
                                    [% CASE 'Series' %]
                                        [% aria_label = t("Show fewer series") %]
                                    [% CASE 'Item types' %]
                                        [% aria_label = t("Show fewer item types") %]
                                    [% CASE 'Home libraries' %]
                                        [% aria_label = t("Show fewer home libraries") %]
                                    [% CASE 'Holding libraries' %]
                                        [% aria_label = t("Show fewer holding libraries") %]
                                    [% CASE 'Location' %]
                                        [% aria_label = t("Show fewer locations") %]
                                    [% CASE 'Collections' %]
                                        [% aria_label = t("Show fewer collections") %]
                                    [% CASE 'Languages' %]
                                        [% aria_label = t("Show fewer languages") %]
                                    [% END %]

                                    [% IF aria_label %]
                                        <a href="#" aria-label="[% aria_label | html | trim %]"><strong>Show less</strong></a>
                                    [% END %]
                                </li>
                            [% END %]
                        </ul>
                    </li>
                [% END # / IF facets_loo.facets.size > 0 %]
            [% END # / FOREACH facets_loo %]
        </ul>
    </div>
    <!-- / #search-facets -->

    [% IF ( OPACResultsSidebar ) %]
        <div id="opacresultssidebar"> [% PROCESS koha_news_block news => OPACResultsSidebar %] </div>
    [% END %]
[% END # / IF opacfacets && facets_loop %]
