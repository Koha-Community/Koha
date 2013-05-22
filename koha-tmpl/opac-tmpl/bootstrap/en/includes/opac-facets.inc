[% IF ( opacfacets && facets_loop ) %]
    <div id="search-facets">
        <h4><a href="#" class="menu-collapse-toggle">Refine your search</a></h4>
        <ul class="menu-collapse">
            <li id="availability_facet">Availability
                <ul>
                    <li>
                        [% IF ( available ) %]
                            Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |uri %][% limit_cgi_not_availablity %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]">Show all items</a>
                        [% ELSE %]
                            <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |uri %][% limit_cgi |uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]&amp;limit=available">Limit to currently available items.</a>
                        [% END %]
                    </li>
                </ul>
                [% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %])</li>[% END %]
            </li>

            [% FOREACH facets_loo IN facets_loop %]
                [% IF facets_loo.facets.size > 0 %]
                    <li id="[% facets_loo.type_id %]">
                        <h5>[% IF ( facets_loo.type_label_Authors ) %]Authors[% END %]
                                            [% IF ( facets_loo.type_label_Titles ) %]Titles[% END %]
                                            [% IF ( facets_loo.type_label_Topics ) %]Topics[% END %]
                                            [% IF ( facets_loo.type_label_Places ) %]Places[% END %]
                                            [% IF ( facets_loo.type_label_Series ) %]Series[% END %]
                                            [% IF ( facets_loo.type_label_ItemTypes ) %]Item types[% END %]
                                            [% UNLESS ( singleBranchMode ) %]
                                                [% IF ( facets_loo.type_label_Libraries ) %]Libraries[% END %]
                                            [% END %]
                                            [% IF ( facets_loo.type_label_Location ) %]Locations[% END %]</h5>
                        <ul>
                            [% FOREACH facet IN facets_loo.facets %]
                                <li>
                                    <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |uri %][% limit_cgi |uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %]&amp;limit=[% facet.type_link_value |uri %]:[% facet.facet_link_value |uri %]" title="[% facet.facet_title_value |html %]">[% facet.facet_label_value %]</a>
                                    [% IF ( displayFacetCount ) %]
                                        ([% facet.facet_count %])
                                    [% END %]
                                </li>
                            [% END %]
                            [% IF ( facets_loo.expandable ) %]
                                <li class="showmore">
                                    <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |uri %][% limit_cgi |uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |uri %][% END %][% IF ( offset ) %]
                                            &amp;offset=[% offset |uri %][% END %]&amp;expand=[% facets_loo.expand |uri %]#[% facets_loo.type_id |uri %]">Show more</a>
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
            [% OPACResultsSidebar %]
        </div>
    [% END %]
[% END # / IF opacfacets && facets_loop %]
