[% IF ( PAGE_NUMBERS ) %]
    <div class="pagination pagination-small noprint">
        <ul>
        [% IF ( previous_page_offset.defined ) %]
            <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% previous_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html %][% END %]">&laquo; Previous</a></li>
        [% END %]
        [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
            [% IF ( PAGE_NUMBER.highlight ) %]
                <li class="active"><a href="#">[% PAGE_NUMBER.pg %]</a></li>
            [% ELSE %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% PAGE_NUMBER.offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html%][% END %]">[% PAGE_NUMBER.pg %]</a></li>
            [% END %]
        [% END %]
        [% IF ( next_page_offset ) %]
            <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;offset=[% next_page_offset %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |html %][% END %]">Next &raquo;</a></li>
        [% END %]
        </ul>
    </div>
[% END %]
