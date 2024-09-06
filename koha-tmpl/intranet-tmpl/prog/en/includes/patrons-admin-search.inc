[% USE raw %]
[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
<!-- patrons-admin-search.inc -->

[% WRAPPER tabs id= "header_search" %]
    [% WRAPPER tab_panels %]
        [% WRAPPER tab_panel tabname="patron_category_search" bt_active= 1 %]
            <form action="/cgi-bin/koha/admin/categories.pl" method="get">
                <div class="form-title">
                    <label class="control-label" for="category_search"><span class="control-text">Search patron categories</span> <i class="fa fa-fw fa-id-card" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="description" id="category_search" value="[% searchfield | html %]" placeholder="Search by patron category name" />
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        [% END # /tab_panel %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
        [% END %]

        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]
    [% END # /WRAPPER tab_panels %]

    [% WRAPPER tabs_nav %]
        [% WRAPPER tab_item tabname= "patron_category_search" bt_active= 1 %]
            <i class="fa fa-fw fa-id-card" aria-hidden="true"></i> <span class="tab-title">Search patron categories</span>
        [% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% WRAPPER tab_item tabname= "circ_search" %]
                <i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span>
            [% END %]
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% WRAPPER tab_item tabname= "catalog_search" %]
                <i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span>
            [% END %]
        [% END %]
    [% END # /WRAPPER tabs_nav %]
[% END # /WRAPPER tabs %]
<!-- /patrons-admin-search.inc -->
