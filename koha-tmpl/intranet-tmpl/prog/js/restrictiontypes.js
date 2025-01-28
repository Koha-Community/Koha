jQuery.validator.addMethod(
    "restrictionCode",
    function (value) {
        var ex = Object.keys(existing);
        return value.length > 0 && ex.indexOf(value.toUpperCase()) > -1
            ? false
            : true;
    },
    MSG_DUPLICATE_CODE
);

jQuery.validator.addMethod(
    "restrictionDisplayText",
    function (value) {
        var ex = Object.values(existing).map(function (el) {
            return el.toLowerCase();
        });
        var code = $('input[name="code"]').val();
        return value.length > 0 &&
            ex.indexOf(value.toLowerCase()) > -1 &&
            existing[code] != value
            ? false
            : true;
    },
    MSG_DUPLICATE_DISPLAY_TEXT
);

$(document).ready(function () {
    $("#restriction_types").kohaTable({
        columnDefs: [
            {
                targets: [-1],
                orderable: false,
                searchable: false,
            },
            {
                targets: [0, 1],
                type: "natural",
            },
        ],
        order: [[1, "asc"]],
        pagingType: "full",
    });

    $("#restriction_form").validate({
        rules: {
            code: {
                required: true,
                restrictionCode: true,
            },
            display_text: {
                required: true,
                restrictionDisplayText: true,
            },
        },
        messages: {
            code: {
                restrictionCode: MSG_DUPLICATE_CODE,
            },
            display_text: {
                restrictionDisplayText: MSG_DUPLICATE_DISPLAY_TEXT,
            },
        },
    });
});
