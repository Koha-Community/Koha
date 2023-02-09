[% USE TablesSettings %]

<script>
function KohaTable(selector, dt_parameters, columns_settings) {
    var id = 0;
    var hidden_ids = [];
    var included_ids = [];
    $(columns_settings).each( function() {
        var named_id = $( 'thead th[data-colname="' + this.columnname + '"]', selector ).index( selector+' th' );

        var used_id = dt_parameters.bKohaColumnsUseNames ? named_id : id;
        if ( used_id == -1 ) return;

        if ( this['is_hidden'] == "1" ) {
            hidden_ids.push( used_id );
        }
        if ( this['cannot_be_toggled'] == "0" ) {
            included_ids.push( used_id );
        }
        id++;
    });

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

    if( included_ids.length > 0 ){
        dt_parameters[ "buttons" ].push(
            {
                extend: 'colvis',
                fade: 100,
                columns: included_ids,
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

    table.dataTable(new_parameters);
    table.DataTable().on("column-visibility.dt", function () {
        if (typeof columnsInit == 'function') {
            // This function can be created separately and used to trigger
            // an event after the DataTable has loaded AND column visibility
            // has been updated according to the table's configuration
            columnsInit();
        }
    }).columns(hidden_ids).visible(false);

    $(".dt_button_clear_filter, .columns_controls, .export_controls").tooltip();

    return table;
}

</script>
