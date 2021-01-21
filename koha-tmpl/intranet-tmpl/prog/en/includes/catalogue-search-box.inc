[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
        <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
            <label class="tip" for="search-form">Enter search keywords:</label>
                [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %]
                    [% INCLUDE 'search_indexes.inc' $header_pulldown = 1 %]
                [% END %]
            <input type="text" name="q" id="search-form" size="40" value="[% ms_value | html %]" title="Enter the terms you wish to search for." class="query form-text head-searchbox" />
            <input type="submit" value="Submit"  class="submit" />
        </form>
    </div>
[% END %]
