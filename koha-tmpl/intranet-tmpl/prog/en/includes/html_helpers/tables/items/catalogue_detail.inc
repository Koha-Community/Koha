[% USE To %]
[% USE tojson = To %]
[% USE Koha %]
[% USE Branches %]
[% USE AuthorisedValues %]
[% USE ItemTypes %]
[% USE raw %]

[% BLOCK build_table %]
    <table class="items_table" id="[% tab | html %]_table">
        <thead>
            <th id="[% tab | html %]_checkbox" data-colname="checkbox" class="NoSort"></th>
            [% IF Koha.Preference('LocalCoverImages') %]
                <th id="[% tab | html %]_cover_image" data-colname="cover_image">Cover image</th>
            [% END %]
            [% IF ( item_level_itypes ) %]<th id="[% tab | html %]_itype" data-colname="itype">Item type</th>[% END %]
            <th id="[% tab | html %]_holdingbranch" data-colname="holdingbranch">Current library</th>
            <th id="[% tab | html %]_homebranch" data-colname="homebranch">Home library</th>
            <th id="[% tab | html %]_ccode" data-colname="ccode">Collection</th>
            [% IF Koha.Preference('EnableItemGroups') %]
                <th id="[% tab | html %]_item_group" data-colname="item_group">Item group</th>
            [% END %]
            <th id="[% tab | html %]_itemcallnumber" data-colname="itemcallnumber">Call number</th>
            <th id="[% tab | html %]_enumchron" data-colname="enumchron">Serial enumeration / chronology</th>
            <th id="[% tab | html %]_status" data-colname="status">Status</th>
            <th id="[% tab | html %]_lastseen" data-colname="lastseen">Last seen</th>
            <th id="[% tab | html %]_issues" data-colname="issues">Checkouts</th>
            <th id="[% tab | html %]_renewals" data-colname="renewals">Renewals</th>
            <th id="[% tab | html %]_localuse" data-colname="localuse">Local uses</th>
            <th id="[% tab | html %]_dateaccessioned" data-colname="dateaccessioned">Date accessioned</th>
            <th id="[% tab | html %]_datelastborrowed" data-colname="datelastborrowed">Date last borrowed</th>
            <th id="[% tab | html %]_booksellerid" data-colname="booksellerid">Source of acquisition</th>
            <th id="[% tab | html %]_barcode" data-colname="barcode">Barcode</th>
            <th id="[% tab | html %]_uri" data-colname="uri">URL</th>
            <th id="[% tab | html %]_copynumber" data-colname="copynumber">Copy number</th>
            <th id="[% tab | html %]_stocknumber" data-colname="stocknumber">Inventory number</th>
            <th id="[% tab | html %]_materials" data-colname="materials">Materials specified</th>
            <th id="[% tab | html %]_itemnotes" data-colname="itemnotes">Public notes</th>
            <th id="[% tab | html %]_itemnotes_nonpublic" data-colname="itemnotes_nonpublic">Non-public notes</th>
            [% IF Koha.Preference('EasyAnalyticalRecords') %]<th id="[% tab | html %]_hostrecord" data-colname="hostrecord">Host records</th>[% END %]
            [% IF ( analyze ) %]<th id="[% tab | html %]_usedin" data-colname="usedin">Used in</th><th></th>[% END %]
            [% IF Koha.Preference('UseCourseReserves') %]<th id="[% tab | html %]_course_reserves" data-colname="course_reserves">Course reserves</th>[% END %]
            [% IF ( SpineLabelShowPrintOnBibDetails ) %]<th id="[% tab | html %]_spinelabel" data-colname="spinelabel" class="NoSort">Spine label</th>[% END %]
            [% IF ( CAN_user_editcatalogue_edit_items ) %]<th id="[% tab | html %]_actions" data-colname="actions" class="NoSort noExport">&nbsp;</th>[% END %]
            </tr>
        </thead>
    </table>
