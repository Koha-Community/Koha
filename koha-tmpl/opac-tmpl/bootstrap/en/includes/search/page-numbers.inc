[% IF ( PAGE_NUMBERS ) %]
  <div class="pages">
   [% IF Koha.Preference('SearchEngine') == 'Elasticsearch' %]<h6>10000 results loaded, refine your search to view other records</h6>[% END %]
    [% IF ( previous_page ) %]
      <a class="nav" href="?[% FOREACH fp IN follower_params %][% fp.var |url %]=[% fp.val |url %]&amp;[% END %]page=[% previous_page |url %]">&lt;&lt; Previous</a>
    [% END %]
    [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
      [% IF ( PAGE_NUMBER.current ) %]
        <span class="current">[% PAGE_NUMBER.page %]</span>
      [% ELSE %]
        <a class="nav" href="?[% FOREACH fp IN follower_params %][% fp.var |url %]=[% fp.val |url %]&amp;[% END %]page=[% PAGE_NUMBER.page |url %]">[% PAGE_NUMBER.page %]</a>
      [% END %]
    [% END %]
    [% IF ( next_page ) %]
      <a class="nav" href="?[% FOREACH fp IN follower_params %][% fp.var |url %]=[% fp.val |url %]&amp;[% END %]page=[% next_page |url %]">Next &gt;&gt;</a>
    [% END %]
  </div>
[% END %]
