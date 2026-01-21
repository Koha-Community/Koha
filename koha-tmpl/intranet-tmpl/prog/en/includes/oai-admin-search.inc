[% USE Koha %]
<!-- oai-admin-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="oai_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/admin/oai_servers.pl" method="get">
                <div class="form-title">
                    <label class="control-label" for="searchfield">Search OAI repositories</label>
                </div>

                <div class="form-content">
                    <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="[% searchfield | html %]" placeholder="OAI repository search" />
                </div>
                <input type="hidden" name="op" value="search" />
                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %] </div
    ><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search OAI repositories" href="#oai_search" aria-controls="z3950_search" role="tab" aria-expanded="true" data-bs-toggle="tab" class="keep_text"
                ><i class="fa fa-search"></i> <span class="tab-title">Search OAI repositories</span></a
            >
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-bs-toggle="tab" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-bs-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul> </div
><!-- /#header_search -->
<!-- /oai-admin-search.inc -->
