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

    $("#tabs").tabs({
        activate: function( event, ui ){
            tableInit( ui.oldPanel.attr('id'), ui.newPanel.attr('id') );
        },
    });

    $('.delete').click(function () {
        if ($(this).hasClass('mandatory') && $(".mandatory[data-field_name=" + $(this).attr('data-field_name') + "]").length < 2) {
            alert( __("This field is mandatory and must have at least one mapping") );
            return;
        } else {
            $(this).parents('tr').remove();
        }
    });

    $("table.mappings").tableDnD({
        onDragClass: "dragClass",
    });

    $('.add').click(function () {
        var table = $(this).closest('table');
        var index_name = $(table).attr('data-index_name');
        var line = $(this).closest("tr");
        var marc_field = $(line).find('input[data-id="mapping_marc_field"]').val();
        if (marc_field.length > 0) {
            var new_line = clone_line(line);
            new_line.appendTo($('table[data-index_name="' + index_name + '"]>tbody'));
            $('.delete').click(function () {
                $(this).parents('tr').remove();
            });
            clean_line(line);

            $(table).tableDnD({
                onDragClass: "dragClass",
            });
        }
    });
    $("#facet_biblios > table").tableDnD({
        onDragClass: "dragClass",
    });
});
