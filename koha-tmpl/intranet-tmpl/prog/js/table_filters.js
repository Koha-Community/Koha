function activate_filters(id) {
    var table = $("#" + id + " table");
    if (table.length == 1) {
        filters_row = table.find('thead tr.filters_row');

        var aoColumns = [];
        filters_row.find('th').each(function() {
            if(this.className === "NoSort"){
                aoColumns.push(null);
            } else {
                aoColumns.push('text');
            }
        });

        if (table.find('thead tr.columnFilter').length == 0) {
            table.dataTable().columnFilter({
                'sPlaceHolder': 'head:after'
                ,   'aoColumns': aoColumns
            });
            filters_row.addClass('columnFilter');
        }
        filters_row.show();
    }

    $('#' + id + '_activate_filters')
        .html('<i class="fa fa-filter"></i> ' + _("Deactivate filters") )
        .unbind('click')
        .click(function() {
            deactivate_filters(id);
            return false;
        });
}

function deactivate_filters(id) {
    filters_row = $("#" + id + " table").find('thead tr.filters_row');

    filters_row.find('input[type="text"]')
        .val('')            // Empty filter text boxes
        .trigger('keyup')   // Filter (display all rows)
        .trigger('blur');   // Reset value to the column name
    filters_row.hide();

    $('#' + id + '_activate_filters')
        .html('<i class="fa fa-filter"></i> ' + _("Activate filters") )
        .unbind('click')
        .click(function() {
            activate_filters(id);
            return false;
        });
}
