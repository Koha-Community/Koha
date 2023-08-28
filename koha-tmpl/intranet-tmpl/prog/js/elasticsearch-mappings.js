/* global __ dataTablesDefaults */

function clean_line(line) {
    $(line).find('input[type="text"]').val("");
    $(line).find('select').find('option:first').attr("selected", "selected");
}

function clone_line(line) {
    var new_line = $(line).clone();
    $(new_line).removeClass("nodrag nodrop");
    $(new_line).find('td:last-child>a').removeClass("add").addClass("delete").html( __("Delete") );
    $(new_line).find('[data-id]').each(function () {
        $(this).attr({ name: $(this).attr('data-id') }).removeAttr('data-id');
    });
    $(new_line).find("select").each(function () {
        var attr = $(this).attr('name');
        var val = $(line).find('[data-id="' + attr + '"]').val();
        $(this).find('option[value="' + val + '"]').attr("selected", "selected");
    });
    return new_line;
}

function tableInit( oldtabid, newtabid ) {
    if ( oldtabid ){
        var oldTableId = $("#" + oldtabid + "_table");
        oldTableId.DataTable().destroy();
    }

    var newTableId = $("#" + newtabid + "_table");
    newTableId.DataTable(
        $.extend(true, {}, dataTablesDefaults, {
            "columnDefs": [
                { "orderable": false, "searchable": false, 'targets': ['NoSort'] },
            ],
            "paging": false,
            "autoWidth": false
        }));
}

$(document).ready(function () {

    tableInit( "", "search_fields");

    $("a[data-toggle='tab']").on("shown.bs.tab", function (e) {
        var oldtabid = $(e.relatedTarget).data("tabname");
        var newtabid = $(e.target).data("tabname");
        tableInit( oldtabid, newtabid );
    });

    $('.delete').click(function () {
        if ($(this).hasClass('mandatory') && $(".mandatory[data-field_name=" + $(this).attr('data-field_name') + "]").length < 2) {
            alert( __("This field is mandatory and must have at least one mapping") );
            return;
        } else {
            var table = $(this).closest('table');
            let dt = $(table).DataTable();
            dt.row( $(this).closest('tr') ).remove().draw();
        }
    });

    $("table.mappings").tableDnD({
        onDragClass: "dragClass highlighted-row",
    });

    $('.add').click(function () {
        var table = $(this).closest('table');
        let table_id = table.attr('id');
        var index_name = $(table).attr('data-index_name');
        var line = $(this).closest("tr");
        var marc_field = $(line).find('input[data-id="mapping_marc_field"]').val();
        if (marc_field.length > 0) {
            var new_line = clone_line(line);
            new_line.appendTo($('table[data-index_name="' + index_name + '"]>tbody'));
            let dt = $('#' + table_id).DataTable();
            dt.row.add(new_line).draw();

            $(table).on( 'click', '.delete', function () {
                var table = $(this).closest('table');
                let dt = $(table).DataTable();
                dt.row( $(this).closest('tr') ).remove().draw();
            } );

            clean_line(line);

            $(table).tableDnD({
                onDragClass: "dragClass highlighted-row",
            });
        }
    });
    $("#facet_biblios > table").tableDnD({
        onDragClass: "dragClass highlighted-row",
    });

    $("#es_mappings").on("submit", function(e){
        let table_ids = ['search_fields_table', 'mapping_biblios_table', 'mapping_authorities_table'];
        $(table_ids).each(function(){
            let table;
            // Remove warning "Cannot reinitialise DataTable"
            if ( $.fn.dataTable.isDataTable( '#' + this ) ) {
                table = $('#' + this).DataTable();
            }
            else {
                table = $('#' + this).DataTable( {
                    paging: false
                } );
            }
            table.search('').draw();
        });
        return true;
    });
});
