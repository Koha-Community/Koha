[% IF ( PAGE_NUMBERS ) %]
    <div class="pagination pagination-small noprint">
     [% IF hits_to_paginate < total %]<h6>[% hits_to_paginate | html %] of [% total | html %] results loaded, refine your search to view other records</h6>[% END %]
        <ul>
            [% IF ( previous_page_offset.defined ) %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | uri %][% limit_cgi | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">First</a></li>
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | uri %][% limit_cgi | uri %]&amp;offset=[% previous_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">&laquo; Previous</a></li>
            [% END %]
            [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
                [% IF ( PAGE_NUMBER.highlight ) %]
                    <li class="active"><a href="#">[% PAGE_NUMBER.pg | html %]</a></li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | uri %][% limit_cgi | uri %]&amp;offset=[% PAGE_NUMBER.offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">[% PAGE_NUMBER.pg | html %]</a></li>
                [% END %]
            [% END %]
            [% IF ( next_page_offset ) %]
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | uri %][% limit_cgi | uri %]&amp;offset=[% next_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Next &raquo;</a></li>
                <li><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | uri %][% limit_cgi | uri %]&amp;offset=[% last_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Last</a></li>
            [% END %]
        </ul>
    </div>
[% END %]
