[% USE raw %]
[% USE Koha %]
[% USE TablesSettings %]
<!-- columns_settings.inc -->

<script>
// default_filters is not used but keeping the same constructor as kohaTable for consistency
function KohaTable(id_selector, dt_parameters, table_settings, add_filters, default_filters, filters_options) {
    var selector = '#' + id_selector;

    if ( table_settings ) {

        let columns_settings = table_settings["columns"];

        let table_key = 'DataTables_%s_%s_%s_%s'.format(
            table_settings.module,
            table_settings.page,
            table_settings.table,
            id_selector,
        );

        let default_save_state        = table_settings.default_save_state;
        let default_save_state_search = table_settings.default_save_state_search;

        dt_parameters.stateSave = true;
        dt_parameters.stateSaveCallback = function( settings, data ) {
            localStorage.setItem( table_key, JSON.stringify(data) )
        }

        function set_default(table_settings, table_dt){
            let columns = new Array(table_dt.columns()[0].length).fill({visible: true});
            let hidden_ids = _dt_visibility(table_settings, table_dt);
            hidden_ids.forEach((id, i) => { columns[id] = { visible: false } } );
            // State is not loaded if time is not passed
            return { columns, time: new Date() };
        }
        dt_parameters.stateLoadCallback = function(settings) {

            // Load state from URL
            const url = new URL(window.location.href);
            let state_from_url = url.searchParams.get( table_key + '_state');
            if ( state_from_url ) {
                settings.loaded_from_state = true;
                return JSON.parse(atob(state_from_url));
            }

            if (!default_save_state) return set_default(table_settings, this.api());

            let state = localStorage.getItem(table_key);
            if (!state) return set_default(table_settings, this.api());

            state = JSON.parse(state);

            if (default_save_state_search ) {
                settings.loaded_from_state = true;
            } else {
                delete state.search;
                state.columns.forEach(c => delete c.search );
            }
            return state;
        }

        if ( table_settings.hasOwnProperty('default_save_state') && table_settings['default_save_state'] === 0 ) {
            localStorage.removeItem(table_key);
        }
    }

    var exportColumns = ":visible:not(.noExport)";
    var exportRows = ":visible:not(.noExport)";
    if( dt_parameters.hasOwnProperty("exportColumns") ){
        // A custom buttons configuration has been passed from the page
        exportColumns = dt_parameters["exportColumns"];
    }

    const export_format_spreadsheet = {
        body: function ( data, row, column, node ) {
            var newnode = $(node);

            if ( newnode.find(".noExport").length > 0 ) {
                newnode = newnode.clone();
                newnode.find(".noExport").remove();
            }
            let trimmed_str = newnode.text().replace( /\n/g, ' ' ).trim();
            const unsafeCharacters = /^[=+\-@\t\r]/;
            if ( unsafeCharacters.test(trimmed_str) ){
                trimmed_str = "'" + trimmed_str;
            }
            return trimmed_str;
        }
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
                format:  export_format_spreadsheet
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
                    format:  export_format_spreadsheet
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

    $.fn.dataTable.ext.buttons.clear_filter =
        {
            fade: 100,
            className: "dt_button_clear_filter",
            titleAttr: _("Clear filter"),
            enabled: false,
            text: '<i class="fa fa-lg fa-times"></i> <span class="dt-button-text">' + _("Clear filter") + '</span>',
            action: function ( e, dt, node, config ) {
                dt.search( "" ).draw("page");
                node.addClass("disabled");
            }
        };

    dt_parameters[ "buttons" ] = ['clear_filter'];

    // Retrieving bKohaColumnsUseNames from the options passed to the constructor, not DT settings
    // But ideally should be retrieved using table.data()
    let use_names = dt_parameters.bKohaColumnsUseNames;
    let included_columns = [];
    if (table_settings) {
        if (use_names) {
            // bKohaColumnsUseNames is set, identify columns by their data-colname
            included_columns = table_settings.columns
                .filter(c => !c.cannot_be_toggled)
                .map(c => "[data-colname='%s']".format(c.columnname))
                .join(",");
        } else {
            // Not set, columns are ordered the same than in the columns settings
            included_columns = table_settings.columns
                .map((c, i) => (!c.cannot_be_toggled ? i : null))
                .filter(i => i !== null);
        }
    }

    if( included_columns.length > 0 ){
        dt_parameters[ "buttons" ].push(
            {
                extend: 'colvis',
                fade: 100,
                columns: included_columns,
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

    /* No other exceptions should be added here! */
    if ( table_settings && table_settings.page != 'itemsearch' ) {
        dt_parameters["buttons"].push(
            {
                autoClose: true,
                fade: 100,
                className: "copyConditions_controls",
                titleAttr: __("Copy shareable link"),
                text: '<i class="fa fa-lg fa-copy"></i> <span class="dt-button-text">' + __("Copy shareable link") + '</span>',
                action: function (e, dt, node, config) {
                    let table_key = 'DataTables_%s_%s_%s_%s'.format(
                        table_settings.module,
                        table_settings.page,
                        table_settings.table,
                        dt.settings()[0].nTable.id,
                    );

                    let state = JSON.stringify(dt.state());
                    delete state.time;
                    let searchParams = new URLSearchParams(window.location.search);
                    searchParams.set(table_key + '_state', btoa(state));
                    let url = window.location.origin + window.location.pathname + '?' + searchParams.toString() + window.location.hash;
                    if( navigator.clipboard && navigator.clipboard.writeText){
                        navigator.clipboard.writeText( url );
                        $(node).tooltip({trigger: 'manual', title: _("Copied!")}).tooltip('show');
                    }
                },
            }
        );
    }

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

    if ( add_filters ) {
        dt_parameters['orderCellsTop'] = true;
    }

    var table = $(selector);

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

    new_parameters["loaded_from_state"] = false;

    if ( table_settings ) {
        if ( table_settings.hasOwnProperty('default_display_length') && table_settings['default_display_length'] != null ) {
            // pageLength needs to be a number, not a string, or it can cause issues with DataTable's next button.
            new_parameters["pageLength"] = parseInt(table_settings['default_display_length']);
        }
        if ( table_settings.hasOwnProperty('default_sort_order') && table_settings['default_sort_order'] != null ) {
            new_parameters["order"] = [[ table_settings['default_sort_order'], 'asc' ]];
        }
    }

    $(table).data('bKohaColumnsUseNames', dt_parameters.bKohaColumnsUseNames);

    table.dataTable(new_parameters);
    var table_dt = table.DataTable();
    table_dt.on("column-visibility.dt", function(){
        if( typeof columnsInit == 'function' ){
            // This function can be created separately and used to trigger
            // an event after the DataTable has loaded AND column visibility
            // has been updated according to the table's configuration
            columnsInit(this);
        }
    });

    if ( add_filters ) {
        _dt_add_filters(table, table_dt, filters_options);
    }

    table_dt.on("column-visibility.dt", function(){
        if ( add_filters ) {
            _dt_add_filters(table, table_dt, filters_options);
        }
    });

    table_dt.on( 'search.dt', function ( e, settings ) {
        // When the DataTables search function is triggered,
        // enable or disable the "Clear filter" button based on
        // the presence of a search string
        toggledClearFilter(table_dt.search(), settings.nTable.id);
    });

    return table;
}
</script>
<!-- / columns_settings.inc -->
