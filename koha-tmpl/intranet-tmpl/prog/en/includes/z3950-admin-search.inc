[% USE Koha %]
<div id="header_search">

    <div id="z3950_search" class="residentsearch">
        <form action="/cgi-bin/koha/admin/z3950servers.pl" method="post">
            <span class="form-title">
                <label class="control-label">Search Z39.50/SRU servers</label>
            </span>

            <span class="form-content">
                <input class="head-searchbox form-control" type="text" name="searchfield" id="searchfield" value="[% searchfield | html %]" placeholder="Z39.50/SRU server search" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search Z39.50/SRU servers" href="#z3950_search" class="keep_text"><i class="fa fa-search"></i> Search Z39.50/SRU servers</a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> Check out</a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> Search catalog</a></li>[% END %]
    </ul>
</div>
<!-- End Members Resident Search Box -->
