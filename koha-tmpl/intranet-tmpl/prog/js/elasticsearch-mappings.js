/* global __ */

function clean_line(line) {
    $(line).find('input[type="text"]').val("");
    $(line).find("select").find("option:first").prop("selected", true);
}

function build_delete_link(del_class) {
    return '<a class="btn btn-default btn-xs %s" style="cursor: pointer;"><i class="fa fa-trash"></i> %s</a>'.format(
        del_class,
        __("Delete")
    );
}

function remove_line(line) {
    var table = $(line).closest("table");
    let dt = $(table).DataTable();
    dt.row(line).remove().draw();
}

function clone_line(line) {
    var new_line = $(line).clone();
    let type = $(line).data("type");
    $(new_line)
        .find("td:last-child")
        .html(build_delete_link("delete-%s".format(type)));
    $(new_line)
        .find("[data-id]")
        .each(function () {
            $(this)
                .attr({ name: $(this).attr("data-id") })
                .removeAttr("data-id");
        });
    $(new_line)
        .find("select")
        .each(function () {
            var attr = $(this).attr("name");
            var val = $(line)
                .find('[data-id="' + attr + '"]')
                .val();
            $(this).find("option").removeAttr("selected");
            $(this)
                .find('option[value="' + val + '"]')
                .attr("selected", "selected");
        });
    return new_line;
}

function tableInit(oldtabid, newtabid) {
    if (oldtabid) {
        var oldTableId = $("#" + oldtabid + "_table");
        oldTableId.DataTable().destroy();
    }

    $("#" + newtabid + "_table").kohaTable({
        paging: false,
        autoWidth: false,
    });
}

$(document).ready(function () {
    tableInit("", "search_fields");

    $("a[data-bs-toggle='tab']").on("shown.bs.tab", function (e) {
        var oldtabid = $(e.relatedTarget).data("tabname");
        var newtabid = $(e.target).data("tabname");
        tableInit(oldtabid, newtabid);
    });

    $(document).on("click", ".delete-facet", function () {
        var line = $(this).closest("tr");
        remove_line(line);
    });
    $(document).on("click", ".delete-mapping", function () {
        var line = $(this).closest("tr");
        remove_line(line);
    });
    $(document).on("click", ".delete-search-field", function () {
        if (
            $(this).hasClass("mandatory") &&
            $(
                ".mandatory[data-field_name=" +
                    $(this).attr("data-field_name") +
                    "]"
            ).length < 2
        ) {
            alert(
                __("This field is mandatory and must have at least one mapping")
            );
            return;
        } else {
            var line = $(this).closest("tr");

            var name;
            // We clicked delete button on search fields tab.
            if (
                (name = $(line).find('input[name="search_field_name"]').val())
            ) {
                // Prevent user from using a search field for a mapping
                // after removing it without saving.
                $('select[data-id="mapping_search_field_name"]').each(
                    function (index, element) {
                        $(element)
                            .find('option[value="' + name + '"]')
                            .remove();
                    }
                );
            }

            var search_field_name = $(line)
                .find('input[name="mapping_search_field_name"]')
                .val();
            var mappings = $(
                'input[name="mapping_search_field_name"][type="hidden"][value="' +
                    search_field_name +
                    '"]'
            );
            if (mappings.length == 0) {
                var search_field_line = $(
                    'input[name="search_field_name"][value="' +
                        search_field_name +
                        '"]'
                ).closest("tr");
                $(search_field_line)
                    .find("a.btn-default")
                    .removeClass("disabled");
            }

            remove_line(line);
        }
    });

    $(".add").click(function () {
        var table = $(this).closest("table");
        let table_id = table.attr("id");
        let dt = $("#" + table_id).DataTable();
        var line = $(this).closest("tr");
        var marc_field = $(line)
            .find('input[data-id="mapping_marc_field"]')
            .val();
        let dt_data = dt.data();
        if (marc_field.length) {
            var new_line = clone_line(line);
            var index_name = $(table).attr("data-index_name");
            let dt = $("#" + table_id).DataTable();
            dt.row.add(new_line).draw();

            clean_line(line);
        }
    });

    $("#facet_biblios_table").DataTable(
        $.extend(true, {}, dataTablesDefaults, {
            columnDefs: [{ searchable: false, visible: false, targets: 0 }],
            dom: "t",
            paging: false,
            autoWidth: false,
            rowReorder: true,
        })
    );

    $("#es_mappings").on("submit", function (e) {
        let table_ids = [
            "search_fields_table",
            "mapping_biblios_table",
            "mapping_authorities_table",
        ];
        $(table_ids).each(function () {
            let table;
            // Remove warning "Cannot reinitialise DataTable"
            if ($.fn.dataTable.isDataTable("#" + this)) {
                table = $("#" + this).DataTable();
            } else {
                table = $("#" + this).DataTable({
                    paging: false,
                });
            }
            table.search("").draw();
        });
        return true;
    });

    $(".add-search-field").click(function () {
        var table = $(this).closest("table");
        let table_id = table.attr("id");
        let dt = $("#" + table_id).DataTable();
        var line = $(this).closest("tr");
        var search_field_name = $(line)
            .find('input[data-id="search_field_name"]')
            .val();
        let already_exists = dt
            .data()
            .filter((row, idx) => row[0]["@data-order"] === search_field_name);
        if (already_exists.length) {
            alert(
                __("Search field '%s' already exists").format(search_field_name)
            );
            return;
        }
        if (search_field_name.length > 0) {
            var new_line = clone_line(line);
            new_line.find("td:first").attr({ "data-order": search_field_name });
            dt.row.add(new_line).draw();

            clean_line(line);
        }
    });

    $(".add-facet").click(function () {
        var table = $(this).closest("table");
        let table_id = table.attr("id");
        let dt = $("#" + table_id).DataTable();
        var line = $(this).closest("tr");
        let selected_option = $(line).find(
            'select[data-id="facet-search-field"] option:selected'
        );
        var search_field_name = selected_option.val();
        let dt_data = dt.data();
        let already_exists = dt_data.filter(
            (row, idx) => row[1] === search_field_name
        );
        if (already_exists.length) {
            alert(__("Facet '%s' already exists").format(search_field_name));
            return;
        }
        if (search_field_name.length > 0) {
            const next_id =
                Math.max.apply(
                    null,
                    dt_data.map(row => row[0])
                ) + 1;
            const label = selected_option.data("label");
            const av_cat_select = $(clone_line(line).find("td")[2])
                .find("select")
                .attr({
                    name: "facet_av_cat_%s".format(
                        search_field_name.escapeHtml()
                    ),
                });
            new_line = [
                next_id,
                search_field_name,
                '<span>%s</span><input type="hidden" name="facet_name" value="%s" />'.format(
                    label.escapeHtml(),
                    search_field_name.escapeHtml()
                ),
                av_cat_select[0].outerHTML,
                build_delete_link(),
            ];
            dt.row.add(new_line).draw();

            clean_line(line);
        }
    });
});
