[% IF ( opacfacets ) %]
[% IF ( facets_loop ) %]
<div id="search-facets">
<h4>Refine your search</h4>
<ul>
    <li id="availability_facet">Availability<ul><li>[% IF ( available ) %]Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi_not_availablity %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html%][% END %]">Show all items</a>[% ELSE %]Limit to <a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html%][% END %]&amp;limit=available">currently available items.</a>[% END %]</li></ul>
	[% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %])</li>[% END %]
	</li>
	
[% FOREACH facets_loo IN facets_loop %]
<li id="[% facets_loo.type_id %]">
[% IF ( facets_loo.type_label_Authors ) %]Authors[% END %]
[% IF ( facets_loo.type_label_Titles ) %]Titles[% END %]
[% IF ( facets_loo.type_label_Topics ) %]Topics[% END %]
[% IF ( facets_loo.type_label_Places ) %]Places[% END %]
[% IF ( facets_loo.type_label_Series ) %]Series[% END %]
[% IF ( facets_loo.type_label_ItemTypes ) %]Item types[% END %]
[% UNLESS ( singleBranchMode ) %]
[% IF ( facets_loo.type_label_Libraries ) %]Libraries[% END %]
[% END %]
[% IF ( facets_loo.type_label_Location ) %]Locations[% END %]
<ul>
        [% FOREACH facet IN facets_loo.facets %]<li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html %][% END %]&amp;limit=[% facet.type_link_value %]:[% facet.facet_link_value %]" title="[% facet.facet_title_value |html %]">[% facet.facet_label_value %]</a> [% IF ( displayFacetCount ) %]([% facet.facet_count %])[% END %]</li>[% END %][% IF ( facets_loo.expandable ) %]
        <li class="showmore"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html %][% END %][% IF ( offset ) %]&amp;offset=[% offset %][% END %]&amp;expand=[% facets_loo.expand %]#[% facets_loo.type_id %]">Show more</a></li>
[% END %]
</ul></li>
[% END %]
</ul>
</div>
[% IF ( OPACResultsSidebar ) %]
<div id="opacresultssidebar">
[% OPACResultsSidebar %]
</div>
[% END %]
[% END %]
[% END %]
