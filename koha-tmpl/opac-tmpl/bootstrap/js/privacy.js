/* global __ confirmDelete */
$(document).ready(function () {
    $(".privacy-confirm-delete").on("click", function () {
        return confirmDelete(
            __("Warning: Cannot be undone. Please confirm once again")
        );
    });

    $("#never-warning").hide();
    $("#privacy").on("change", function () {
        if ($(this).val() == "2") {
            $("#never-warning").show();
        } else {
            $("#never-warning").hide();
        }
    });
});
