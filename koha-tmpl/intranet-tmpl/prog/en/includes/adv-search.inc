[% USE raw %]
[% PROCESS 'html_helpers.inc' %]
<!-- adv-search.inc -->
[% WRAPPER tabs id= "header_search" %]
    [% WRAPPER tab_panels %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' bs_tab_active= 1 %]
            [% INCLUDE 'checkin-search-box.inc' %]
            [% INCLUDE 'renew-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_borrowers_edit_borrowers ) %]
            [% INCLUDE 'member-search-box.inc' %]
        [% END %]
    [% END %]

    [% WRAPPER tabs_nav %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% WRAPPER tab_item tabname= "circ_search" bt_active= 1 %]
                <i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span>
            [% END %]
            [% WRAPPER tab_item tabname= "checkin_search" %]
                <i class="fa fa-fw fa-download" aria-hidden="true"></i> <span class="tab-title">Check in</span>
            [% END %]
            [% WRAPPER tab_item tabname= "renew_search" %]
                <i class="fa fa-fw fa-retweet" aria-hidden="true"></i> <span class="tab-title">Renew</span>
            [% END %]
        [% END %]
        [% IF ( CAN_user_borrowers_edit_borrowers ) %]
            [% WRAPPER tab_item tabname= "patron_search" %]
                <i class="fa fa-fw fa-id-card" aria-hidden="true"></i> <span class="tab-title">Search patrons</span>
            [% END %]
        [% END %]
    [% END # /WRAPPER tabs_nav %]
[% END # /WRAPPER tabs %]
<!-- adv-search.inc -->
