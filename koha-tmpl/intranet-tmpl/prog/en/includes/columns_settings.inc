[% USE raw %]
[% USE Koha %]
[% USE TablesSettings %]
<!-- columns_settings.inc -->

<script>
function KohaTable(id_selector, dt_parameters, table_settings, add_filters) {
    var counter = 0;
    var hidden_ids = [];
    var included_ids = [];
    var selector = '#' + id_selector;

    if ( table_settings ) {
        var columns_settings = table_settings['columns'];

        $(columns_settings).each( function() {
            var named_id = $( 'thead th[data-colname="' + this.columnname + '"]', selector ).index( selector + ' th' );
            var used_id = dt_parameters.bKohaColumnsUseNames ? named_id : counter;
            if ( used_id == -1 ) return;

            if ( this['is_hidden'] == "1" ) {
                hidden_ids.push( used_id );
            }
            if ( this['cannot_be_toggled'] == "0" ) {
                included_ids.push( used_id );
            }
            counter++;
        });
    }

    var exportColumns = ":visible:not(.noExport)";
    var exportRows = ":visible:not(.noExport)";
    if( dt_parameters.hasOwnProperty("exportColumns") ){
        // A custom buttons configuration has been passed from the page
        exportColumns = dt_parameters["exportColumns"];
    }

    var export_format = {
        body: function ( data, row, column, node ) {
            var newnode = $(node);

            if ( newnode.find(".noExport").length > 0 ) {
                newnode = newnode.clone();
                newnode.find(".noExport").remove();
            }

            return newnode.text().replace( /\n/g, ' ' ).trim();
        }
    }

    var export_numeric = {
        body: function ( data, row, column, node ) {
            var newnode = $(node);

            if ( newnode.find(".noExport").length > 0 ) {
                newnode = newnode.clone();
                newnode.find(".noExport").remove();
            }
            let tp = newnode.text().replace( /\n/g, ' ' ).trim();
            tp = $('<p>' + tp + '</p>').text();
            return $.isNumeric(tp.replace(',', '.')) ? tp.replace(',', '.') : tp;
        }
    }

    var export_buttons = [
        {
            extend: 'csvHtml5',
            text: _("CSV"),
            exportOptions: {
                columns: exportColumns,
                rows: exportRows,
                format:  export_format
            },
        },
        {
            extend: 'copyHtml5',
            text: _("Copy"),
            exportOptions: {
                columns: exportColumns,
                rows: exportRows,
                format:  export_format
            },
        },
        {
            extend: 'print',
            text: _("Print"),
            exportOptions: {
                columns: exportColumns,
                rows: exportRows,
                format:  export_format
            },
        }
    ];

    [% IF Koha.Preference("CurrencyFormat") != 'FR' %]
        export_buttons.unshift (
            {
                extend: 'excelHtml5',
                text: _("Excel"),
                exportOptions: {
                    columns: exportColumns,
                    rows: exportRows,
                    format:  export_format
                },
            }
        );
    [% ELSE %]
        export_buttons.unshift (
            {
                extend: 'excelHtml5',
                text: _("Excel"),
                exportOptions: {
                    columns: exportColumns,
                    rows: exportRows,
                    format:  export_numeric
                },
            }
        );
    [% END %]

    dt_parameters[ "buttons" ] = [
        {
            fade: 100,
            className: "dt_button_clear_filter",
            titleAttr: _("Clear filter"),
            enabled: false,
            text: '<i class="fa fa-lg fa-remove"></i> <span class="dt-button-text">' + _("Clear filter") + '</span>',
            action: function ( e, dt, node, config ) {
                dt.search( "" ).draw("page");
                node.addClass("disabled");
            }
        }
    ];

    if( included_ids.length > 0 ){
        dt_parameters[ "buttons" ].push(
            {
                extend: 'colvis',
                fade: 100,
                columns: included_ids,
                className: "columns_controls",
                titleAttr: _("Columns settings"),
                text: '<i class="fa fa-lg fa-gear"></i> <span class="dt-button-text">' + _("Columns") + '</span>',
                exportOptions: {
                    columns: exportColumns,
                    rows: exportRows,
                }
            }
        );
    }

    dt_parameters[ "buttons" ].push(
        {
            extend: 'collection',
            autoClose: true,
            fade: 100,
            className: "export_controls",
            titleAttr: _("Export or print"),
            text: '<i class="fa fa-lg fa-download"></i> <span class="dt-button-text">' + _("Export") + '</span>',
            buttons: export_buttons
        }
    );

    if ( table_settings && CAN_user_parameters_manage_column_config ) {
        dt_parameters[ "buttons" ].push(
            {
                className: "dt_button_configure_table",
                fade: 100,
                titleAttr: _("Configure table"),
                text: '<i class="fa fa-lg fa-wrench"></i> <span class="dt-button-text">' + _("Configure") + '</span>',
                action: function() {
                    window.location = '/cgi-bin/koha/admin/columns_settings.pl?module=' + table_settings['module'] + '&page=' + table_settings['page'] + '&table=' + table_settings['table'];
                },
            }
        );
    }

    var table = $(selector);
    if ( add_filters ) {
        // Duplicate the table header row for columnFilter
        thead_row = table.find('thead tr');
        clone = thead_row.clone().addClass('filters_row');
        clone.find("th.NoSort").html('');
        thead_row.before(clone);
    }

    var new_parameters = {}
    $.extend(true, new_parameters, dataTablesDefaults, dt_parameters);
    var default_column_defs = [
        { "targets": [ "title-string" ], "type": "title-string" },
        { "targets": [ "string-sort" ],  "type": "string" },
        { "targets": [ "anti-the" ],     "type": "anti-the" },
        { "targets": [ "NoSort" ],       "orderable": false, "searchable": false },
        { "targets": [ "NoVisible" ],    "visible": false }
    ];
    if ( new_parameters["aoColumnDefs"] === undefined ) {
        new_parameters["aoColumnDefs"] = default_column_defs;
    } else {
        $(default_column_defs).each(function(){
            new_parameters["aoColumnDefs"].push(this);
        });
    }

    if ( table_settings ) {
        if ( table_settings.hasOwnProperty('default_display_length') && table_settings['default_display_length'] != null ) {
            new_parameters["pageLength"] = table_settings['default_display_length'];
        }
        if ( table_settings.hasOwnProperty('default_sort_order') && table_settings['default_sort_order'] != null ) {
            new_parameters["order"] = [[ table_settings['default_sort_order'], 'asc' ]];
        }
    }

    table.dataTable(new_parameters);
    table.DataTable().on("column-visibility.dt", function(){
        if( typeof columnsInit == 'function' ){
            // This function can be created separately and used to trigger
            // an event after the DataTable has loaded AND column visibility
            // has been updated according to the table's configuration
            columnsInit(this);
        }
    }).columns( hidden_ids ).visible( false );

    if ( add_filters ) {
        // show a link to activate filtering
        link = $('<a>')
            .attr('href', '#')
            .attr('id', id_selector + '_activate_filters');
        $("." + id_selector  + "_table_controls").prepend(link);
        deactivate_filters(id_selector);
    }

    $(".dt_button_clear_filter, .columns_controls, .export_controls, .dt_button_configure_table").tooltip();

    return table;
}


