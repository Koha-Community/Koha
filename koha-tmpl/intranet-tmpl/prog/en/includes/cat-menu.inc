[% USE Koha %]
<div id="cat-menu" class="sidebar_menu icon-collapse">
    [% IF ( CAN_user_tools_stage_marc_import || CAN_user_tools_manage_staged_marc ) %]
        <h5>Import</h5>
        <ul>
            [% IF ( CAN_user_tools_stage_marc_import ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/stage-marc-import.pl" title="Stage records for import"><i class="fa-solid fa-download fa-fw" aria-hidden="true"></i><span class="menu-label">Stage records for import</span></a>
                </li>
            [% END %]
            [% IF ( CAN_user_tools_manage_staged_marc ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/manage-marc-import.pl" title="Manage staged records"><i class="fa-solid fa-list-check fa-fw" aria-hidden="true"></i><span class="menu-label">Manage staged records</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_tools_export_catalog ) %]
        <h5>Export</h5>
        <ul>
            [% IF ( CAN_user_tools_export_catalog ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/export.pl" title="Export catalog data"><i class="fa-solid fa-upload fa-fw" aria-hidden="true"></i><span class="menu-label">Export catalog data</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_tools_inventory || ( ( Koha.Preference('OpacCatalogConcerns') || Koha.Preference('CatalogConcerns') ) && CAN_user_editcatalogue_edit_catalogue ) ) %]
        <h5>Reports</h5>
        <ul>
            [% IF ( CAN_user_tools_inventory ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/inventory.pl" title="Inventory"><i class="fa-solid fa-clipboard-check fa-fw" aria-hidden="true"></i><span class="menu-label">Inventory</span></a>
                </li>
            [% END %]
            [% IF ( Koha.Preference('OpacCatalogConcerns') || Koha.Preference('CatalogConcerns') ) && CAN_user_editcatalogue_edit_catalogue %]
                <li>
                    <a href="/cgi-bin/koha/cataloguing/concerns.pl" title="Catalog concerns"><i class="fa-solid fa-list-ul fa-fw" aria-hidden="true"></i><span class="menu-label">Catalog concerns</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_tools_items_batchmod || CAN_user_tools_items_batchdel || CAN_user_tools_records_batchmod || CAN_user_tools_records_batchdel || CAN_user_editcatalogue_records_restore || CAN_user_tools_marc_modification_templates ) %]
        <h5>Batch editing</h5>
        <ul>
            [% IF ( CAN_user_tools_items_batchmod ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/batchMod.pl" title="Batch item modification"><i class="fa-solid fa-pencil fa-fw" aria-hidden="true"></i><span class="menu-label">Batch item modification</span></a>
                </li>
            [% END %]
            [% IF ( CAN_user_tools_items_batchdel ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/batchMod.pl?del=1" title="Batch item deletion"><i class="fa-solid fa-trash-can fa-fw" aria-hidden="true"></i><span class="menu-label">Batch item deletion</span></a>
                </li>
            [% END %]
            [% IF CAN_user_tools_records_batchmod %]
                <li>
                    <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="Batch record modification"><i class="fa-solid fa-file-pen fa-fw" aria-hidden="true"></i><span class="menu-label">Batch record modification</span></a>
                </li>
            [% END %]
            [% IF CAN_user_tools_records_batchdel %]
                <li>
                    <a href="/cgi-bin/koha/tools/batch_delete_records.pl" title="Batch record deletion"><i class="fa-solid fa-file-circle-minus fa-fw" aria-hidden="true"></i><span class="menu-label">Batch record deletion</span></a>
                </li>
            [% END %]
            [% IF ( CAN_user_tools_marc_modification_templates ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/marc_modification_templates.pl" title="MARC modification templates"><i class="fa-solid fa-gear fa-fw" aria-hidden="true"></i><span class="menu-label">MARC modification templates</span></a>
                </li>
            [% END %]
            [% IF ( CAN_user_editcatalogue_records_restore ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/restore-records.pl" title="Restore deleted records"><i class="fa-solid fa-arrow-rotate-left fa-fw" aria-hidden="true"></i><span class="menu-label">Restore deleted records</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_tools_items_modification_by_age || ( CAN_user_stockrotation_manage_rotas && Koha.Preference('StockRotation') ) ) %]
        <h5>Automation</h5>
        <ul>
            [% IF ( CAN_user_tools_items_modification_by_age ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/automatic_item_modification_by_age.pl" title="Item modifications by age"
                        ><i class="fa-solid fa-calendar-days fa-fw" aria-hidden="true"></i><span class="menu-label">Item modifications by age</span></a
                    >
                </li>
            [% END %]
            [% IF ( CAN_user_stockrotation_manage_rotas && Koha.Preference('StockRotation') ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/stockrotation.pl" title="Stock rotation"><i class="fa-solid fa-rotate fa-fw" aria-hidden="true"></i><span class="menu-label">Stock rotation</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_tools_label_creator || CAN_user_tools_upload_local_cover_images ) %]
        <h5>Tools</h5>
        <ul>
            [% IF ( CAN_user_tools_label_creator ) %]
                <li>
                    <a href="/cgi-bin/koha/labels/label-home.pl" title="Label creator"><i class="fa-solid fa-hashtag fa-fw" aria-hidden="true"></i><span class="menu-label">Label creator</span></a>
                </li>
                <li>
                    <a href="/cgi-bin/koha/labels/barcode-print.pl" title="Barcode image generator"><i class="fa-solid fa-barcode fa-fw" aria-hidden="true"></i><span class="menu-label">Barcode image generator</span></a>
                </li>
                <li>
                    <a href="/cgi-bin/koha/labels/spinelabel-home.pl" title="Quick spine label creator"><i class="fa-solid fa-tags fa-fw" aria-hidden="true"></i><span class="menu-label">Quick spine label creator</span></a>
                </li>
            [% END %]

            [% IF ( CAN_user_tools_upload_local_cover_images ) %]
                <li>
                    <a href="/cgi-bin/koha/tools/upload-cover-image.pl" title="Upload local cover image"><i class="fa-solid fa-image fa-fw" aria-hidden="true"></i><span class="menu-label">Upload local cover image</span></a>
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_parameters ) %]
        <h5>Administration</h5>
        <ul>
            [% IF ( CAN_user_parameters_manage_sysprefs ) %]
                <li>
                    <a class="circ-button" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing" title="Preferences"><i class="fa-solid fa-sliders fa-fw" aria-hidden="true"></i><span class="menu-label">Preferences</span></a>
                </li>
            [% END %]
            <li>
                <a class="circ-button" href="/cgi-bin/koha/admin/admin-home.pl" title="Configuration"><i class="fa-solid fa-gears fa-fw" aria-hidden="true"></i><span class="menu-label">Configuration</span></a>
            </li>
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
