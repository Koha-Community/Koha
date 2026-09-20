[% USE Koha %]
[% USE Biblio %]
[% SET biblio_object_id = biblio.biblionumber %]

<div id="biblio-view-menu" class="sidebar_menu icon-collapse">
    <ul>
        <li [% IF detailview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url %]" title="Normal"><i class="fa-solid fa-eye fa-fw" aria-hidden="true"></i> <span class="menu-label">Normal</span></a>
        </li>

        [%- IF Koha.Preference('viewMARC') -%]
            <li [% IF marcview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=[% biblio_object_id | url %]" title="MARC"><i class="fa-solid fa-code fa-fw" aria-hidden="true"></i> <span class="menu-label">MARC</span></a>
            </li>
        [%- END -%]

        [%- IF Koha.Preference('viewLabeledMARC') -%]
            <li [% IF labeledmarcview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=[% biblio_object_id | url %]" title="Labeled MARC"><i class="fa-solid fa-tag fa-fw" aria-hidden="true"></i> <span class="menu-label">Labeled MARC</span></a>
            </li>
        [%- END -%]

        [%- IF Koha.Preference('viewISBD') -%]
            <li [% IF isbdview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=[% biblio_object_id | url %]" title="ISBD"><i class="fa-solid fa-align-left fa-fw" aria-hidden="true"></i> <span class="menu-label">ISBD</span></a>
            </li>
        [%- END -%]

        <li [% IF moredetailview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio_object_id | url %]" title="Items"><i class="fa-solid fa-boxes-stacked fa-fw" aria-hidden="true"></i> <span class="menu-label">Items</span></a>
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

        [% IF ( Koha.Preference('EnableBooking') && CAN_user_circulate_manage_bookings && biblio.items.filter_by_bookable.count ) %]
            <li [% IF bookingsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/bookings/list.pl?biblionumber=[% biblio_object_id | url %]" title="Bookings"
                    ><i class="fa-solid fa-calendar-check fa-fw" aria-hidden="true"></i> <span class="menu-label">Bookings (<span class="bookings_count">[% biblio.bookings.filter_by_active.count | html %]</span>)</span></a
                >
            </li>
        [% END %]

        [%- IF ( CAN_user_reserveforothers ) -%]
            <li [% IF holdsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblio_object_id | url %]" title="Holds"
                    ><i class="fa-solid fa-bookmark fa-fw" aria-hidden="true"></i> <span class="menu-label">Holds ([% biblio.holds.count | html %])</span></a
                >
            </li>
        [%- END -%]

        [%- IF ( EasyAnalyticalRecords ) -%]
            <li [% IF analyze %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url %]&amp;analyze=1" title="Analytics"
                    ><i class="fa-solid fa-chart-line fa-fw" aria-hidden="true"></i> <span class="menu-label">Analytics</span></a
                >
            </li>
        [%- END -%]

        [%- IF Koha.Preference('ArticleRequests') -%]
            <li [% IF article_requests_view %]class="active"[% END %]>
                <a href="/cgi-bin/koha/circ/request-article.pl?biblionumber=[% IF ( object ) %][% object | uri %][% ELSE %][% biblionumber | uri %][% END %]" title="Article requests"
                    ><i class="fa-solid fa-file-lines fa-fw" aria-hidden="true"></i> <span class="menu-label">Article requests ([% biblio.article_requests.filter_by_current.count | html %])</span></a
                >
            </li>
        [%- END -%]

        [%- IF ( subscriptionsnumber ) -%]
            <li>
                <a href="/cgi-bin/koha/serials/serials-search.pl?searched=1&amp;biblionumber=[% biblio_object_id | url %]" title="Subscriptions"
                    ><i class="fa-solid fa-newspaper fa-fw" aria-hidden="true"></i> <span class="menu-label">Subscriptions ([% subscriptionsnumber | html %])</span></a
                >
            </li>
        [%- END -%]

        <li [% IF issuehistoryview %]class="active"[% END %]>
            <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=[% biblio_object_id | url %]" title="Checkout history"
                ><i class="fa-solid fa-clock-rotate-left fa-fw" aria-hidden="true"></i> <span class="menu-label">Checkout history</span></a
            >
        </li>

        [%- IF ( CAN_user_tools_view_system_logs ) -%]
            <li [% IF logview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=CATALOGUING&amp;actions=MODIFY&amp;actions=RESTORE&amp;object=[% biblio_object_id | url %]&amp;object_type=biblio" title="Modification log"
                    ><i class="fa-solid fa-clipboard-list fa-fw" aria-hidden="true"></i> <span class="menu-label">Modification log</span></a
                >
            </li>
        [%- END -%]

        [%- IF ( CAN_user_stockrotation_manage_rota_items && Koha.Preference('StockRotation') ) -%]
            <li [% IF stockrotationview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/catalogue/stockrotation.pl?biblionumber=[% biblio_object_id | uri %]" title="Rota"><i class="fa-solid fa-rotate fa-fw" aria-hidden="true"></i> <span class="menu-label">Rota</span></a>
            </li>
        [%- END -%]

        [%- IF ( Koha.Preference('UseRecalls') != "off" && CAN_user_recalls ) -%]
            <li [% IF recallsview %]class="active"[% END %]>
                <a href="/cgi-bin/koha/recalls/request.pl?biblionumber=[% biblio_object_id | url %]" title="Recalls"
                    ><i class="fa-solid fa-rotate-left fa-fw" aria-hidden="true"></i> <span class="menu-label">Recalls ([% biblio.recalls.search( completed => 0 ).count | html %])</span></a
                >
            </li>
        [%- END -%]
    </ul>
</div>
<!-- /.sidebar_menu -->
