[% USE raw %]
[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
[% PROCESS 'patronfields.inc' %]
<!-- cataloging-search.inc -->
[% WRAPPER tabs id="header_search" %]
    [% WRAPPER tab_panels %]
        [% WRAPPER tab_panel tabname="addbooks_search" bt_active= 1 %]
            <form name="search" action="addbooks.pl" method="get">
                <div class="form-title">
                    <label class="control-label" for="cat_search"><span class="control-text">Cataloging search</span> <i class="fa fa-fw fa-search" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="q" id="cat_search" placeholder="Search the catalog and the reservoir" size="40" />
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        [% END # /tab_panel %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
            [% INCLUDE 'checkin-search-box.inc' %]
            [% INCLUDE 'renew-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]
    [% END # /tab_panels %]
    [% WRAPPER tabs_nav %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation" class="active">
                [% WRAPPER tab_item tabname= "addbooks_search" bt_active= 1 %]
                    <i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Cataloging search</span>
                [% END %]
                [% WRAPPER tab_item tabname= "circ_search" %]
                    <i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span>
                [% END %]
                [% WRAPPER tab_item tabname= "checkin_search" %]
                    <i class="fa fa-fw fa-download" aria-hidden="true"></i> <span class="tab-title">Check in</span>
                [% END %]
                [% WRAPPER tab_item tabname= "renew_search" %]
                    <i class="fa fa-fw fa-retweet" aria-hidden="true"></i> <span class="tab-title">Renew</span>
                [% END %]
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% WRAPPER tab_item tabname= "catalog_search" %]
                <i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span>
            [% END %]
        [% END %]
    [% END # /tabs_nav %]
[% END # /WRAPPER tabs %]
<!-- /cataloging-search.inc -->
