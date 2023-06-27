[% USE Koha %]
[% USE Branches %]
[% IF ( CAN_user_catalogue ) %]
    <!-- catalogue-search-box.inc -->
    [% IF( bs_tab_active ) %]
        <div id="catalog_search" role="tabpanel" class="tab-pane active">
    [% ELSE %]
        <div id="catalog_search" role="tabpanel" class="tab-pane">
    [% END %]
        <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
            <div class="form-title">
                <label class="control-label"><span class="control-text">Search catalog</span> <i class="fa fa-fw fa-search" aria-hidden="true"></i></label>
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
    <!-- /catalogue-search-box.inc -->
[% END %]
