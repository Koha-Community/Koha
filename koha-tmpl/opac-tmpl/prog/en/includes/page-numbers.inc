[% IF ( PAGE_NUMBERS ) %]<div class="pages">
    <!-- Row of numbers corresponding to search result pages -->
        [% IF ( previous_page_offset ) %]<a class="nav" href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% previous_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |htm l%][% END %]">&lt;&lt; Previous</a>[% END %]
    [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %][% IF ( PAGE_NUMBER.highlight ) %]<span class="current">[% PAGE_NUMBER.pg %]</span>[% ELSE %]        <a class="nav" href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% PAGE_NUMBER.offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html%][% END %]">[% PAGE_NUMBER.pg %]</a>[% END %]
    [% END %]
        [% IF ( next_page_offset ) %]<a class="nav" href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% next_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html %][% END %]">Next &gt;&gt;</a>[% END %] </div>[% END %]
