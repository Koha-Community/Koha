[% USE Biblio %]

[%# Parameters: %]
[%# biblio: the Koha::Biblio object %]
[%# biblionumber: FIXME what about using biblio.id? %]

<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items || CAN_user_serials_create_subscription || Koha.Preference('CatalogConcerns') ) %]
        <div class="btn-group">
            <button type="button" class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa fa-plus"></i> New</button>
            <ul class="dropdown-menu">
                [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
                    <li><a class="dropdown-item" id="newbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New record</a></li>
                [% END %]

                [% IF ( CAN_user_editcatalogue_edit_items ) %]
                    <li><a class="dropdown-item" id="newitem" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber | html %]#additema">New item</a></li>
                [% END %]
                [% IF ( CAN_user_serials_create_subscription ) %]
                    <li><a class="dropdown-item" id="newsub" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber | html %]">New subscription</a></li>
                [% END %]

                [% IF ( EasyAnalyticalRecords && CAN_user_editcatalogue_edit_catalogue ) %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblionumber | uri %]&amp;analyze=1">Analyze items</a></li>
                [% END %]
                [% IF CAN_user_editcatalogue_edit_catalogue && ! EasyAnalyticalRecords %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/cataloguing/addbiblio.pl?parentbiblionumber=[% biblionumber | uri %]">New child record</a></li>
                [% END %]
                [% IF Koha.Preference('CatalogConcerns') %]
                    <li><a class="dropdown-item" id="newconcern" role="button" href="#" data-bs-toggle="modal" data-bs-target="#addConcernModal">New catalog concern</a></li>
                [% END %]
            </ul>
        </div>
    [% END %]

    [% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items || CAN_user_tools_items_batchmod || CAN_user_tools_items_batchdel ) or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit</button>
            <ul class="dropdown-menu">
                [% IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                    [% IF biblio.can_be_edited(logged_in_user) %]
                        <li><a class="dropdown-item" id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber | html %]">Edit record</a></li>
                    [% ELSE %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="This record is locked"><a class="dropdown-item disabled" aria-disabled="true" id="editbiblio" href="#">Edit record</a></li>
                    [% END %]
                [% END %]

                [% IF CAN_user_tools_records_batchmod %]
                    <li>
                        <form action="/cgi-bin/koha/tools/batch_record_modification.pl" method="post">
                            [% INCLUDE 'csrf-token.inc' %]
                            <input type="hidden" name="recordtype" value="biblio" />
                            <input type="hidden" name="op" value="cud-list" />
                            <input type="hidden" name="bib_list" value="[% biblionumber | html %]" />
                            <button type="submit" class="dropdown-item" id="modifybiblio">Modify record using template</button>
                        </form>
                    </li>
                [% END %]

                [% IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                    <li><a class="dropdown-item" id="manageitems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber | html %]">Manage items</a></li>
                [% END %]

                [% IF ( CAN_user_tools_items_batchmod ) %]
                    [% IF ( count ) %]
                        <li>
                            <form action="/cgi-bin/koha/tools/batchMod.pl" method="post">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-show" />
                                <input type="hidden" name="biblionumber" value="[% biblionumber | html %]" />
                                <input type="hidden" name="src" value="CATALOGUING" />
                                <button id="batchedit" type="submit" class="dropdown-item">Edit items in a batch</button>
                            </form>
                        </li>
                    [% ELSE %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="This record has no items">
                            <a class="dropdown-item disabled" aria-disabled="true" id="batchedit-disabled" href="#">Edit items in batch</a>
                        </li>
                    [% END %]
                [% END %]

                [% IF ( CAN_user_tools_items_batchdel ) %]
                    [% IF ( count ) %]
                        <li>
                            <form action="/cgi-bin/koha/tools/batchMod.pl" method="post">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-show" />
                                <input type="hidden" name="del" value="1" />
                                <input type="hidden" name="biblionumber" value="[% biblionumber | html %]" />
                                <input type="hidden" name="src" value="CATALOGUING" />
                                <button id="batchdelete" type="submit" class="dropdown-item">Delete items in a batch</button>
                            </form>
                        </li>
                    [% ELSE %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="This record has no items">
                            <a class="dropdown-item disabled" aria-disabled="true" id="batchdelete-disabled" href="#">Delete items in a batch</a>
                        </li>
                    [% END %]
                [% END %]

                [% IF ( CAN_user_editcatalogue_edit_items ) %]
                    <li>
                        <a class="dropdown-item" href="/cgi-bin/koha/cataloguing/moveitem.pl?biblionumber=[% biblionumber | uri %]">Attach item</a>
                    </li>
                [% END %]

                [% IF ( EasyAnalyticalRecords ) %]
                    [% IF ( CAN_user_editcatalogue_edit_items ) %]
                        <li>
                            <a class="dropdown-item" href="/cgi-bin/koha/cataloguing/linkitem.pl?biblionumber=[% biblionumber | uri %]">Link to host record</a>
                        </li>
                    [% END %]
                [% END %]
                [% IF ( LocalCoverImages || OPACLocalCoverImages) %]
                    [% IF ( CAN_user_tools_upload_local_cover_images ) %]
                        <li>
                            <a class="dropdown-item" href="/cgi-bin/koha/tools/upload-cover-image.pl?biblionumber=[% biblionumber | uri %]&amp;filetype=image">Upload image</a>
                        </li>
                    [% END %]
                [% END %]

                [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
                    <li>
                        <a class="dropdown-item" id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber | html %]&amp;op=duplicate">Edit as new (duplicate)</a>
                    </li>
                    <li><a class="dropdown-item" href="#" id="z3950copy">Replace record via Z39.50/SRU</a></li>
                [% END %]

                [% IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                    [% IF ( count ) %]
                        <li
                            data-bs-toggle="tooltip"
                            data-bs-placement="left"
                            title="[%- I18N.tnx('There is an item attached to this record. You must delete all items before deleting this record', 'There are {count} items attached to this record. You must delete all items before deleting this record', count, { count => count }) -%]"
                        >
                            <a class="dropdown-item disabled" aria-disabled="true" id="deletebiblio" href="#">Delete record</a>
                        </li>
                    [% ELSIF ( biblio.subscriptions.count ) %]
                        [%- SET subscriptions_count = biblio.subscriptions.count -%]
                        <li
                            data-bs-toggle="tooltip"
                            data-bs-placement="left"
                            title="[%- I18N.tnx('There is a subscription attached to this record. You must delete all subscriptions before deleting this record', 'There are {subscriptions_count} subscriptions attached to this record. You must delete all subscriptions before deleting this record', subscriptions_count, { subscriptions_count => subscriptions_count }) -%]"
                        >
                            <a class="dropdown-item disabled" aria-disabled="true" id="deletebiblio" href="#">Delete record</a>
                        </li>
                    [% ELSE %]
                        <li>
                            <form action="/cgi-bin/koha/cataloguing/addbiblio.pl" method="post">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-delete" />
                                <input type="hidden" name="biblionumber" value="[% biblionumber | html %]" />
                                <input type="hidden" name="searchid" value="[% searchid | html %]" />
                            </form>
                            <a class="dropdown-item" id="deletebiblio" data-order-manage="[% CAN_user_acquisition_order_manage | html %]" href="#">Delete record</a>
                        </li>
                    [% END %]
                [% END %]

                [% IF CAN_user_editcatalogue_delete_all_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                    [% IF ( count ) %]
                        <li>
                            <form action="/cgi-bin/koha/cataloguing/additem.pl" method="post">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-delallitems" />
                                <input type="hidden" name="biblionumber" value="[% biblionumber | html %]" />
                                <input type="hidden" name="searchid" value="[% searchid | html %]" />
                            </form>
                            <a class="dropdown-item" href="#" id="deleteallitems">Delete all items</a>
                        </li>
                    [% ELSE %]
                        <li id="deleteallitems-disabled" data-bs-toggle="tooltip" data-bs-placement="left" title="This record has no items">
                            <a class="dropdown-item disabled" aria-disabled="true" href="#">Delete all items</a>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        </div>
    [% END %]

    <div class="btn-group">
        <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa fa-download"></i> Save</button>
        <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=bibtex&amp;op=export&amp;bib=[% biblionumber | uri %]">BIBTEX</a></li>
            <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#exportModal_">Dublin Core</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=marcxml&amp;op=export&amp;bib=[% biblionumber | uri %]">MARCXML</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=marc8&amp;op=export&amp;bib=[% biblionumber | uri %]">MARC (non-Unicode/MARC-8)</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=utf8&amp;op=export&amp;bib=[% biblionumber | uri %]">MARC (Unicode/UTF-8)</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=marcstd&amp;op=export&amp;bib=[% biblionumber | uri %]">MARC (Unicode/UTF-8, Standard)</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=mods&amp;op=export&amp;bib=[% biblionumber | uri %]">MODS (XML)</a></li>
            <li><a class="dropdown-item" href="/cgi-bin/koha/catalogue/export.pl?format=ris&amp;op=export&amp;bib=[% biblionumber | uri %]">RIS</a></li>
        </ul>
    </div>

    [% IF (Koha.Preference("intranetbookbag")) %]
        [% IF ( incart ) %]
            <div class="btn-group">
                <a id="cart[% biblionumber | html %]" class="btn btn-default addtocart incart" href="#" role="button"><i class="fa fa-shopping-cart"></i> Add to cart</a>
            </div>
            <div class="btn-group">
                <a id="cartR[% biblionumber | html %]" class="btn btn-default cartRemove incart" href="#" role="button"><i class="fa fa-shopping-cart"></i> Remove from cart</a>
            </div>
        [% ELSE %]
            <div class="btn-group">
                <a id="cart[% biblionumber | html %]" class="btn btn-default addtocart" href="#" role="button"><i class="fa fa-shopping-cart"></i> Add to cart</a>
            </div>
            <div class="btn-group">
                <a id="cartR[% biblionumber | html %]" class="btn btn-default cartRemove" href="#" role="button"><i class="fa fa-shopping-cart"></i> Remove from cart</a>
            </div>
        [% END %]
    [% END %]

    [% IF Koha.Preference('virtualshelves') %]
        <div class="btn-group">
            <button type="button" class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> <i class="fa fa-list"></i> Add to list </button>
            <ul class="dropdown-menu">
                [% IF add_to_some_private_shelves.count %]
                    <li><h6 class="dropdown-header">Your lists</h6></li>
                    [% SET number_of_private_shelves = 0 %]
                    [% FOREACH s IN add_to_some_private_shelves %]
                        [% IF shelfnumber != s.shelfnumber %]
                            <li>
                                <a class="dropdown-item addtolist" href="#" data-shelfnumber="[% s.shelfnumber | html %]">[% s.shelfname | html %]</a>
                            </li>
                            [% SET number_of_private_shelves = number_of_private_shelves + 1 %]
                            [% IF number_of_private_shelves == 10 %][% LAST %][% END %]
                        [% END %]
                    [% END %]
                [% END %]
                [% IF add_to_some_public_shelves.count %]
                    <li><h6 class="dropdown-header">Public lists</h6></li>
                    [% SET number_of_public_shelves = 0 %]
                    [% FOREACH s IN add_to_some_public_shelves %]
                        [% IF shelfnumber != s.shelfnumber %]
                            <li>
                                <a class="dropdown-item addtolist" href="#" data-shelfnumber="[% s.shelfnumber | html %]">[% s.shelfname | html %]</a>
                            </li>
                            [% SET number_of_public_shelves = number_of_public_shelves + 1 %]
                            [% IF number_of_public_shelves == 10 %][% LAST %][% END %]
                        [% END %]
                    [% END %]
                [% END %]
                <li><hr class="dropdown-divider" /></li>
                [% IF ( add_to_some_private_shelves and add_to_some_private_shelves.count > 10 ) or ( add_to_some_public_shelves and add_to_some_public_shelves.count > 10 ) %]
                    <li>
                        <a href="#" class="addtolist morelists dropdown-item">More lists</a>
                    </li>
                [% END %]
                <li>
                    <a href="#" class="addtolist newlist dropdown-item">New list</a>
                </li>
            </ul>
        </div>
    [% END # /IF virtualshelves %]

    <div class="btn-group"
        ><a id="printbiblio" class="btn btn-default" role="button"><i class="fa fa-print"></i> Print</a></div
    >

    [% IF ( CAN_user_reserveforothers ) %]
        [% IF biblio.items.filter_by_for_hold.count %]
            [% IF ( holdfor ) %]
                <div class="btn-group">
                    <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa-solid fa-bookmark"></i>
                        Place hold
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber | uri %]">Place hold</a></li>
                        <li
                            ><a class="dropdown-item" href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber | uri %]&amp;findborrower=[% holdfor_patron.cardnumber | uri %]"
                                >Place hold for [% INCLUDE 'patron-title.inc' patron => holdfor_patron no_title => 1 %]</a
                            ></li
                        >
                    </ul>
                </div>
            [% ELSE %]
                <div class="btn-group"
                    ><a id="placehold" class="btn btn-default" href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber | html %]" role="button"><i class="fa-solid fa-bookmark"></i> Place hold</a></div
                >
            [% END %]
        [% END %]
    [% END %]

    <div class="btn-group">
        <a id="audit_record" class="btn btn-default" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblionumber | html %]&audit=1" role="button"> <i class="fa-solid fa-stethoscope"></i> Audit</a>
    </div>

    [% IF ( Koha.Preference('EnableBooking') &&  CAN_user_circulate_manage_bookings && biblio.items.filter_by_bookable.count ) %]
        <div class="btn-group"
            ><button id="placbooking" class="btn btn-default" data-bs-toggle="modal" data-bs-target="#placeBookingModal" data-biblionumber="[% biblionumber | html %]"><i class="fa fa-calendar"></i> Place booking</button></div
        >
    [% END %]

    [% IF Koha.Preference('ArticleRequests') %]
        <div class="btn-group"
            ><a id="placehold" class="btn btn-default" href="/cgi-bin/koha/circ/request-article.pl?biblionumber=[% biblionumber | html %]" role="button"><i class="fa-solid fa-file-lines"></i> Request article</a></div
        >
    [% END %]

    [% IF ( CAN_user_acquisition_order_manage ) %]
        [% IF ( searchtoorder_basketno && searchtoorder_vendorid ) %]
            <div class="btn-group">
                <a class="btn btn-default" href="/cgi-bin/koha/acqui/neworderempty.pl?booksellerid=[% searchtoorder_vendorid | uri %]&amp;basketno=[% searchtoorder_basketno | uri %]&amp;biblionumber=[% biblionumber | uri %]" role="button"
                    ><i class="fa fa-shopping-basket"></i> Add order</a
                >
            </div>
        [% END %]
    [% END %]

    [% FOREACH p IN plugins %]
        [% p.intranet_catalog_biblio_enhancements_toolbar_button | $raw %]
    [% END %]
</div>

<!--Modal for Dublin Core-->
<div class="modal" id="exportModal_" tabindex="-1" role="dialog" aria-labelledby="exportLabelexportModal_" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title" id="exportLabelexportModal_">Exporting to Dublin Core...</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="get" action="/cgi-bin/koha/catalogue/export.pl">
                <div class="modal-body">
                    <fieldset>
                        <input id="input-simple" type="radio" name="format" value="rdfdc" />
                        <label for="input-simple">Simple DC-RDF</label>
                        <br />
                        <input id="input-oai" type="radio" name="format" value="oaidc" checked />
                        <label for="input-oai">OAI-DC</label>
                        <br />
                        <input id="input-srw" type="radio" name="format" value="srwdc" />
                        <label for="input-srw">SRW-DC</label>
                        <br />
                    </fieldset>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Export</button>
                    <button type="button" class="btn btn-default" data-bs-dismiss="modal">Close</button>
                </div>
                <input type="hidden" name="op" value="export" />
                <input type="hidden" name="bib" value="[% biblionumber | html %]" />
            </form>
        </div>
    </div>
</div>

[% INCLUDE modals/place_booking.inc %]
