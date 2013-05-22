[% IF facets_loop %]
  <div id="search-facets">
    <h4>Refine your search</h4>
    <ul>
      [% FOR facets IN facets_loop %]
        <li>
          [% facets.label %]
          <ul class="facets_list">
            [% FOR value IN facets.values %]
              <li>
                [% IF ( value.active ) %]
                  [% value.lib %] ([% value.count %])
                  [% SET url = "/cgi-bin/koha/opac-search.pl?" %]
                  [% SET first = 1 %]
                  [% FOR p IN follower_params %]
                    [% IF p.var != 'filters' %]
                      [% UNLESS first %]
                        [% SET url = url _ '&' %]
                      [% END %]
                      [% SET first = 0 %]
                      [% SET url = url _ p.var _ '=' _ p.val %]
                    [% END %]
                  [% END %]
                  [% FOR f IN filters %]
                    [% UNLESS f.var == facets.indexname && f.val == value.value %]
                      [% SET url = url _ '&filters=' _ f.var _ ':&quot;' _ f.val _ '&quot;' %]
                    [% END %]
                  [% END %]
                  [<a href="[% url |url %]">x</a>]
                [% ELSE %]
                  [% SET url = "/cgi-bin/koha/opac-search.pl?" %]
                  [% SET first = 1 %]
                  [% FOR p IN follower_params %]
                    [% IF p.var != 'filters' %]
                      [% UNLESS first %]
                        [% SET url = url _ '&' %]
                      [% END %]
                      [% SET first = 0 %]
                      [% SET url = url _ p.var _ '=' _ p.val %]
                    [% END %]
                  [% END %]
                  [% FOR f IN filters %]
                    [% SET url = url _ '&filters=' _ f.var _ ':&quot;' _ f.val _ '&quot;' %]
                  [% END %]
                  [% SET url = url _ '&filters=' _ facets.indexname _ ':&quot;' _ value.value _ '&quot;' %]

                  <a href="[% url |url %]">[% value.lib %]</a> ([% value.count %])
                [% END %]
              </li>
            [% END %]
          </ul>
        </li>
      [% END %]
    </ul>
</div>
[% END %]
