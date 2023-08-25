[% USE Koha %]
<!-- cities-admin-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="city_search" role="tabpanel" class="tab-pane active">
            <form action="[% script_name | html %]" method="post">
                <div class="form-title">
                    <label class="control-label" for="city_name_filter"><span class="control-text">Search cities</span> <i class="fa fa-fw fa-building" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="city_name_filter" id="city_name_filter" value="[% city_name_filter | html %]" placeholder="City search" />
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]

    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search cities" href="#city_search" aria-controls="city_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-building" aria-hidden="true"></i> <span class="tab-title">Search cities</span></a>
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- cities-admin-search.inc -->
