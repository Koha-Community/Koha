<div id="header_search" class="navbar-form navbar-left">
    <div id="syspref_search" class="residentsearch">
        <form action="/cgi-bin/koha/admin/preferences.pl">
            <input type="hidden" name="tab" value="[% last_tab | html %]" />
            <input type="hidden" name="op" value="search" />

            <span class="form-title">
                <label class="control-label">Search system preferences</label>
            </span>

            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="" placeholder="System preference search">
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search system preferences" href="#syspref_search" class="keep_text"><i class="fa fa-fw fa-cogs"></i></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i></a></li>[% END %]
    </ul>
</div><!-- /header_search -->
<!-- End Main page Resident Search Box -->
