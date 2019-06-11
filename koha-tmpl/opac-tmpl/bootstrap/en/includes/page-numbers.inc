[% IF ( PAGE_NUMBERS ) %]
    <div class="pagination pagination-small noprint">
     [% IF hits_to_paginate < total %]<h6>[% hits_to_paginate | html %] of [% total | html %] results loaded, refine your search to view other records</h6>[% END %]
        <ul>
            [% IF ( previous_page_offset.defined ) %]
                <li class="page-first"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]"><i class="fa fa-fw fa-angle-double-left"></i>  First</a></li>
                <li class="page-prev"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% previous_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]"> <i class="fa fa-fw fa-angle-left"></i>  Previous</a></li>
            [% END %]
            [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
                [% IF ( PAGE_NUMBER.highlight ) %]
                    <li class="active"><a clas="page-num current" href="#">[% PAGE_NUMBER.pg | html %]</a></li>
                [% ELSE %]
                    <li class="page-num"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% PAGE_NUMBER.offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">[% PAGE_NUMBER.pg | html %]</a></li>
                [% END %]
            [% END %]
            [% IF ( next_page_offset ) %]
                <li class="page-next"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% next_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Next <i class="fa fa-fw fa-angle-double-right"></i></a></li>
                <li class="page-last"><a href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% last_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %]">Last <i class="fa fa-fw fa-angle-double-right"></i></a></li>
            [% END %]
        </ul>
    </div>
[% END %]
