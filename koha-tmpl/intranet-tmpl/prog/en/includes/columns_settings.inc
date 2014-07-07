[% USE ColumnsSettings %]

<script type="text/javascript">
function KohaTable(selector, dt_parameters, columns_settings) {
    var id = 0;
    var hidden_ids = [];
    var excluded_ids = [];
    $(columns_settings).each( function() {
        if ( this['is_hidden'] == "1" ) {
            hidden_ids.push( id );
        }
        if ( this['cannot_be_toggled'] == "1" ) {
            excluded_ids.push( id );
        }
        id++;
    });
    dt_parameters[ "oColVis" ] = { "aiExclude": excluded_ids };
    var table = $(selector).dataTable($.extend(true, {}, dataTablesDefaults, dt_parameters));

    $(hidden_ids).each(function(index, value) {
        table.fnSetColumnVis( value, false );
    });

    return table;
}

</script>
