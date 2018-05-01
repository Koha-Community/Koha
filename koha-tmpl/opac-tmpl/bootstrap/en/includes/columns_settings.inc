[% USE ColumnsSettings %]

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
    dt_parameters[ "buttons" ] = [
        {
            extend: 'colvis',
            columns: included_ids,
            text: _("Column visibility"),
        }
    ];
    var table = $(selector).dataTable($.extend(true, {}, dataTablesDefaults, dt_parameters));

    $(hidden_ids).each(function(index, value) {
        table.fnSetColumnVis( value, false );
    });

    return table;
}

</script>
