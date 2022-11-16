[% USE Koha %]
[% USE Branches %]
[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
        <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
            <span class="form-title">
                <label class="control-label">Search catalog</label>
            </span>

            <span class="form-content">
                [% IF ( Koha.Preference('RetainCatalogSearchTerms') ) %]
                    <input type="text" name="q" id="search-form" size="20" value="[% ms_value | html %]" title="Enter the terms you wish to search for." class="query form-text head-searchbox form-control" placeholder="Enter search keywords" />
                [% ELSE %]
                    <input type="text" name="q" id="search-form" size="20" title="Enter the terms you wish to search for." class="query form-text head-searchbox form-control" placeholder="Enter search keywords" />
                [% END %]

                [% IF Koha.Preference('IntranetCatalogSearchPulldown') || Koha.Preference('IntranetAddMastheadLibraryPulldown') %]
                    <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
                [% END %]
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <div class="form-extra-content">
                [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %]
                    <div>
                        <label for="idx">Search index</label>
                        [% INCLUDE 'search_indexes.inc' $header_pulldown = 1 %]
                    </div>
                [% END %]

                [% IF ( Koha.Preference('IntranetAddMastheadLibraryPulldown') ) %]
                    <div>
                        <label for="select_library">Library</label>
                        <select id="select_library" name="limit">
                            <option value="">All libraries</option>
                            [% PROCESS options_for_libraries prefix => "branch:" libraries => Branches.all( selected => branch_limit ) %]
                        </select>
                    </div>
                [% END %]
            </div>
        </form>
    </div>
[% END %]
