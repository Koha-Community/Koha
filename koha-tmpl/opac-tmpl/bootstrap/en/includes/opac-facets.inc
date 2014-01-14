[% IF ( opacfacets && facets_loop ) %]
    <div id="search-facets">
        <h4><a href="#" class="menu-collapse-toggle">Refine your search</a></h4>
        <ul class="menu-collapse">
            <li id="availability_facet">Availability
                <ul>
                    <li>
                        [% IF ( available ) %]
                            Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |url %][% limit_cgi_not_availablity %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">Show all items</a>
                        [% ELSE %]
                            <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |url %][% limit_cgi |url %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]&amp;limit=available">Limit to currently available items.</a>
                        [% END %]
                    </li>
                </ul>
                [% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %])</li>[% END %]
            </li>

            [% FOREACH facets_loo IN facets_loop %]
                [% IF facets_loo.facets.size > 0 %]
                    <li id="[% facets_loo.type_id %]">
                        <h5>[% IF ( facets_loo.type_label_Authors ) %]<span id="facets-Authors">Authors</span>[% END %]
                                            [% IF ( facets_loo.type_label_Titles ) %]<span id="facets-Titles">Titles</span>[% END %]
                                            [% IF ( facets_loo.type_label_Topics ) %]<span id="facets-Topics">Topics</span>[% END %]
                                            [% IF ( facets_loo.type_label_Places ) %]<span id="facets-Places">Places</span>[% END %]
                                            [% IF ( facets_loo.type_label_Series ) %]<span id="facets-Series">Series</span>[% END %]
                                            [% IF ( facets_loo.type_label_ItemTypes ) %]<span id="facets-Itemtypes">Item types</span>[% END %]
                                            [% UNLESS ( singleBranchMode ) %]
                                                [% IF ( facets_loo.type_label_Libraries ) %]<span id="facets-Libraries">Libraries</span>[% END %]
                                            [% END %]
                                            [% IF ( facets_loo.type_label_Location ) %]<span id="facets-Locations">Locations</span>[% END %]</h5>
                        <ul>
                            [% FOREACH facet IN facets_loo.facets %]
                                <li>
                                    <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |url %][% limit_cgi |url %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]&amp;limit=[% facet.type_link_value |url %]:[% facet.facet_link_value |url %]" title="[% facet.facet_title_value |html %]">[% facet.facet_label_value %]</a>
                                    [% IF ( displayFacetCount ) %]
                                        ([% facet.facet_count %])
                                    [% END %]
                                </li>
                            [% END %]
                            [% IF ( facets_loo.expandable ) %]
                                <li class="showmore">
                                    <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |url %][% limit_cgi |url %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF ( offset ) %]
                                            &amp;offset=[% offset |url %][% END %]&amp;expand=[% facets_loo.expand |url %]#[% facets_loo.type_id |url %]">Show more</a>
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
