[% IF ( PAGE_NUMBERS ) %]
    <div class="pagination pagination-small noprint">
     [% IF hits_to_paginate < total %]<h6>[% hits_to_paginate | html %] of [% total | html %] results loaded, refine your search to view other records</h6>[% END %]
        <ul>
            [% IF ( previous_page_offset.defined ) %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | html %][% limit_cgi | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | html %][% END %]">First</a></li>
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | html %][% limit_cgi | html %]&amp;offset=[% previous_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | html %][% END %]">&laquo; Previous</a></li>
            [% END %]
            [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
                [% IF ( PAGE_NUMBER.highlight ) %]
                    <li class="active"><a href="#">[% PAGE_NUMBER.pg | html %]</a></li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | html %][% limit_cgi | html %]&amp;offset=[% PAGE_NUMBER.offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | html %][% END %]">[% PAGE_NUMBER.pg | html %]</a></li>
                [% END %]
            [% END %]
            [% IF ( next_page_offset ) %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | html %][% limit_cgi | html %]&amp;offset=[% next_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | html %][% END %]">Next &raquo;</a></li>
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | html %][% limit_cgi | html %]&amp;offset=[% last_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | html %][% END %]">Last</a></li>
            [% END %]
        </ul>
    </div>
[% END %]
