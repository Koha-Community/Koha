[% USE TablesSettings %]

<script>

function _dt_visibility(table_settings, table_dt){
    let hidden_ids = [];
    if ( table_settings ) {
        var columns_settings = table_settings.columns;
        let i = 0;
        let use_names = $(table_dt.table().node()).data('bKohaColumnsUseNames');
        if ( use_names ) {
            let hidden_columns = table_settings.columns.filter(c => c.is_hidden);
            if (!hidden_columns.length) return [];
            table_dt.columns(hidden_columns.map(c => "[data-colname='%s']".format(c.columnname)).join(',')).every(function(){
                hidden_ids.push(this.index());
            });
        } else {
            $(columns_settings).each( function(i, c) {
                if ( c.is_hidden == '1' ) {
                    hidden_ids.push(i);
                }
            });
        }
    }
    return hidden_ids;
}

function KohaTable(selector, dt_parameters, table_settings) {

    // By default we include all visible columns in exports and print unless they have the "noExport" class
    var exportColumns = ":visible:not(.noExport)";
    if( dt_parameters.hasOwnProperty("exportColumns") ){
        // A custom buttons configuration has been passed from the page
        exportColumns = dt_parameters["exportColumns"];
    }
    // Data which has the "noExport" class should not appear in print or export
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

    // Add a "Clear filter" button to table filter form field
    dt_parameters[ "buttons" ] = [
        {
            fade: 100,
            className: "dt_button_clear_filter",
            titleAttr: _("Clear filter"),
            enabled: false,
            text: '<i class="fa fa-lg fa-times" aria-hidden="true"></i> <span class="dt-button-text">' + _("Clear filter") + '</span>',
            action: function ( e, dt, node, config ) {
                dt.search( "" ).draw("page");
                node.addClass("disabled");
            }
        },
        {
            extend: 'csvHtml5',
            text: _("CSV"),
            exportOptions: {
                columns: exportColumns,
                format: export_format
            },
        },
        {
            extend: 'copyHtml5',
            text: _("Copy"),
            exportOptions: {
                columns: exportColumns,
                format: export_format
            },
        },
        {
            extend: 'print',
            text: _("Print"),
            exportOptions: {
                columns: exportColumns,
                format: export_format
            },
        }
    ];

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
                text: '<i class="fa fa-lg fa-gear" aria-hidden="true"></i> <span class="dt-button-text">' + _("Columns") + '</span>',
                exportOptions: {
                    columns: exportColumns
                }
            }
        );
    }

    var table = $(selector);

    var new_parameters = {}
    $.extend(true, new_parameters, dataTablesDefaults, dt_parameters);
    var default_column_defs = [
        { "aTargets": ["string-sort"], "sType": "string" },
        { "aTargets": ["anti-the"], "sType": "anti-the" },
        { "aTargets": ["NoSort"], "bSortable": false, "bSearchable": false }
    ];
    if (new_parameters["aoColumnDefs"] === undefined) {
        new_parameters["aoColumnDefs"] = default_column_defs;
    } else {
        $.extend(true, new_parameters, default_column_defs);
    }

    $(table).data('bKohaColumnsUseNames', dt_parameters.bKohaColumnsUseNames);

    table.dataTable(new_parameters);
    var table_dt = table.DataTable();

    let hidden_ids = _dt_visibility(table_settings, table_dt);
    table_dt.on("column-visibility.dt", function () {
        if (typeof columnsInit == 'function') {
            // This function can be created separately and used to trigger
            // an event after the DataTable has loaded AND column visibility
            // has been updated according to the table's configuration
            columnsInit();
        }
    }).columns(hidden_ids).visible(false);

    return table;
}

</script>
