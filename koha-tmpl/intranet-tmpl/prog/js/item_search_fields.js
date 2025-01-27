/* global _ MSG_ITEM_SEARCH_DELETE_CONFIRM */

jQuery.validator.addMethod(
    "marcfield",
    function (value, element) {
        return this.optional(element) || /^[0-9a-zA-Z]+$/.test(value);
    },
    __("Please enter letters or numbers")
);

$(document).ready(function () {
    $(".field-delete").on("click", function () {
        $(this).parent().parent().addClass("highlighted-row");
        if (confirm(__("Are you sure you want to delete this field?"))) {
            return true;
        } else {
            $(this).parent().parent().removeClass("highlighted-row");
            return false;
        }
    });

    $("#search_fields").validate({
        rules: {
            label: "required",
            tagfield: {
                required: true,
                marcfield: true,
            },
            tagsubfield: {
                marcfield: true,
            },
        },
    });
});
