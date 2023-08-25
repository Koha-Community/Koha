[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
[% PROCESS 'patronfields.inc' %]
<!-- cataloging-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">

        <div id="addbooks_search" role="tabpanel" class="tab-pane active">
            <form name="search" action="addbooks.pl">
                <div class="form-title">
                    <label class="control-label" for="cat_search"><span class="control-text">Cataloging search</span> <i class="fa fa-fw fa-search" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="q" id="cat_search" placeholder="Search the catalog and the reservoir" size="40" />
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

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
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation" class="active">
                <a title="Cataloging search" href="#addbooks_search" aria-controls="addbooks_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Cataloging search</span></a>
            </li>
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span></a>
            </li>
            <li role="presentation">
                <a title="Check in" href="#checkin_search" aria-controls="checkin_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-download" aria-hidden="true"></i> <span class="tab-title">Check in</span></a>
            </li>
            <li role="presentation">
                <a title="Renew" href="#renew_search" aria-controls="renew_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-retweet" aria-hidden="true"></i> <span class="tab-title">Renew</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- /cataloging-search.inc -->
