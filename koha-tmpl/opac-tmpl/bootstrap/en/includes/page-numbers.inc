[% IF ( PAGE_NUMBERS ) %]
    <div class="pagination pagination-small noprint">
        <ul>
        [% IF ( previous_page_offset.defined ) %]
            <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi %][% limit_cgi %]&amp;offset=[% previous_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by %][% END %]">&laquo; Previous</a></li>
        [% END %]
        [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
            [% IF ( PAGE_NUMBER.highlight ) %]
                <li class="active"><a href="#">[% PAGE_NUMBER.pg %]</a></li>
            [% ELSE %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi %][% limit_cgi %]&amp;offset=[% PAGE_NUMBER.offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by%][% END %]">[% PAGE_NUMBER.pg %]</a></li>
            [% END %]
        [% END %]
        [% IF ( next_page_offset ) %]
            <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi %][% limit_cgi %]&amp;offset=[% next_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by %][% END %]">Next &raquo;</a></li>
        [% END %]
        </ul>
    </div>
[% END %]
