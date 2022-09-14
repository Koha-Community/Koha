[% USE Koha %]
<!-- Begin Main page Resident Search Box -->

<div id="header_search">

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'renew-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Renew" href="#renew_search" class="keep_text"><i class="fa fa-retweet"></i> <span class="tab-title">Renew</span></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a></li>[% END %]
    </ul>
</div><!-- /header_search -->
<!-- End Main page Resident Search Box -->

