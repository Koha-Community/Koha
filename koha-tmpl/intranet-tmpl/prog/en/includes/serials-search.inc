[% USE Koha %]
<!-- Begin Main page Resident Search Box -->

<div id="header_search" class="navbar-form navbar-left">
    <div id="subscription_search" class="residentsearch">
        <form action="/cgi-bin/koha/serials/serials-search.pl" method="get">
            [% IF ( routing ) %]
            <input type="hidden" name="routing" value="[% routing | html %]" />
            [% END %]
            <input type="hidden" name="searched" value="1" />

            <span class="form-title">
                <label class="control-label">Search subscriptions</label>
            </span>

            <span class="form-content">
                <input type="text" class="form-control" placeholder="ISSN" size="11" name="ISSN_filter" id="ISSN_filter" value="[% ISSN_filter | html %]" />

                [% IF (UNIMARC) %]
                    <input type="text" class="form-control" placeholder="EAN" size="11" name="EAN_filter" id="EAN_filter" value="[% EAN_filter | html %]" />
                [% END %]

                <input type="text" class="form-control" placeholder="Title" size="11" name="title_filter" id="title_filter" value="[% title_filter | html %]" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search subscriptions" href="#subscription_search" class="keep_text"><i class="fa fa-book"></i></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i></a></li>[% END %]
    </ul>
</div><!-- /header_search -->
<!-- End Serials Resident Search Box -->
