[% USE raw %]
[% IF ( PAGE_NUMBERS ) %]
    <nav class="pagination pagination-sm noprint" aria-label="Search results pagination">
        [% IF hits_to_paginate < total %]
            <span class="h6">[% hits_to_paginate | html %] of [% total | html %] results loaded, refine your search to view other records</span>
        [% END %]
        <ul class="pagination">
            [% IF ( previous_page_offset.defined ) %]
                <li class="page-item">
                    <a class="page-link" href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | uri %][% END %]" aria-label="Go to the first page"><i class="fa fa-fw fa-angle-double-left" aria-hidden="true"></i>  First</a>
                </li>
                <li class="page-item">
                    <a class="page-link" href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% previous_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | uri %][% END %]" aria-label="Go to the previous page"> <i class="fa fa-fw fa-angle-left" aria-hidden="true"></i>  Previous</a>
                </li>
            [% END %]
            [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
                [% IF ( PAGE_NUMBER.highlight ) %]
                    <li class="page-item disabled">
                        <a class="page-link" href="#" aria-disabled="true" aria-label="Current page: Page [% PAGE_NUMBER.pg | html %]" aria-current="true">[% PAGE_NUMBER.pg | html %]</a>
                    </li>
                [% ELSE %]
                    <li class="page-item">
                        <a class="page-link" href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% PAGE_NUMBER.offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | uri %][% END %]" aria-label="Go to page [% PAGE_NUMBER.pg | html %]">[% PAGE_NUMBER.pg | html %]</a>
                    </li>
                [% END %]
            [% END %]
            [% IF ( next_page_offset ) %]
                <li class="page-item">
                    <a class="page-link" href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% next_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | uri %][% END %]" aria-label="Go to the next page">Next <i class="fa fa-fw fa-angle-double-right" aria-hidden="true"></i></a>
                </li>
                <li class="page-item">
                    <a class="page-link" href="/cgi-bin/koha/opac-search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% last_page_offset | uri %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by | uri %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | uri %][% END %]" aria-label="Go to the last page">Last <i class="fa fa-fw fa-angle-double-right" aria-hidden="true"></i></a>
                </li>
            [% END %]
        </ul>
    </nav>
[% END %]
