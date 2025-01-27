[% USE raw %]
[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
[% USE Branches %]
<!-- catalogue-search-box.inc -->
[% WRAPPER tab_panel tabname="catalog_search" bt_active= bs_tab_active %]
    <form action="/cgi-bin/koha/catalogue/search.pl" method="get" id="cat-search-block">
        <div class="form-title">
            <label class="control-label" for="search-form"><span class="control-text">Search catalog</span> <i class="fa fa-fw fa-search" aria-hidden="true"></i></label>
        </div>

        <div class="form-content">
            [% IF ( Koha.Preference('RetainCatalogSearchTerms') ) %]
                <input type="text" name="q" id="search-form" size="20" value="[% ms_value | html %]" title="Enter the terms you wish to search for." class="query form-text head-searchbox form-control" placeholder="Enter search keywords" />
            [% ELSE %]
                <input type="text" name="q" id="search-form" size="20" title="Enter the terms you wish to search for." class="query form-text head-searchbox form-control" placeholder="Enter search keywords" />
            [% END %]

            [% IF Koha.Preference('IntranetCatalogSearchPulldown') || Koha.Preference('IntranetAddMastheadLibraryPulldown') %]
                <button type="button" class="form-extra-content-toggle" title="More options"><i class="form-extra-content-icon fa-solid fa-sliders" aria-hidden="true"></i></button>
            [% END %]
        </div>
        <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>

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
[% END # /tab_panel %]
<!-- /catalogue-search-box.inc -->
