[% USE AuthorisedValues %]
[% IF ( opacfacets ) %]
[% IF ( facets_loop ) %]
<div id="search-facets">
<h4>Refine your search</h4>
<ul>
    <li id="availability_facet">Availability<ul><li>[% IF ( available ) %]<strong>Showing only available items</strong></li><li><a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | uri %][% limit_cgi_not_availablity | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">Show all items</a>[% ELSE %]<a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | html %][% limit_cgi | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]&amp;limit=available">Limit to currently available items</a>[% END %]</li></ul>
	[% IF ( related ) %] <li>(related searches: [% FOREACH relate IN related %][% relate.related_search | html %][% END %])</li>[% END %]
	</li>

	[% FOREACH facets_loo IN facets_loop %]
[% IF facets_loo.facets.size > 0 %]
	<li id="[% facets_loo.type_id | html %]">
[% facets_loo.type_label | html %]
[% IF facets_loo.type_label_Authors %]<span id="facet-authors">Authors</span>[% END %]
[% IF facets_loo.type_label_Titles %]<span id="facet-titles">Titles</span>[% END %]
[% IF facets_loo.type_label_Topics %]<span id="facet-topics">Topics</span>[% END %]
[% IF facets_loo.type_label_Places %]<span id="facet-places">Places</span>[% END %]
[% IF facets_loo.type_label_Series %]<span id="facet-series">Series</span>[% END %]
[% IF facets_loo.type_label_ItemTypes %]<span id="facet-itemtypes">Item types</span>[% END %]
[% IF ( facets_loo.type_label_HomeLibrary ) %]<span id="facet-home-libraries">Home libraries</span>[% END %]
[% IF ( facets_loo.type_label_HoldingLibrary ) %]<span id="facet-holding-libraries">Holding libraries</span>[% END %]
[% IF facets_loo.type_label_Location %]<span id="facet-locations">Locations</span>[% END %]
[% IF facets_loo.type_label_CollectionCodes %]<span id="facet-collections">Collections</span>[% END %]
<ul>
  [% SET url = "/cgi-bin/koha/catalogue/search.pl?" _ query_cgi _ limit_cgi %]
  [% IF ( sort_by ) %]
    [% url = BLOCK %][% url | html %][% "&amp;sort_by=" _ sort_by |url %][% END %]
  [% END %]
  [% FOREACH facet IN facets_loo.facets %]
  [% IF facets_loo.type_label_CollectionCodes %][% SET facet.facet_label_value = AuthorisedValues.GetByCode('CCODE',facet.facet_label_value,0) || facet.facet_label_value %][% END %]
    <li>
      [% IF facet.active %]
        [% SET local_url = url _ "&amp;nolimit=" _ facet.type_link_value _ ":" _ facet.facet_link_value %]
        <span class="facet-label">[% facet.facet_label_value | html %]</span>
        [<a href="[% local_url | uri %]" title="Remove facet [% facet.facet_link_value | html %]">x</a>]
      [% ELSE %]
        [% SET local_url = url _ "&amp;limit=" _ facet.type_link_value _ ":" _ facet.facet_link_value %]
        <span class="facet-label"><a href="[% local_url | uri %]" title="[% facet.facet_title_value | html %]">[% facet.facet_label_value | html %]</a></span>
        [% IF ( displayFacetCount ) %]
          <span class="facet-count"> ([% facet.facet_count | html %])</span>
        [% END %]
      [% END %]
    </li>
  [% END %]
  [% IF ( facets_loo.expandable ) %]
      <li class="showmore">
          <a href="[% url | uri %][% IF offset %]&amp;offset=[% offset |url %][% END %]&amp;expand=[% facets_loo.expand |url %]#[% facets_loo.type_id |url %]">Show more</a>
      </li>
  [% END %]
</ul></li>
[% END %]
[% END %]
</ul>
</div>
[% END %]
[% END %]