[% END %]
[% BLOCK items_table %]
    <div class="[% tab | html %]_table_table_controls">
        <span class="show_hide_filters">
            [% IF Koha.Preference('AlwaysShowHoldingsTableFilters') %]
                <button class="btn btn-link show_filters" data-tab="[% tab | html %]" style="display: none;"><i class="fa fa-filter"></i> Show filters</button>
                <button class="btn btn-link hide_filters" data-tab="[% tab | html %]"><i class="fa fa-filter"></i> Hide filters</button>
            [% ELSE %]
                <button class="btn btn-link show_filters" data-tab="[% tab | html %]"><i class="fa fa-filter"></i> Show filters</button>
                <button class="btn btn-link hide_filters" data-tab="[% tab | html %]" style="display: none;"><i class="fa fa-filter"></i> Hide filters</button>
            [% END %]
        </span>
        <button class="btn btn-link SelectAll" data-tab="[% tab | html %]"><i class="fa fa-check"></i> Select all</button>
        <button class="btn btn-link ClearAll" data-tab="[% tab | html %]"><i class="fa fa-times"></i> Clear all</button>
        <span class="itemselection_actions">
          | Actions:
          [% IF CAN_user_tools_items_batchdel %]
              <form class="itemselection_action_delete_form" method="post" action="/cgi-bin/koha/tools/batchMod.pl">
                  [% INCLUDE 'csrf-token.inc' %]
                  <input name='src' type='hidden' value='CATALOGUING' />
                  <input name='biblionumber' type='hidden' value="[% biblionumber | html %]" />
                  <input name='op' type='hidden' value='cud-show' />
                  <input name='del' type='hidden' value='1' />
                  <button type="submit" class="itemselection_action_delete btn btn-link" /><i class="fa fa-trash-can"></i> Delete selected items</button>
              </form>
          [% END %]
          [% IF CAN_user_tools_items_batchmod %]
              <form class="itemselection_action_modify_form" method="post" action="/cgi-bin/koha/tools/batchMod.pl">
                  [% INCLUDE 'csrf-token.inc' %]
                  <input name='src' type='hidden' value='CATALOGUING' />
                  <input name='biblionumber' type='hidden' value="[% biblionumber | html %]" />
                  <input name='op' type='hidden' value='cud-show' />
                  <button type="submit" class="itemselection_action_modify btn btn-link" /><i class="fa-solid fa-pencil"></i> Modify selected items</button>
              </form>
          [% END %]
          [% IF CAN_user_editcatalogue_manage_item_groups && biblio.item_groups.count %]
            <a class="itemselection_action_item_group_set" href="#"><i class="fa fa-book"></i> Add/move to item group</a>
            <a class="itemselection_action_item_group_unset" href="#"><i class="fa fa-unlink"></i> Remove from item group</a>
          [% END %]
        </span>
    </div>

    [% PROCESS build_table tab => tab %]
