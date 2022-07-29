[% USE Koha %]

<div id="header_search" class="navbar-form navbar-left">
    <div id="contract_description_search" class="residentsearch">
        <form action="[% script_name | html %]" method="post">
            <span class="form-title">
                <label class="control-label">Search contracts</label>
            </span>

            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="[% searchfield | html %]" placeholder="Search by contract name or/and description:" size="40"/>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search contracts" href="#contract_description_search" class="keep_text"><i class="fa fa-pencil-square-o"></i></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i></a></li>[% END %]
    </ul>
</div>
<!-- End Patrons Admin Resident Search Box -->
