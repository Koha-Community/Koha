<!-- adv-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' bs_tab_active= 1 %]
            [% INCLUDE 'checkin-search-box.inc' %]
            [% INCLUDE 'renew-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_borrowers_edit_borrowers ) %]
            [% INCLUDE 'member-search-box.inc' %]
        [% END %]

    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation" class="active">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" aria-expanded="true" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a>
            </li>
            <li role="presentation">
                <a title="Check in" href="#checkin_search" aria-controls="checkin_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-download"></i> <span class="tab-title">Check in</span></a>
            </li>
            <li role="presentation">
                <a title="Renew" href="#renew_search" aria-controls="renew_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-retweet"></i> <span class="tab-title">Renew</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_borrowers_edit_borrowers ) %]
            <li role="presentation">
                <a title="Search patrons" href="#patron_search" aria-controls="patron_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-id-card"></i> <span class="tab-title">Search patrons</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- adv-search.inc -->
