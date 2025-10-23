[% USE raw %]
[% IF ( PAGE_NUMBERS ) %][% FILTER collapse %]
    <nav>
        <ul class="pagination">
            [% IF hits_to_paginate < total %]
                <h6>[% hits_to_paginate | html %] of [% total | html %] results loaded, refine your search to view other records</h6>
            [% END %]
            [% IF ( previous_page_offset.defined ) %]
                <li class="page-item">
                    <a
                        class="page-link"
                        href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | html %][% END %]"
                        ><i class="fa fa-fw fa-angle-double-left"></i> First</a
                    >
                </li>
                <!-- Row of numbers corresponding to search result pages -->
                <li class="page-item">
                    <a
                        class="page-link"
                        href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% previous_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | html %][% END %]"
                        ><i class="fa fa-fw fa-angle-left"></i> Previous</a
                    >
                </li>
            [% END %]
            [% FOREACH PAGE_NUMBER IN PAGE_NUMBERS %]
                [% IF ( PAGE_NUMBER.highlight ) %]
                    <li class="page-item active" aria-current="page">
                        <a href="#" class="page-link" aria-disabled="true" tabindex="-1">[% PAGE_NUMBER.pg | html %]</a>
                    </li>
                [% ELSE %]
                    <li class="page-item">
                        <a
                            class="page-link"
                            href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% PAGE_NUMBER.offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | html %][% END %]"
                            >[% PAGE_NUMBER.pg | html %]</a
                        >
                    </li>
                [% END %]
            [% END %]
            [% IF ( next_page_offset ) %]
                <li class="page-item">
                    <a
                        class="page-link"
                        href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% next_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | html %][% END %]"
                        >Next <i class="fa fa-fw fa-angle-right"></i
                    ></a>
                </li>
                <li class="page-item">
                    <a
                        class="page-link"
                        href="/cgi-bin/koha/catalogue/search.pl?[% query_cgi | $raw %][% limit_cgi | $raw %]&amp;offset=[% last_page_offset | html %][% IF ( sort_by ) %]&amp;sort_by=[% sort_by |url %][% END %][% IF results_per_page %]&amp;count=[% results_per_page | html %][% END %]"
                        >Last <i class="fa fa-fw fa-angle-double-right"></i
                    ></a>
                </li>
            [% END %]
        </ul>
        <!-- /.pagination -->
    </nav>
[% END %][% END %]
