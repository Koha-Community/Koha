[% USE Koha %]
<div id="header_search">
    <div id="city_search" class="residentsearch">
        <form action="[% script_name | html %]" method="post">
            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="city_name_filter" id="city_name_filter" value="[% city_name_filter | html %]" placeholder="City search" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search cities" href="#city_search" class="keep_text"><i class="fa fa-building-o"></i> Search cities</a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> Check out</a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> Search catalog</a></li>[% END %]
    </ul>
</div>
<!-- End Cities Resident Search Box -->
