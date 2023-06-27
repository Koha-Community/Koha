<!-- patron-search-header.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        [% INCLUDE 'member-search-box.inc' bs_tab_active= 1 %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
            [% INCLUDE 'checkin-search-box.inc' %]
            [% INCLUDE 'renew-search-box.inc' %]
        [% END %]

        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]
    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search patrons" href="#patron_search" aria-controls="patron_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-id-card" aria-hidden="true"></i> <span class="tab-title">Search patrons</span></a>
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Check out</span></span></a>
            </li>
            <li role="presentation">
                <a title="Check in" href="#checkin_search" aria-controls="checkin_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-download" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Check in</span></span></a>
            </li>
            <li role="presentation">
                <a title="Renew" href="#renew_search" aria-controls="renew_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-retweet" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Renew</span></span></a>
            </li>
        [% END %]

        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title"><span class="tab-title">Search catalog</span></span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- /patron-search-header.inc -->
