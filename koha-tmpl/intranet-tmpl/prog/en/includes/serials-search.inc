[% USE Koha %]
<!-- serials-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="subscription_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/serials/serials-search.pl" method="get">
                [% IF ( routing ) %]
                    <input type="hidden" name="routing" value="[% routing | html %]" />
                [% END %]
                <input type="hidden" name="searched" value="1" />

                <div class="form-title">
                    <label class="control-label">Search subscriptions</label>
                </div>

                <div class="form-content">
                    <input type="text" class="form-control" placeholder="ISSN" size="11" name="ISSN_filter" id="ISSN_filter" value="[% ISSN_filter | html %]" />

                    [% IF (UNIMARC) %]
                        <input type="text" class="form-control" placeholder="EAN" size="11" name="EAN_filter" id="EAN_filter" value="[% EAN_filter | html %]" />
                    [% END %]

                    <input type="text" class="form-control" placeholder="Title" size="11" name="title_filter" id="title_filter" value="[% title_filter | html %]" />
                    <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>

                </div>

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
                </div> <!-- /.form-extra-content -->
            </form>
        </div> <!-- /#subscription_search -->

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]

    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search subscriptions" href="#subscription_search" aria-controls="subscription_search" aria-expanded="true" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-book"></i> <span class="tab-title">Search subscriptions</span></a>
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- /serials-search.inc -->
