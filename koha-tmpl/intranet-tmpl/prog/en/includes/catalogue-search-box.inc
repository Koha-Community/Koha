[% USE Branches %]
[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
        <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
            <span class="form-title">
                <label class="control-label">Search catalog</label>
            </span>
            <span class="form-content">
                [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %]
                    [% INCLUDE 'search_indexes.inc' $header_pulldown = 1 %]
                [% END %]
                [% IF ( Koha.Preference('RetainCatalogSearchTerms') ) %]
                    <input type="text" name="q" id="search-form" size="20" value="[% ms_value | html %]" title="Enter the terms you wish to search for." class="query form-text head-searchbox" />
                [% ELSE %]
                    <input type="text" name="q" id="search-form" size="20" title="Enter the terms you wish to search for." class="query form-text head-searchbox" />
                [% END %]

                [% IF ( Koha.Preference('IntranetAddMastheadLibraryPulldown') ) %]
                    <select id="select_library" name="limit" style="margin-left:5px;">
                        <option value="">All libraries</option>
                        [% PROCESS options_for_libraries prefix => "branch:" libraries => Branches.all( selected => branch_limit ) %]
                    </select>
                [% END %]
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
[% END %]
