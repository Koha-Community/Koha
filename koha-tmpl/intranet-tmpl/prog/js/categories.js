/* global __ */

jQuery.validator.addMethod(
    "letters_numbers",
    function (value, element) {
        var patt = /^[a-zA-Z0-9\-_]+$/g;
        if (patt.test(element.value)) {
            return true;
        } else {
            return false;
        }
    },
    __(
        "Category code can only contain the following characters: letters, numbers, - and _."
    )
);

jQuery.validator.addMethod(
    "enrollment_period",
    function () {
        enrolmentperiod = $("#enrolmentperiod").val();
        enrolmentperioddate = $("#enrolmentperioddate").val();
        if (
            $("#enrolmentperiod").val() !== "" &&
            $("#enrolmentperioddate").val() !== ""
        ) {
            return false;
        } else {
            return true;
        }
    },
    __("Please choose an enrollment period in months OR by date.")
);

$(document).ready(function () {
    KohaTable(
        "patron_categories",
        {
            columnDefs: [
                {
                    targets: [-1],
                    orderable: false,
                    searchable: false,
                },
                {
                    targets: [3, 4, 5],
                    type: "natural",
                },
            ],
            pagingType: "full",
            exportColumns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        },
        table_settings
    );

    if ($("#branches option:selected").length < 1) {
        $("#branches option:first").attr("selected", "selected");
    }

    $("#categorycode").on("blur", function () {
        toUC(this);
    });

    $("#category_form").validate({
        rules: {
            categorycode: {
                required: true,
                letters_numbers: true,
            },
            description: "required",
            enrolmentperiod: {
                required: function (element) {
                    return $("#enrolmentperioddate").val() === "";
                },
                digits: true,
                enrollment_period: true,
                min: 1,
            },
            enrolmentperioddate: {
                required: function (element) {
                    return $("#enrolmentperiod").val() === "";
                },
                enrollment_period: true,
            },
            password_expiry_days: {
                digits: true,
            },
            dateofbirthrequired: {
                digits: true,
            },
            upperagelimit: {
                digits: true,
            },
            enrolmentfee: {
                number: true,
            },
            reservefee: {
                number: true,
            },
            category_type: {
                required: true,
            },
            min_password_length: {
                digits: true,
            },
        },
        messages: {
            enrolmentperiod: {
                required: __(
                    "Please choose an enrollment period in months OR by date."
                ),
            },
            enrolmentperioddate: {
                required: __(
                    "Please choose an enrollment period in months OR by date."
                ),
            },
        },
    });

    let blocked_actions_select = $("select#block_expired[multiple='multiple']");
    blocked_actions_select.multipleSelect({
        placeholder: _("Please select ..."),
        selectAll: false,
        hideOptgroupCheckboxes: true,
        allSelected: _("All selected"),
        countSelected: _("# of % selected"),
        noMatchesFound: _("No matches found"),
        onClick: function (view) {
            if (
                view.value == "follow_syspref_BlockExpiredPatronOpacActions" &&
                view.selected
            ) {
                blocked_actions_select.multipleSelect("uncheck", "hold");
                blocked_actions_select.multipleSelect("uncheck", "renew");
                blocked_actions_select.multipleSelect("uncheck", "ill_request");
            } else if (
                view.value != "follow_syspref_BlockExpiredPatronOpacActions" &&
                view.selected
            ) {
                blocked_actions_select.multipleSelect(
                    "uncheck",
                    "follow_syspref_BlockExpiredPatronOpacActions"
                );
            }
        },
    });
});
