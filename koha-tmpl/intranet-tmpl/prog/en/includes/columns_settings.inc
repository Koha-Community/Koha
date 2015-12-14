[% USE ColumnsSettings %]

<link rel="stylesheet" type="text/css" href="[% themelang %]/css/buttons.dataTables.min.css" />
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/dataTables.buttons.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/buttons.colVis.min.js"></script>

<script type="text/javascript">
function KohaTable(selector, dt_parameters, columns_settings) {
    var id = 0;
    var hidden_ids = [];
    var included_ids = [];
    $(columns_settings).each( function() {
        var named_id = $( 'thead th[data-colname="' + this.columnname + '"]', selector ).index( 'th' );
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
        }
    ];
    var table = $(selector).dataTable($.extend(true, {}, dataTablesDefaults, dt_parameters));

    $(hidden_ids).each(function(index, value) {
        table.fnSetColumnVis( value, false );
    });

    return table;
}

</script>
