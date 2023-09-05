[% USE raw %]
[% USE AuthorisedValues %]
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
    <li id="availability_facet">Availability<ul><li>[% IF ( available ) %]<strong>Showing only available items</strong></li><li><a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi_not_availablity | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Show all items</a>[% ELSE %]<a href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]&amp;limit=available">Limit to records with available items</a>[% END %]</li></ul>
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
[% IF facets_loo.type_label_Language %]<span id="facet-languages">Languages</span>[% END %]
<ul>
  [% SET url = "/cgi-bin/koha/catalogue/search.pl?" _ query_cgi _ limit_cgi %]
  [% IF ( sort_by ) %]
    [% url = BLOCK %][% url | $raw %][% "&sort_by=" _ sort_by | url %][% END %]
  [% END %]
  [% IF ( results_per_page ) %]
    [% url = BLOCK %][% url | $raw %][% "&count=" _ results_per_page | url %][% END %]
  [% END %]
  [% FOREACH facet IN facets_loo.facets %]
  [% IF facets_loo.type_label_CollectionCodes %][% SET facet.facet_label_value = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.ccode', authorised_value => facet.facet_label_value ) || facet.facet_label_value %][% END %]
  [% IF facets_loo.type_label_Language %][% SET facet.facet_label_value = Languages.GetByISOCode(lang,facet.facet_label_value) || facet.facet_label_value %][% END %]
  [% IF loop.count > 5 && !facet.active %]
    <li class="collapsible-facet" style="display:none">
  [% ELSE %]
    <li>
  [% END %]
      [% IF facet.active %]
        [% local_url = BLOCK %][% url | $raw %][% "&nolimit=" _  facet.type_link_value _ ":" _ facet.facet_link_value | url %][% END %]
        <span class="facet-label">[% facet.facet_label_value | html %]</span>
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
</ul></li>
[% END %]
[% END %]
</ul>
</div>
[% END %]
[% END %]
