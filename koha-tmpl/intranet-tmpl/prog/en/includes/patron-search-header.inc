[% USE raw %]
[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]

<!-- patron-search-header.inc -->
[% WRAPPER tabs id="header_search" %]
    [% WRAPPER tab_panels %]
        [% INCLUDE 'member-search-box.inc' bs_tab_active= 1 %]

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
        [% WRAPPER tab_item tabname="patron_search" bt_active= 1 %]
            <i class="fa fa-fw fa-id-card" aria-hidden="true"></i> <span class="tab-title">Search patrons</span>
        [% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% WRAPPER tab_item tabname= "circ_search" %]
                <i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Check out</span></span>
            [% END %]
            [% WRAPPER tab_item tabname= "checkin_search" %]
                <i class="fa fa-fw fa-download" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Check in</span></span>
            [% END %]
            [% WRAPPER tab_item tabname= "renew_search" %]
                <i class="fa fa-fw fa-retweet" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Renew</span></span>
            [% END %]
        [% END %]

        [% IF ( CAN_user_catalogue ) %]
            [% WRAPPER tab_item tabname= "catalog_search" %]
                <i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Search catalog</span></span>
            [% END %]
        [% END %]
    [% END # /tabs_nav %]
[% END # /WRAPPER tabs %]
<!-- /patron-search-header.inc -->
