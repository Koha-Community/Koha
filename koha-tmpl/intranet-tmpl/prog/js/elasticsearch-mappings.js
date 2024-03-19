/* global __ dataTablesDefaults */

function clean_line(line) {
    $(line).find('input[type="text"]').val("");
    $(line).find('select').find('option:first').prop("selected", true);
}

function clone_line(line) {
    var new_line = $(line).clone();
    $(new_line).find('td:last-child>a').removeClass("add").addClass("delete").html('<i class="fa fa-trash"></i> %s'.format(__("Delete") ));
    $(new_line).find('[data-id]').each(function () {
        $(this).attr({ name: $(this).attr('data-id') }).removeAttr('data-id');
    });
    $(new_line).find("select").each(function () {
        var attr = $(this).attr('name');
        var val = $(line).find('[data-id="' + attr + '"]').val();
        $(this).find('option').removeAttr('selected');
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

    $(document).on('click', '.delete', function() {
        if ($(this).hasClass('mandatory') && $(".mandatory[data-field_name=" + $(this).attr('data-field_name') + "]").length < 2) {
            alert( __("This field is mandatory and must have at least one mapping") );
            return;
        } else {
            var table = $(this).closest('table');
            let dt = $(table).DataTable();
            dt.row( $(this).closest('tr') ).remove().draw();
            $(this).parents('tr').remove();
            var line = $(this).closest("tr");

            var name;
            // We clicked delete button on search fields tab.
            if (name = $(line).find('input[name="search_field_name"]').val()) {
                // Prevent user from using a search field for a mapping
                // after removing it without saving.
                $('select[data-id="mapping_search_field_name"]').each(function( index, element) {
                    $(element).find('option[value="' + name + '"]').remove();
                });
            }

            var search_field_name = $(line).find('input[name="mapping_search_field_name"]').val();
            var mappings = $('input[name="mapping_search_field_name"][type="hidden"][value="' + search_field_name + '"]');
            if (mappings.length == 0) {
                var search_field_line = $('input[name="search_field_name"][value="' + search_field_name + '"]').closest("tr");
                $(search_field_line).find('a.btn-default').removeClass('disabled');
            }
        }
    });

    $('.add').click(function () {
        var table = $(this).closest('table');
        let table_id = table.attr('id');
        var index_name = $(table).attr('data-index_name');
        var line = $(this).closest("tr");
        var marc_field = $(line).find('input[data-id="mapping_marc_field"]').val();
        if (marc_field.length > 0) {
            var new_line = clone_line(line);
            var search_field_name = $(line).find('select[data-id="mapping_search_field_name"] option:selected').text();
            new_line.appendTo($('table[data-index_name="' + index_name + '"]>tbody'));
            let dt = $('#' + table_id).DataTable();
            dt.row.add(new_line).draw();

            $(table).on( 'click', '.delete', function () {
                var table = $(this).closest('table');
                let dt = $(table).DataTable();
                dt.row( $(this).closest('tr') ).remove().draw();
            } );

            clean_line(line);
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

    $('.add-search-field').click(function() {
        var table = $(this).closest('table');
        let table_id = table.attr('id');
        let dt = $('#' + table_id).DataTable();
        var line = $(this).closest('tr');
        var search_field_name = $(line).find('input[data-id="search_field_name"]').val();
        let already_exists = dt.data().filter((row, idx) => row[0]['@data-order'] === search_field_name);
        if ( already_exists.length ) {
            alert(__("SearchField '%s' already exist".format(search_field_name)));
            return;
        }
        if (search_field_name.length > 0) {
            var new_line = clone_line(line);
            new_line.find('td:first').attr({'data-order': search_field_name});
            new_line.appendTo($('table#' + table_id + '>tbody'));
            dt.row.add(new_line).draw();

            $(table).on( 'click', '.delete', function () {
                var table = $(this).closest('table');
                let dt = $(table).DataTable();
                dt.row( $(this).closest('tr') ).remove().draw();
            } );

            clean_line(line);
        }
    });
});
