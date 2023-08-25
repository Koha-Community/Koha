<!-- prefs-admin-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="syspref_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/admin/preferences.pl">
                <input type="hidden" name="tab" value="[% last_tab | html %]" />
                <input type="hidden" name="op" value="search" />

                <div class="form-title">
                    <label class="control-label" for="searchfield"><span class="control-text">Search system preferences</span> <i class="fa fa-fw fa-cogs" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="" placeholder="System preference search">
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
        <a title="Search system preferences" href="#syspref_search" aria-controls="syspref_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-cogs" aria-hidden="true"></i> <span class="tab-title">Search system preferences</span></a>
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- /prefs-admin-search.inc -->
