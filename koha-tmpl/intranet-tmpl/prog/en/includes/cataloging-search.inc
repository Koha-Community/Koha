[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
[% PROCESS 'patronfields.inc' %]
<!-- Begin Patrons Resident Search Box -->

<div id="header_search">

    <div id="addbooks_search" class="residentsearch">
        <form name="search" action="addbooks.pl">
            <span class="form-title">
                <label class="control-label">Cataloging search</label>
            </span>

            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="q" id="cat_search" placeholder="Search the catalog and the reservoir" size="40" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'checkin-search-box.inc' %]
    [% INCLUDE 'renew-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Cataloging search" href="#addbooks_search" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Cataloging search</span></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check in" href="#checkin_search" class="keep_text"><i class="fa fa-download"></i> <span class="tab-title">Check in</span></a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Renew" href="#renew_search" class="keep_text"><i class="fa fa-retweet"></i> <span class="tab-title">Renew</span></a></li>[% END %]
        <li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a></li>
    </ul>
</div><!-- /header_search -->
<!-- End Main page Resident Search Box -->
