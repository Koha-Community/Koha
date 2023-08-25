[% USE Koha %]
<!-- z3950-admin-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="z3950_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/admin/z3950servers.pl" method="post">
                <div class="form-title">
                    <label class="control-label" for="searchfield"><span class="control-text">Search Z39.50/SRU servers</span> <i class="fa fa-fw fa-search" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="[% searchfield | html %]" placeholder="Z39.50/SRU server search" />
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
            <a title="Search Z39.50/SRU servers" href="#z3950_search" aria-controls="z3950_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-search" aria-hidden="true"></i> <span class="tab-title">Search Z39.50/SRU servers</span></a>
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
<!-- /z3950-admin-search.inc -->
