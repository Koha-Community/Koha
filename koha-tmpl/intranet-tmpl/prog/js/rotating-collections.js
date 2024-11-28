/* global _ */

$(document).ready(function () {
    $("#barcode").focus();

    $(".confirmdelete").click(function () {
        return confirm(
            __("Are you sure you want to delete this rotating collection?")
        );
    });

    $(".removeitem").on("click", function () {
        $(this).parents("tr").addClass("warn");
        if (confirm(__("Are you sure you want to remove this item?"))) {
            $(this).parents("form").submit();
            return true;
        } else {
            $(this).parents("tr").removeClass("warn");
            return false;
        }
    });

    if ($("#rotating-collections-table").length > 0) {
        $("#rotating-collections-table").kohaTable({
            autoWidth: false,
            columnDefs: [
                { targets: [-1], orderable: false, searchable: false },
            ],
            pagingType: "full",
        });
    }
});
