[% USE Koha %]

<div id="header_search">
    <div id="currency_search" class="residentsearch">
        <form action="[% script_name | html %]" method="post">
            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="description" id="description" value="[% searchfield | html %]" placeholder="Currencies search" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search currencies" href="#currency_search" class="keep_text"><i class="fa fa-dollar"></i> Search currencies</a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> Check out</a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> Search catalog</a></li>[% END %]
    </ul>
</div>
<!-- End Currencies Resident Search Box -->
