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
                        [% IF facets_loo.type_label_Authors %]<h5 id="facet-authors">Authors</h5>[% END %]
                        [% IF facets_loo.type_label_Titles %]<h5 id="facet-titles">Titles</h5>[% END %]
                        [% IF facets_loo.type_label_Topics %]<h5 id="facet-topics">Topics</h5>[% END %]
                        [% IF facets_loo.type_label_Places %]<h5 id="facet-places">Places</h5>[% END %]
                        [% IF facets_loo.type_label_Series %]<h5 id="facet-series">Series</h5>[% END %]
                        [% IF facets_loo.type_label_ItemTypes %]<h5 id="facet-itemtypes">Item types</h5>[% END %]
                        [% UNLESS singleBranchMode %]
                          [% IF facets_loo.type_label_Libraries %]<h5 id="facet-libraries">Libraries</h5>[% END %]
                        [% END %]
                        [% IF facets_loo.type_label_Location %]<h5 id="facet-locations">Locations</h5>[% END %]

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
