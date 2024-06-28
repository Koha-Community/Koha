[% USE Koha %]
[% USE Biblio %]
[% SET biblio_object_id = biblio.biblionumber %]

<div id="biblio-view-menu" class="sidebar_menu">
    <ul>
        <li [% IF detailview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url %]">Normal</a>
        </li>

        [%- IF Koha.Preference('viewMARC') -%]
            <li [% IF marcview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=[% biblio_object_id | url %]">MARC</a>
            </li>
        [%- END -%]

        [%- IF Koha.Preference('viewLabeledMARC') -%]
            <li [% IF labeledmarcview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=[% biblio_object_id | url %]">Labeled MARC</a>
            </li>
        [%- END -%]

        [%- IF Koha.Preference('viewISBD') -%]
            <li [% IF isbdview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=[% biblio_object_id | url %]">ISBD</a>
            </li>
        [%- END -%]

        <li [% IF moredetailview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio_object_id | url %]">Items</a>
            [% IF ( ITEM_DATA ) %]
                <ul id="items_submenu">
                    [% FOREACH ITEM_DAT IN ITEM_DATA %]
                        <li>
                            [% IF ITEM_DAT.barcode -%]
                                <a class="item_sublink" href="#item[% ITEM_DAT.itemnumber | html %]">Barcode [% ITEM_DAT.barcode | html %]</a>
                            [% ELSE -%]
                                <a class="item_sublink" href="#item[% ITEM_DAT.itemnumber | html %]">Item number [% ITEM_DAT.itemnumber | html %]</a>
                            [% END %]
                        </li>
                    [% END %]
                </ul>
            [% END %]
        </li>

        [% IF ( CAN_user_circulate_manage_bookings && biblio.items.filter_by_bookable.count ) %]
            <li [% IF bookingsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/bookings/list.pl?biblionumber=[% biblio_object_id | url %]">Bookings (<span class="bookings_count">[% biblio.bookings.filter_by_active.count | html %]</span>)</a>
            </li>
        [% END %]

        [%- IF ( CAN_user_reserveforothers ) -%]
            <li [% IF holdsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblio_object_id | url %]">Holds ([% biblio.holds.count | html %])</a>
            </li>
        [%- END -%]

        [%- IF ( EasyAnalyticalRecords ) -%]
            <li [% IF analyze %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url %]&amp;analyze=1">Analytics</a>
            </li>
        [%- END -%]

        [%- IF Koha.Preference('ArticleRequests') -%]
            <li [% IF article_requests_view %]class="active"[% END %]>
                <a href="/cgi-bin/koha/circ/request-article.pl?biblionumber=[% IF ( object ) %][% object | uri %][% ELSE %][% biblionumber | uri %][% END %]"
                    >Article requests ([% biblio.article_requests.filter_by_current.count | html %])</a
                >
            </li>
        [%- END -%]

        [%- IF ( subscriptionsnumber ) -%]
            <li>
                <a href="/cgi-bin/koha/serials/serials-search.pl?searched=1&amp;biblionumber=[% biblio_object_id | url %]">Subscriptions ([% subscriptionsnumber | html %])</a>
            </li>
        [%- END -%]

        <li [% IF issuehistoryview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=[% biblio_object_id | url %]">Checkout history</a>
        </li>

        [%- IF ( CAN_user_tools_view_system_logs ) -%]
            <li [% IF logview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=CATALOGUING&amp;action=MODIFY&amp;object=[% biblio_object_id | url %]&amp;object_type=biblio">Modification log</a>
            </li>
        [%- END -%]

        [%- IF ( CAN_user_stockrotation_manage_rota_items && Koha.Preference('StockRotation') ) -%]
            <li [% IF stockrotationview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/stockrotation.pl?biblionumber=[% biblio_object_id | uri %]">Rota</a>
            </li>
        [%- END -%]

        [%- IF ( Koha.Preference('UseRecalls') && CAN_user_recalls ) -%]
            <li [% IF recallsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/recalls/request.pl?biblionumber=[% biblio_object_id | url %]">Recalls ([% biblio.recalls.search( completed => 0 ).count | html %])</a>
            </li>
        [%- END -%]
    </ul>
</div>
<!-- /.sidebar_menu -->