/* get_columns_saved_state checks for a DataTables configuration saved
* in the browser's local storage. If it is present, the columns
* configuration supplied by Koha is overwritten
*
* It takes two parameters:
*  - localstorage_config, the DataTables saved state object from local storage
*  - columns_settings, the columns settings object supplied by the template
*
* An example:
*
*    var columns_settings = [% ColumnsSettings.GetColumns( 'module', 'page', 'table', 'json' ) | $raw %];
*    var saved_table = localStorage.getItem("DataTables_TABLE_ID_/cgi-bin/koha/PATH/TO/SCRIPT.pl");
*    var updated_settings = get_columns_saved_state( saved_table, columns_settings );
*
*    KohaTable("TABLE_ID", {
*        "stateSave": true
*    }, updated_settings);
*/

function get_columns_saved_state( localstorage_config, columns_settings ){
    var tables = JSON.parse( localstorage_config );
    // if a table configuration was found in local storage, parse it
    if( tables ){
        var stateSave_column_visibility = [];
        $(tables.columns).each(function(){
            stateSave_column_visibility.push( this.visible === true ? 0 : 1 );
        });
        $.each( columns_settings, function( index, key ){
            if( stateSave_column_visibility[ index ] !== columns_settings[key] ){
                columns_settings[ index ].is_hidden = stateSave_column_visibility[ index ];
            }
        });
        return columns_settings;
    } else {
        return columns_settings;
    }
}

</script>
<!-- / columns_settings.inc -->
