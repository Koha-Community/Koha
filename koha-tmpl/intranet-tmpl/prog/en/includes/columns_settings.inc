[% USE ColumnsSettings %]

<script>
function KohaTable(id_selector, dt_parameters, columns_settings, add_filters) {
    var counter = 0;
    var hidden_ids = [];
    var included_ids = [];
    var selector = '#' + id_selector;

    $(columns_settings).each( function() {
        var named_id = $( 'thead th[data-colname="' + this.columnname + '"]', selector ).index( 'th' );
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

    var exportColumns = ":visible:not(.noExport)";
    if( dt_parameters.hasOwnProperty("exportColumns") ){
        // A custom buttons configuration has been passed from the page
        exportColumns = dt_parameters["exportColumns"];
    }

    var export_buttons = [
        {
            extend: 'excelHtml5',
            text: _("Excel"),
            exportOptions: {
                columns: exportColumns
            },
        },
        {
            extend: 'csvHtml5',
            text: _("CSV"),
            exportOptions: {
                columns: exportColumns
            },
        },
        {
            extend: 'copyHtml5',
            text: _("Copy"),
            exportOptions: {
                columns: exportColumns
            },
        },
        {
            extend: 'print',
            text: _("Print"),
            exportOptions: {
                columns: exportColumns
            },
        }
    ];

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
        },
        {
            extend: 'colvis',
            fade: 100,
            columns: included_ids,
            className: "columns_controls",
            titleAttr: _("Columns settings"),
            text: '<i class="fa fa-lg fa-gear"></i> <span class="dt-button-text">' + _("Columns") + '</span>',
            exportOptions: {
                columns: exportColumns
            },
        },
        {
            extend: 'collection',
            autoClose: true,
            fade: 100,
            className: "export_controls",
            titleAttr: _("Export or print"),
            text: '<i class="fa fa-lg fa-download"></i> <span class="dt-button-text">' + _("Export") + '</span>',
            buttons: export_buttons
        }

    ];

    var table = $(selector);
    if ( add_filters ) {
        // Duplicate the table header row for columnFilter
        thead_row = table.find('thead tr');
        clone = thead_row.clone().addClass('filters_row');
        clone.find("th.NoSort").html('');
        thead_row.before(clone);
    }

    table.dataTable($.extend(true, {}, dataTablesDefaults, dt_parameters));

    table.DataTable().on("column-visibility.dt", function(){
        if( typeof columnsInit == 'function' ){
            // This function can be created separately and used to trigger
            // an event after the DataTable has loaded AND column visibility
            // has been updated according to the table's configuration
            columnsInit();
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

    $(".dt_button_clear_filter, .columns_controls, .export_controls").tooltip();

    return table;
}

</script>
