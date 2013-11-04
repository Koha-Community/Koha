[% IF ( opacfacets ) %]
[% IF ( facets_loop ) %]
<div id="search-facets">
<h4>Refine your search</h4>
<ul>
    <li id="availability_facet">Availability<ul><li>[% IF ( available ) %]Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi_not_availablity %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by %][% END %]">Show all items</a>[% ELSE %]Limit to <a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by %][% END %]&amp;limit=available">currently available items.</a>[% END %]</li></ul>
	[% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %])</li>[% END %]
	</li>

	[% FOREACH facets_loo IN facets_loop %]
[% IF facets_loo.facets.size > 0 %]
	<li id="[% facets_loo.type_id %]">
[% facets_loo.type_label %]
[% IF facets_loo.type_label_Authors %]<span id="facet-authors">Authors</span>[% END %]
[% IF facets_loo.type_label_Titles %]<span id="facet-titles">Titles</span>[% END %]
[% IF facets_loo.type_label_Topics %]<span id="facet-topics">Topics</span>[% END %]
[% IF facets_loo.type_label_Places %]<span id="facet-places">Places</span>[% END %]
[% IF facets_loo.type_label_Series %]<span id="facet-series">Series</span>[% END %]
[% IF facets_loo.type_label_ItemTypes %]<span id="facet-itemtypes">Item types</span>[% END %]
[% IF ( facets_loo.type_label_HomeLibrary ) %]<span id="facet-home-libraries">Home libraries</span>[% END %]
[% IF ( facets_loo.type_label_HoldingLibrary ) %]<span id="facet-holding-libraries">Holding libraries</span>[% END %]
[% IF facets_loo.type_label_Location %]<span id="facet-locations">Locations</span>[% END %]
<ul>
  [% FOREACH facet IN facets_loo.facets %]
    <li>
      [% SET query_cgi_f = query_cgi | html %]
      [% SET limit_cgi_f = limit_cgi | html %]
      [% SET url = "/cgi-bin/koha/catalogue/search.pl?" _ query_cgi_f _ limit_cgi_f %]
      [% IF ( sort_by ) %]
        [% SET url = url _ "&amp;sort_by=" _ sort_by %]
      [% END %]
      [% facet.facet_link_value = BLOCK %][% facet.facet_link_value | uri %][% END %]
      [% IF facet.active %]
        [% SET url = url _ "&amp;nolimit=" _ facet.type_link_value _ ":" _ facet.facet_link_value %]
        <span class="facet-label">[% facet.facet_label_value %]</span>
        [<a href="[% url %]" title="Remove facet [% facet.facet_title_value | html %]">x</a>]
      [% ELSE %]
        [% SET url = url _ "&amp;limit=" _ facet.type_link_value _ ":" _ facet.facet_link_value %]
        <span class="facet-label"><a href="[% url %]" title="[% facet.facet_title_value |html %]">[% facet.facet_label_value %]</a></span>
        [% IF ( displayFacetCount ) %]
          <span class="facet-count"> ([% facet.facet_count %])</span>
        [% END %]
      [% END %]
    </li>
  [% END %]
  [% IF ( facets_loo.expandable ) %]
    <li class="showmore"><a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by %][% END %][% IF ( offset ) %]&amp;offset=[% offset %][% END %]&amp;expand=[% facets_loo.expand %]#[% facets_loo.type_id %]">Show more</a></li>
  [% END %]
</ul></li>
[% END %]
[% END %]
</ul>
</div>
[% END %]
[% END %]
