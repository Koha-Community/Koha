<!-- Begin main page resident search box -->
<div id="header_search">

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'checkin-search-box.inc' %]
    [% INCLUDE 'renew-search-box.inc' %]
    [% INCLUDE 'member-search-box.inc' %]

    <ul>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check in" href="#checkin_search" class="keep_text"><i class="fa fa-download"></i> <span class="tab-title">Check in</span></a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Renew" href="#renew_search" class="keep_text"><i class="fa fa-retweet"></i> <span class="tab-title">Renew</span></a></li>[% END %]
        [% IF ( CAN_user_borrowers_edit_borrowers ) %]<li><a title="Search patrons" href="#patron_search" class="keep_text"><i class="fa fa-fw fa-id-card-o"></i> <span class="tab-title">Search patrons</span></a></li>[% END %]
    </ul>
</div><!-- /#header_search -->

<!-- End advanced search page resident search box -->
