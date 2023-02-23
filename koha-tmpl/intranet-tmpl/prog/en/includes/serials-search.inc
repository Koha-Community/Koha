[% USE Koha %]
<!-- Begin Main page Resident Search Box -->

<div id="header_search">
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
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
            <div class="form-extra-content">
                <div>
                    <label for="callnumber_filter">Call number:</label>
                    <input class="form-control" type="text" id="callnumber_filter" name="callnumber_filter" placeholder="Call number" value="[% callnumber_filter | html %]">
                </div>
                <div>
                    <label for="publisher_filter">Publisher:</label>
                    <input class="form-control" type="text" id="publisher_filter" name="publisher_filter" placeholder="Publisher" value="[% publisher_filter | html %]">
                </div>
                <div>
                    <label for="bookseller_filter">Vendor:</label>
                    <input class="form-control" type="text" id="bookseller_filter" name="bookseller_filter" placeholder="Vendor" value="[% bookseller_filter | html %]">
                </div>
                <div>
                    <a href="/cgi-bin/koha/serials/serials-search.pl">Advanced search</a>
                </div>
            </div>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search subscriptions" href="#subscription_search" class="keep_text"><i class="fa fa-book"></i> <span class="tab-title">Search subscriptions</span></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a></li>[% END %]
    </ul>
</div><!-- /header_search -->
<!-- End Serials Resident Search Box -->
