[% IF ( PAGE_NUMBERS ) %]<nav><ul class="pagination">
 [% IF Koha.Preference('SearchEngine') == 'Elasticsearch' %]<h6>10,000 results loaded, refine your search to view other records</h6>[% END %]
    [% IF ( previous_page_offset.defined ) %]
        <li><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">First</a></li>
        <!-- Row of numbers corresponding to search result pages -->
        <li><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% previous_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">&lt;&lt; Previous</a></li>
    [% END %]
    [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
        [% IF ( PAGE_NUMBER.highlight ) %]
            <li class="active"><span>[% PAGE_NUMBER.pg %]</span></li>
        [% ELSE %]
            <li><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% PAGE_NUMBER.offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">[% PAGE_NUMBER.pg %]</a></li>
        [% END %]
    [% END %]
    [% IF ( next_page_offset ) %]
        <li><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% next_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">Next &gt;&gt;</a></li>
        <li><a class="nav" href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% last_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %]">Last</a></li>
    [% END %]
</ul></nav>[% END %]
