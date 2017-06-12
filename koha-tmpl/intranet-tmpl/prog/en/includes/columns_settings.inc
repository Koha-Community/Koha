[% USE ColumnsSettings %]

<script type="text/javascript">
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
    dt_parameters[ "buttons" ] = [
        {
            extend: 'colvis',
            columns: included_ids,
            text: _("Column visibility"),
        },
        'excelHtml5',
        'csvHtml5',
        'copyHtml5',
        'print',
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

    $(hidden_ids).each(function(index, value) {
        table.fnSetColumnVis( value, false );
    });

    if ( add_filters ) {
        // show a link to activate filtering
        link = $('<a>')
            .attr('href', '#')
            .attr('id', id_selector + '_activate_filters');
        $("." + id_selector  + "_table_controls").prepend(link);
        deactivate_filters(id_selector);
    }

    return table;
}

</script>
