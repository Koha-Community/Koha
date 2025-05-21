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
    $("#patron_categories").kohaTable(
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
            bKohaColumnsUseNames: true,
        },
        table_settings
    );

    if ($("#library_limitation").length > 0) {
        $("#library_limitation")[0].style.minWidth = "450px";
        $("#library_limitation").select2();
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
        placeholder: __("Please select ..."),
        selectAll: false,
        hideOptgroupCheckboxes: true,
        allSelected: __("All selected"),
        countSelected: __("# of % selected"),
        noMatchesFound: __("No matches found"),
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