[% END %][%# end of block items_table %]


[% BLOCK build_items_table_js %]
<script>

    let hide_patron_name = [% IF Koha.Preference('HidePatronName') %]true[% ELSE %]false[% END %];

    let items_selection = {};

    function _itemSelectionBuildLink(tab_id, link_class) {

        let itemnumbers = items_selection[tab_id];
        let tab = $("#" + tab_id + "_panel" );
        let form = tab.find(link_class);
        $(form).find("input[name='itemnumber']").remove();

        $(itemnumbers).each(function() {
            $(form).append("<input name='itemnumber' type='hidden' value='%s'/>".format(this));
        });
        return !!itemnumbers.length
    }
    function itemSelectionBuildDeleteLink(tab_id) {
        return _itemSelectionBuildLink(tab_id, '.itemselection_action_delete_form');
    }
    function itemSelectionBuildModifyLink(tab_id) {
        return _itemSelectionBuildLink(tab_id, '.itemselection_action_modify_form');
    }

    function itemSelectionBuildActionLinks(tab_id) {
        var delete_link_ok = itemSelectionBuildDeleteLink(tab_id);
        var modify_link_ok = itemSelectionBuildModifyLink(tab_id);
        var tab = $("#" + tab_id + "_panel" );
        if (modify_link_ok || delete_link_ok) {
            $('.itemselection_actions', tab).show();
        } else {
            $('.itemselection_actions', tab).hide();
        }
    }

    function update_columns_visibility(table_dt, table_settings, user_colvis){
        table_dt.columns().visible(true, false);
        let hidden_ids = _dt_visibility(table_settings, table_dt);
        table_dt.columns(hidden_ids).visible(false, false);
        table_dt.columns().every(function(){
            let i = this.index();
            let is_empty = true;
            let nodes = this.nodes();
            nodes.each((td, ii) => {
                if ( $(td).html() !== '' ) {
                    is_empty = false;
                    return;
                }
            });
            if ( is_empty ) {
                table_dt.columns(i).visible(false, false);
            }
        });
        for (const [key, value] of Object.entries(user_colvis)) {
            table_dt.columns(key).visible(value, false);
        }
    }


    $(document).ready(function() {

        $(".SelectAll").on("click",function(e){
            e.preventDefault();
            let tab_id = $(this).data("tab");
            let tab = $("#" + tab_id + "_panel" );
            items_selection[tab_id] = [];
            tab.find("input[name='itemnumber'][type='checkbox']").each( (i, input) => {
                let itemnumber = parseInt($(input).val());
                items_selection[tab_id].push(itemnumber);
                $(input).prop('checked', true);
            });
            itemSelectionBuildActionLinks(tab_id);
        });

        $(".ClearAll").on("click",function(e){
            e.preventDefault();
            let tab_id = $(this).data("tab");
            let tab = $("#" + tab_id + "_panel" );
            items_selection[tab_id] = [];
            $("input[name='itemnumber'][type='checkbox']", tab).prop('checked', false);
            itemSelectionBuildActionLinks(tab_id);
        });

    });

    let filters_shown = false;
    $(document).ready(function() {
        $(".show_filters").on("click",function(e){
            e.preventDefault();
            let tab_id = $(this).data("tab");
            let tab = $("#" + tab_id + "_panel" );
            tab.find(".show_filters").hide();
            tab.find(".hide_filters").show();
            filters_show = true;
            $("#"+tab_id+"_table thead tr:eq(1)").remove();
            build_items_table(tab_id, true, { destroy: true }, build_items_table_drawncallback );
            itemSelectionBuildActionLinks(tab_id);
        });

        $(".hide_filters").on("click",function(e){
            e.preventDefault();
            let tab_id = $(this).data("tab");
            let tab = $("#" + tab_id + "_panel" );
            tab.find(".hide_filters").hide();
            tab.find(".show_filters").show();
            filters_show = false;
            $("#"+tab_id+"_table thead tr:eq(1)").remove();
            build_items_table(tab_id, false, { destroy: true }, build_items_table_drawncallback );
            itemSelectionBuildActionLinks(tab_id);
        });
    });

    const all_libraries = [% To.json(Branches.all) | $raw %];
    const libraries_filters = all_libraries.map(e => {
                e["_id"] = e["branchcode"];
                e["_str"] = e["branchname"];
                return e;
            });
    const libraries_names = new Map(all_libraries.map( l => [l.branchcode, l.branchname] ));
    const all_item_types = [% To.json(ItemTypes.Get) | $raw %];
    const item_types_filters = all_item_types.map(e => {
                e["_id"] = e["itemtype"];
                e["_str"] = e["translated_description"];
                return e;
            });
    const item_types_notforloan = new Map(all_item_types.map( it => [it.itemtype, it.notforloan] ));

    const statuses = {checked_out: _("Checked out"), local_use: _("On-site checkout"), in_transit: _("In transit"), lost: _("Lost"), withdrawn: _("Withdrawn"), damaged:_("Damaged"), not_for_loan: _("Not for loan"), on_hold: _("On hold"), recalled: _("Recalled"), available: _("Available"), restricted: _("Restricted"), in_bundle: _("In bundle")};
    const all_statuses = Object.keys(statuses).map(k => {return {_id: k, _str: statuses[k]}}).sort();

    const can_edit_items_from = [% To.json(can_edit_items_from || []) | $raw %];
    const item_type_image_locations = [% To.json(item_type_image_locations) | $raw %];
    const av_loc = new Map([% To.json(AuthorisedValues.Get('LOC')) | $raw %].map( av => [av.authorised_value, av.lib]));
    const av_lost = new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.itemlost' })) | $raw %].map( av => [av.authorised_value, av.lib]));
    const av_withdrawn = new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.withdrawn' })) | $raw %].map( av => [av.authorised_value, av.lib]));
    const av_damaged = new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.damaged' })) | $raw %].map( av => [av.authorised_value, av.lib]));
    const av_not_for_loan= new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.notforloan' })) | $raw %].map( av => [av.authorised_value, av.lib]));
    const av_restricted = new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.restricted' })) | $raw %].map( av => [av.authorised_value, av.lib]));
    [% IF Koha.Preference('UseCourseReserves') %]
        const av_courses_term = new Map([% To.json(AuthorisedValues.Get('TERM')) | $raw %].map( av => [av.authorised_value, av.lib]));
    [% END %]

        var coded_values = {
        library: new Map(all_libraries.map( l => [l.branchname, l.branchcode] )),
        item_type: new Map(all_item_types.map( i => [i.translated_description, i.itemtype] )),
        collection_code: new Map([% To.json(AuthorisedValues.GetDescriptionsByKohaField({ kohafield => 'items.ccode' })) | $raw %].map( av => [av.lib, av.authorised_value])),
    };

    [% IF Koha.Preference('URLLinkText') %]
        const url_link_text = "[% Koha.Preference('URLLinkText') | html %]";
    [% ELSE %]
        const url_link_text = _("Link to resource");
    [% END %]
    [%# FIXME The X-Base-Total-Count will be the number of items of the biblios %]
    [%# In case or SeparateHoldings we may need to display the number of biblios in each tab %]
    [%# Do we need separate/new endpoints or do we hack the somewhere client-side? %]
    let item_table_url = "/api/v1/biblios/[% biblio.biblionumber | uri %]/items?";
    let embed = ["+strings,_status,checkout,checkout.patron,transfer,transfer+strings,first_hold,first_hold+strings,first_hold.patron,first_hold.desk"];
    [% IF Koha.Preference('LocalCoverImages') %]
        embed.push('cover_image_ids');
    [% END %]
    [% IF Koha.Preference('EnableItemGroups') %]
        embed.push('item_group_item.item_group.description');
    [% END %]
    [% IF biblio.serial %]
        embed.push('serial_item.serial');
    [% END %]
    [% IF Koha.Preference('UseRecalls') %]
        embed.push('recall', 'recall+strings', 'recall.patron')
    [% END %]
    embed.push('in_bundle', 'bundle_host', 'bundle_host.biblio', 'bundle_items_lost+count', 'bundle_items_not_lost+count');
    [% IF Koha.Preference('UseCourseReserves') %]
        embed.push('course_item.course_reserves.course');
    [% END %]
    [% IF Koha.Preference('ClaimReturnedLostValue') %]
        embed.push('return_claims');
    [% END %]

    [% IF Koha.Preference('EasyAnalyticalRecords') %]
        // For host records
        embed.push('biblio.title');
    [% END %]

    [% IF analyze %]
        embed.push('analytics_count');
    [% END %]

    var items_table_settings = {
        holdings: [% TablesSettings.GetTableSettings('catalogue', 'detail','holdings_table','json') | $raw %],
        otherholdings: [% TablesSettings.GetTableSettings('catalogue', 'detail','otherholdings_table','json')  | $raw %],
    };

    let user_colvis = {holdings: {}, otherholdings: {}};
    let table_nodes = {
        holdings: "[% PROCESS 'build_table' tab="holdings" | collapse | $tojson %]",
        otherholdings: "[% PROCESS 'build_table' tab="otherholdings" | collapse | $tojson %]",
    };
    function build_items_table (tab_id, add_filters, dt_options, drawcallback) {

        let table_dt;
        if ( dt_options && dt_options.hasOwnProperty('destroy') ) {
            // Keep a copy of the user settings, the destroy is going to trigger the column-visibility.dt event for all columns
            let user_colvis_bak= Object.assign({}, user_colvis[tab_id]);
            let table_id = "#"+tab_id+"_table";
            if( $.fn.dataTable.isDataTable(table_id) ) {
                $(table_id).DataTable().destroy();
            }
            $(table_id).replaceWith(table_nodes[tab_id]);
            dt_options['destroy'] = null;
            user_colvis[tab_id] = user_colvis_bak;
        }
        let default_filters = {};
        [% IF Koha.Preference('SeparateHoldings') %]
            [% SET SeparateHoldingsBranch = Koha.Preference('SeparateHoldingsBranch') || 'homebranch' %];
            let branch = '[% IF SeparateHoldingsBranch == 'homebranch' %]me.home_library_id[% ELSE %]me.holding_library_id[% END %]';
            if ( tab_id == 'holdings' ) {
                default_filters[branch] = '[% Branches.GetLoggedInBranchcode() | html %]';
            } else {
                default_filters[branch] = { '!=': '[% Branches.GetLoggedInBranchcode() | html  %]' };
            }
        [% END %]

        [% IF hidden_count %]
            default_filters.lost_status = "0";
        [% END %]
        if ( !items_selection.hasOwnProperty(tab_id) ){
            items_selection[tab_id] = [];
        }

        default_filters._status = function(){
            return $("#" + tab_id + "_status select").val();
        };

        let filters_options = {};

        let itype_col = $("#" + tab_id + "_table thead th[data-colname='itype']").index();
        let holdingbranch_col = $("#" + tab_id + "_table thead th[data-colname='holdingbranch']").index();
        let homebranch_col = $("#" + tab_id + "_table thead th[data-colname='homebranch']").index();
        let status_col = $("#" + tab_id + "_table thead th[data-colname='status']").index();

        if ( itype_col >= 0 ) filters_options[itype_col] = () => all_item_types;
        if ( holdingbranch_col >= 0 ) filters_options[holdingbranch_col] = () => all_libraries;
        if ( homebranch_col >= 0 ) filters_options[homebranch_col] = () => all_libraries;
        if ( status_col >= 0 ) filters_options[status_col] = () => all_statuses;

        var items_table = $("#" + tab_id + '_table').kohaTable({
            ajax: { url: item_table_url },
            order: [],
            embed,
            autoWidth: false,
            bKohaColumnsUseNames: true,
            columns: [
            {
                data: "me.item_id",
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    if ( can_edit_items_from.includes(row.home_library_id) || !can_edit_items_from.length ){
                        if ( items_selection[tab_id].includes(row.item_id) ) {
                            return '<input type="checkbox" value="%s" name="itemnumber" checked />'.format(row.item_id);
                        } else {
                            return '<input type="checkbox" value="%s" name="itemnumber" />'.format(row.item_id);
                        }
                    } else {
                        return ''
                    }
                }
            },
            [% IF Koha.Preference('LocalCoverImages') %]
            {
                data: "",
                className: "cover",
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    if ( !row.cover_image_ids.length > 0 ) {
                        return '';
                    }
                    let node = '<div class="bookcoverimg">';
                    node += '<div class="cover-slider">';
                    row.cover_image_ids.forEach(id => {
                        node += '<div class="cover-image local-coverimg">';
                        node += '<a href="/cgi-bin/koha/catalogue/image.pl?imagenumber=%s" title="%s">'.format(id, _("Local cover image"));
                        node += '<img src="/cgi-bin/koha/catalogue/image.pl?thumbnail=1&imagenumber=%s" data-link="/cgi-bin/koha/catalogue/imageviewer.pl?itemnumber=%s&imagenumber=%s" alt="%s" />'.format(id, row.item_id, id, _("Local cover image"));
                        node += '</a>';
                        node += '</div>';
                    });
                    node += '</div>';
                    node += '</div>';
                    return node;
                }
            },
            [% END %]
            [% IF ( item_level_itypes ) %]
            {
                data: "me.item_type_id", // FIXME Cannot filter by biblioitem.itemtype
                datatype: "coded_value:item_type",
                className: "itype",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    let node = '';
                    let item_type_description = row._strings.item_type_id ? row._strings.item_type_id.str : row.item_type_id;
                    [% UNLESS noItemTypeImages %]
                        let image_location = item_type_image_locations[row.item_type_id];
                        node += image_location
                                ? '<img class="itemtype-image" src="%s" alt="" /> '.format(escape_str(image_location), escape_str(item_type_description), escape_str(item_type_description))
                            : '';
                    [% END %]
                    node += '<span class="itypedesc itypetext">%s</span>'.format(escape_str(item_type_description));
                    return node;
                }
            },
            [% END %]
            {
                data: "me.holding_library_id",
                datatype: "coded_value:library",
                className: "location",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row._strings.holding_library_id ? row._strings.holding_library_id.str : row.holding_library_id);
                }
            },
            {
                data: "me.home_library_id",
                datatype: "coded_value:library",
                className: "homebranch",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    let nodes = '<span class="homebranchdesc">%s</span>'.format(escape_str(row._strings.home_library_id ? row._strings.home_library_id.str : row.home_library_id));
                    nodes += '<span class="shelvingloc">'
                    [%# If permanent location is defined, show description or code and             %]
                    [%# display current location in parentheses. If not, display current location. %]
                    [%# Note that permanent location is a code, and location may be an authval.    %]
                    let loc_str = row._strings.location ? row._strings.location.str : row.location;
                    if ( row.permanent_location && row.permanent_location != row.location ) {
                        let permanent_loc_str = av_loc.get(row.permanent_location);
                        nodes += '%s (%s)'.format(escape_str(permanent_loc_str), escape_str(loc_str));
                    } else {
                        nodes += escape_str(loc_str);
                    }
                    nodes += '</span>';
                    return nodes;
                }
            },
            {
                data: "me.collection_code",
                datatype: "coded_value:collection_code",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row._strings.collection_code ? row._strings.collection_code.str : row.collection_code);
                }
            },
            [% IF Koha.Preference('EnableItemGroups') %]
            {
                data: "item_group_item.item_group.description",
                className: "item_group",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    if ( row.item_group_item ) {
                        return escape_str(row.item_group_item.item_group.description);
                    } else {
                        return "";
                    }
                }
            },
            [% END %]
            {
                data: "me.callnumber",
                className: "itemcallnumber",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row.callnumber);
                }

            },
            {
                data: "me.serial_issue_number",
                className: "enumchron",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    let nodes = "";
                    [%# FIXME Previously we displayed the column if at least one item of the biblio had an enumchron/serial_issue_number. Now it's only if one item of the ones displayed on the current page, how is that bad? How can it be fixed in an elegant way? Should we display the column only if biblio.serial? %]
                    let serial = row.serial_item ? row.serial_item.serial : null;
                    if ( row.serial_issue_number && serial && serial.serialseq ) {
                        nodes += '<span class="enum">%s</span>'.format(escape_str(row.serial_issue_number));
                        if ( serial.serialseq && row.serial_issue_number != serial.serialseq ) {
                            nodes += ' <span class="sep"> -- </span>'
                            nodes += ' <span class="serialseq">%s</span>'.format(escape_str(serial.serialseq));
                        }
                    } else if ( row.serial_issue_number ) {
                        nodes += ' <span class="enum">%s</span>'.format(escape_str(row.serial_issue_number));
                    } else if ( serial && serial.serialseq ) {
                        nodes += '<span class="serialseq">%s</span>'.format(escape_str(serial.serialseq));
                    }
                    if ( serial && serial.publisheddate ) {
                        nodes += ' <span class="pubdate">(%s)</span>'.format($date(serial.publisheddate));
                    }
                    return nodes;
                }
            },
            {
                data: "",
                className: "status",
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    let nodes = "";
                    row._status.forEach( status => {
                    if ( status == 'checked_out' || status == 'local_use') {
                        nodes += '<span>';

                        [%# Hacky for patron_to_html in case we simply want to display the patron's library name %]
                        row.checkout.patron.library = { name: libraries_names.get(row.checkout.patron.library_id) };
                        let patron_to_html = $patron_to_html(row.checkout.patron, { url: true, display_cardnumber: true, hide_patron_name });

                        if ( status == 'local_use' ) {
                            nodes += _("Currently in local use by %s").format(patron_to_html);
                        } else {
                            nodes += '<span class="datedue">';
                            nodes += _("Checked out to %s").format(patron_to_html);
                        }
                        nodes += ': ';
                        nodes += _("due %s").format($date(row.checkout.due_date, { as_due_date: true }));
                        nodes += "</span>"
                    }
                    if ( status == 'in_transit' ) {
                        if ( row.transfer.datesent ) {
                            nodes += '<span class="intransit">%s</span>'.format(_("In transit from %s to %s since %s").format(escape_str(row.transfer._strings.from_library.str), escape_str(row.transfer._strings.to_library.str), $date(row.transfer.datesent)));
                        } else {
                            nodes += '<span class="transitrequested">%s</span>'.format(_("Transit pending from %s to %s since %s").format(escape_str(row.transfer._strings.from_library.str), escape_str(row.transfer._strings.to_library.str), $date(row.transfer.daterequested)));
                        }
                    }

                    if ( status == 'lost' ) {
                        let lost_lib = av_lost.get(row.lost_status.toString()) || _("Unavailable (lost or missing");
                        nodes += '<span class="lost">%s</span>'.format(escape_str(lost_lib));
                        const hasReturnClaims = row.return_claims && row.return_claims.filter(rc => !rc.resolution).length > 0 ? true : false
                        if(hasReturnClaims) {
                            nodes += '<span class="claimed_returned">' + _("(Claimed returned)") + '</span>';
                        }
                    }

                    if ( status == 'withdrawn' ) {
                        let withdrawn_lib = av_withdrawn.get(row.withdrawn.toString()) || _("Withdrawn");
                        nodes += '<span class="wdn">%s</span>'.format(escape_str(withdrawn_lib));
                    }

                    if ( status == 'damaged' ) {
                        let damaged_lib = av_damaged.get(row.damaged_status.toString()) || _("Damaged");
                        nodes += '<span class="dmg">%s</span>'.format(escape_str(damaged_lib));
                    }

                    if ( status == 'not_for_loan' ) {
                        let not_for_loan_lib = av_not_for_loan.get(row.not_for_loan_status.toString());
                        nodes += '<span class="notforloan">%s'.format(_("Not for loan")) + ( not_for_loan_lib ? '<span class="reason"> (%s)</span>'.format(escape_str(not_for_loan_lib)) : '' ) + '</span>';
                    }

                    if ( status == 'on_hold') {
                        if ( row.first_hold.waiting_date ) {
                            if ( row.first_hold.desk ) {
                                nodes += '<span class="waitingat">%s</span>'.format(_("Waiting at %s, %s since %s.").format(row.first_hold._strings.pickup_library_id.str, row.first_hold.desk.desk_name, $date(row.first_hold.waiting_date)));
                            } else {
                                nodes += '<span class="waitingat">%s</span>'.format(_("Waiting at %s since %s.").format(row.first_hold._strings.pickup_library_id.str, $date(row.first_hold.waiting_date)));
                            }
                            [% IF Koha.Preference('canreservefromotherbranches') %]
                                if ( row.first_hold.waiting_date || row.first_hold.priority == 1 ) {
                                    [%# Hacky for patron_to_html in case we simply want to display the patron's library name %]
                                    row.first_hold.patron.library = { name: libraries_names.get(row.first_hold.patron.library_id) };

                                    let patron_to_html = $patron_to_html(row.first_hold.patron, { url: true, display_cardnumber: true, hide_patron_name });
                                    nodes += ' <span class="heldfor">%s</span>'.format(_("Hold for: %s").format(patron_to_html));
                                }
                            [% END %]
                        } else {
                            nodes += ' <span class="holdonitem">%s</span>'.format(_("There is an item level hold on this item (priority = %s).").format(row.first_hold.priority));
                        }
                    }

                    [% IF Koha.Preference('UseRecalls') %]
                        if ( row.recall && ( row.item_id === row.recall.item_id ) ) {
                            if ( row.recall.waiting_date ) {
                                nodes += '<span>%s</span>'.format(_("Waiting recall at %s since %s").format(escape_str(row.recall._strings.pickup_library_id.str), $date(row.recall.waiting_date)));
                            } else {
                                [%# Hacky for patron_to_html in case we simply want to display the patron's library name %]
                                row.recall.patron.library = { name: libraries_names.get(row.recall.patron.library_id) };

                                let patron_to_html = $patron_to_html(row.recall.patron, {url: true, display_cardnumber: true, hide_patron_name });
                                nodes += '<span>%s</span>'.format(_("Recalled by %s on %s").format(patron_to_html, $date(row.recall.created_date)))
                            }
                        }
                    [% END %]
                    if ( status == 'available' ) {
                        nodes += ' <span>%s</span>'.format(_("Available"))
                    }

                    if ( status == 'restricted') {
                        nodes += '<span class="restricted">(%s)</span>'.format(escape_str(av_restricted.get(row.restricted_status.toString())));
                    }
                    if ( status == 'in_bundle') {
                        nodes += '<span class="bundled">%s</span>'.format(_("In bundle: %s").format($biblio_to_html(row.bundle_host.biblio, { link: true })));
                    }
                    }); //end forEach
                    return nodes;
                }
            },
            {
                data: "me.last_seen_date",
                type: "date",
                className: "datelastseen",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return $datetime(row.last_seen_date);
                }
            },
            {
                data: "me.checkouts_count",
                className: "issues",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return row.checkouts_count || 0;
                }
            },
            {
                data: "me.renewals_count",
                className: "renewals",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return row.renewals_count || 0;
                }
            },
            {
                data: "me.localuse",
                className: "localuse",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return row.localuse || 0;
                }
            },
            {
                data: "me.acquisition_date",
                type: "date",
                className: "dateaccessioned",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return $date(row.acquisition_date);
                }
            },
            {
                data: "me.last_checkout_date",
                type: "date",
                className: "datelastborrowed",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return $date(row.last_checkout_date);
                }
            },
            {
                data: "me.acquisition_source",
                className: "booksellerid",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row._strings.acquisition_source ? row._strings.acquisition_source.str : row.acquisition_source);
                }
            },
            {
                data: "me.external_id",
                className: "",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    if ( row.external_id != null ) {
                        return '<a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=%s&itemnumber=%s#item%s">%s</a>'.format(row.biblio_id, row.item_id, row.item_id, row.external_id);
                    }
                    return '';
                }
            },
            {
                data: "me.uri",
                className: "uri",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    if ( !row.uri ) return "";

                    let nodes = '';
                    if ( row.uri.split(' \| ').length > 1 ) {
                        row.uri.split(' \| ').forEach((uri, i) => {
                            let node = safe_link(uri,uri);
                            nodes += node.outerHTML + "<br>";
                        });
                    } else {
                        let node = safe_link(row.uri,url_link_text);
                        nodes += node.outerHTML;
                    }
                    return nodes;
                }
            },
            {
                data: "me.copy_number",
                className: "copynumber",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row._strings.copy_number ? row._strings.copy_number.str : row.copy_number);
                }
            },
            {
                data: "me.inventory_number",
                className: "stocknumber",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row.inventory_number);
                }
            },
            {
                data: "me.materials_notes",
                className: "materials",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row.materials_notes);
                }
            },
            {
                data: "me.public_notes",
                className: "itemnotes",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return row.public_notes ? escape_str(row.public_notes).replaceAll('\n', '<br />') : '';
                }
            },
            {
                data: "me.internal_notes",
                className: "nonpublicnote",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    return escape_str(row.internal_notes);
                }
            },
            [% IF Koha.Preference('EasyAnalyticalRecords') %]
            {
                data: "biblio.title",
                searchable: false,
                orderable: true,
                render: function (data, type, row, meta) {
                    if ( row.biblio_id == [% biblio.biblionumber | html %] ) return "";
                    return '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=%s">%s</a>'.format(row.biblio_id, row.biblio.title);
                }
            },
            [% END %]
            [% IF analyze %]
            {
                data: "analytics_count",
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    if (row.analytics_count == 0) return ""
                    return '<a href="/cgi-bin/koha/catalogue/search.pl?idx=hi&amp;q=%s">%s</a>'.format(row.item_id, _("%s analytics").format(row.analytics_count));
                }
            },
            {
                data: "analytics_count", // create analytics link
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    return '<a href="/cgi-bin/koha/cataloguing/addbiblio.pl?hostbiblionumber=%s&amp;hostitemnumber=%s">%s</a>'.format(row.biblio_id, row.item_id, _("Create analytics"));
                }
            },
            [% END %]
            [% IF Koha.Preference('UseCourseReserves') %]
            {
                data: "course_item.course_reserves.course.course_name",
                searchable: true,
                orderable: true,
                render: function (data, type, row, meta) {
                    let nodes = '';
                    if (!row.course_item) return nodes;
                    row.course_item.course_reserves.forEach((cr, i) => {
                        let c = cr.course;
                        if ( c.enabled != 'yes' ) return;
                        nodes += '<p>';
                        nodes += '<a href="/cgi-bin/koha/course_reserves/course-details.pl?course_id=%s">'.format(c.course_id);
                        nodes += escape_str(c.course_name);
                        if ( c.section ) {
                            nodes += ' ' + escape_str(c.section);
                        }
                        if ( c.term ) {
                            nodes += ' ' + av_courses_term.get(c.term.toString());
                        }
                        nodes += '</p>';
                    });
                    return nodes;
                }
            },
            [% END %]
            [% IF ( SpineLabelShowPrintOnBibDetails ) %]
            {
                data: "",
                searchable: false,
                orderable: false,
                render: function (data, type, row, meta) {
                    return '<a class="btn btn-default btn-xs print-label" href="/cgi-bin/koha/labels/spinelabel-print.pl?barcode=%s"><i class="fa fa-print"></i> Print label</a>'.format(escape_str(row.external_id));
                }
            },
            [% END %]
            [% IF CAN_user_editcatalogue_edit_items %]
            {
                data: function( row, type, val, meta ) {
                    let nodes = '';
                    if ( can_edit_items_from.includes(row.home_library_id) || !can_edit_items_from.length ){
                        [% IF Koha.Preference('LocalCoverImages') OR Koha.Preference('OPACLocalCoverImages') %]
                            nodes += '<div class="btn-group dropup">';
                            nodes += ' <a class="btn btn-default btn-xs" href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=%s&itemnumber=%s#edititem"><i class="fa-solid fa-pencil"></i> %s</a><a class="btn btn-default btn-xs dropdown-toggle" data-bs-toggle="dropdown"><span class="caret"></span></a>'.format(row.biblio_id, row.item_id, _("Edit"));
                            nodes += ' <ul class="dropdown-menu">';
                            nodes += '  <li><a class="dropdown-item" href="/cgi-bin/koha/tools/upload-cover-image.pl?itemnumber=%s&amp;filetype=image"><i class="fa fa-upload"></i> %s</a></li>'.format(row.item_id, _("Upload image"));
                            nodes += ' </ul>';
                            nodes += '</div>';
                        [% ELSE %]
                            nodes += '<a class="btn btn-default btn-xs" href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=%s&itemnumber=%s#edititem"><i class="fa-solid fa-pencil"></i> %s</a>'.format(row.biblio_id, row.item_id, _("Edit"));
                        [% END %]
                    }
                    [% IF bundlesEnabled %]
                        nodes += '<button class="btn btn-default btn-xs details-control"><i class="fa fa-folder"></i> %s</button>'.format(_("Manage bundle (%s|%s)").format(row.bundle_items_not_lost_count, row.bundle_items_lost_count));
                    [% END %]

                    return nodes;
                },
                className: "actions",
                searchable: false,
                orderable: false
            }
            [% END %]
            ],
            initComplete: function( settings, json ){
                itemSelectionBuildActionLinks(tab_id);
            },
            drawCallback: function(settings){
                let api = this.api();
                $.each(
                    $(this).find("tbody tr td:first-child"),
                    function (index, e) {
                        let tr = $(this).parent()
                        let row = api.row(tr).data()
                        if (!row) return // Happen if the table is empty
                        $(this).find("input[name='itemnumber'][type='checkbox']").on("change", function(){
                            let itemnumber = parseInt($(this).val());
                            if( $(this).prop("checked") ){
                                items_selection[tab_id].push(itemnumber);
                            } else {
                                items_selection[tab_id] = items_selection[tab_id].filter( id => id != itemnumber );
                            }
                            itemSelectionBuildActionLinks(tab_id);
                        });
                    }
                );

                if (!add_filters && settings._iRecordsDisplay == settings._iRecordsTotal && settings._iDisplayLength >= settings._iRecordsDisplay){
                    let container = $(this).parent();
                    container.find(".dt-info").remove();
                    container.find(".table_entries").remove();
                    container.find(".dataTables_filter").remove();
                    container.find(".dt_button_clear_filter").remove();
                    container.find(".bottom.pager").remove();
                }

                [% IF ( SpineLabelShowPrintOnBibDetails ) %]
                     $(".print-label").on("click", function(e){
                        e.preventDefault();
                        link = $(this).attr("href");
                        openWindow(link,"Print spine label",400,400);
                    });
                [% END %]

                if ( api.data().length ) {
                    update_columns_visibility(api, items_table_settings[tab_id], user_colvis[tab_id]);
                }

                if ( drawcallback ) { drawcallback(this); }
            },
            ...dt_options,
        },
        items_table_settings[tab_id],
        add_filters,
        default_filters,
        filters_options,
        );

        table_dt = items_table.DataTable();
        table_dt.on("column-visibility.dt", function(e, settings, column, state, recalc ){
            if (recalc === false) return;

            if ( filters_shown ) {
                _dt_add_filters(this, table_dt, filters_options);
            }

            user_colvis[tab_id][column] = state;

        });
        return items_table;
    }
    function safe_link(uri,link_text) {
        let node = document.createElement('a');
        let url_str = '#';
        try {
            const safe_url = new URL(uri);
            url_str = safe_url.href;
        } catch (e) {
            //console.error('Invalid URL:', e);
        }
        node.setAttribute('href',url_str);
        node.textContent = link_text;
        return node;
    }
</script>
[% END %]
