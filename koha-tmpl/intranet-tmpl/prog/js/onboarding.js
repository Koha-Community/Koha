function _(s) {
    return s;
} // dummy function for gettext

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function () {
    return formatstr(this, arguments);
};
function formatstr(str, col) {
    col =
        typeof col === "object"
            ? col
            : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") {
            return "%";
        }
        if (m == "%s") {
            return col[idx++];
        }
        return col[n];
    });
}

jQuery.validator.addMethod(
    "category_code_check",
    function (value, element) {
        var patt = /^[A-Za-z0-9]{0,10}$/g;
        if (patt.test(element.value)) {
            return true;
        } else {
            return false;
        }
    },
    MSG_LETTERS_NUMBERS_ONLY
);

jQuery.validator.addMethod(
    "enrollment_period",
    function () {
        enrolmentperiod = $("#enrolmentperiod").val();
        enrolmentperioddate = $("#enrolmentperioddate").val();
        if (
            ($("#enrolmentperiod").val() === "" &&
                $("#enrolmentperioddate").val() === "") ||
            ($("#enrolmentperiod").val() !== "" &&
                $("#enrolmentperioddate").val() !== "")
        ) {
            return false;
        } else {
            return true;
        }
    },
    MSG_ONLY_ONE_ENROLLMENTPERIOD
);

jQuery.validator.addMethod(
    "password_match",
    function (value, element) {
        var MSG_PASSWORD_MISMATCH = MSG_PASSWORD_MISMATCH;
        var password = document.getElementById("password").value;
        var confirmpassword = document.getElementById("password2").value;

        if (password != confirmpassword) {
            return false;
        } else {
            return true;
        }
    },
    MSG_PASSWORD_MISMATCH
);

function toUC(f) {
    var x = f.value.toUpperCase();
    f.value = x;
    return true;
}

$(document).ready(function () {
    if ($("#branches option:selected").length < 1) {
        $("#branches option:first").attr("selected", "selected");
    }
    $("#categorycode").on("blur", function () {
        toUC(this);
    });

    $("#enrolmentperioddate").flatpickr({
        /* Default Flatpickr configuration uses Font Awesome icons for arrows. Onboarding doesn't include Font Awesome, so we redefine these arrows with some SVG icons */
        nextArrow:
            '<svg width="17" height="17" viewBox="0 0 4.498 4.498" xmlns="http://www.w3.org/2000/svg"><path d="M3.761 2.491c.158.17.47.12.566-.09.085-.158.02-.356-.116-.461L2.562.292C2.445.17 2.3.282 2.217.382c-.087.102-.255.193-.195.35.107.149.254.265.378.399l1.361 1.36zm.496.017c.17-.157.12-.47-.091-.566-.158-.085-.355-.02-.46.117L2.057 3.707c-.12.118-.01.263.091.345.101.087.193.255.35.195.148-.106.264-.254.398-.378l1.36-1.36zm-.746.095c.206.006.457-.124.462-.353-.005-.23-.256-.36-.462-.354-1.054 0-2.109-.002-3.163 0-.174-.003-.234.166-.212.308.01.128-.043.3.104.369.157.056.33.02.493.03h2.778z"/></svg>',
        prevArrow:
            '<svg width="17" height="17" viewBox="0 0 4.498 4.498" xmlns="http://www.w3.org/2000/svg"><path d="M.737 2.008c-.158-.17-.47-.12-.566.09-.085.158-.02.356.116.461l1.649 1.648c.117.121.263.01.345-.09.087-.102.255-.193.195-.35-.107-.149-.254-.265-.378-.399L.737 2.008zM.241 1.99c-.17.157-.12.47.091.566.158.085.355.02.46-.117L2.441.792C2.56.674 2.45.53 2.35.447 2.249.36 2.157.192 2 .252c-.148.106-.264.254-.398.378L.242 1.99zm.746-.095C.781 1.89.53 2.02.525 2.249c.005.23.256.36.462.354 1.054 0 2.109.002 3.163 0 .174.003.234-.166.212-.308-.01-.128.043-.3-.104-.369-.157-.056-.33-.02-.493-.03H.987z"/></svg>',
        minDate: new Date().fp_incr(1),
        onReady: function (selectedDates, dateStr, instance) {
            $(instance.input)
                /* Add a wrapper element so that we can prevent the clear button from wrapping */
                .wrap("<span class='flatpickr_wrapper'></span>")
                .after(
                    $("<a/>")
                        .attr("href", "#")
                        .addClass("clear_date")
                        .on("click", function (e) {
                            e.preventDefault();
                            instance.clear();
                        })
                        .attr("aria-hidden", true)
                );
        },
    }); // Require that "until date" be in the future

    $("#category_form").validate({
        rules: {
            categorycode: {
                required: true,
                category_code_check: true,
            },
            description: {
                required: true,
            },
            enrolmentperiod: {
                required: function (element) {
                    return $("#enrolmentperioddate").val() === "";
                },
                digits: true,
                enrollment_period: true,
            },
            enrolmentperioddate: {
                required: function (element) {
                    return $("#enrolmentperiod").val() === "";
                },
                enrollment_period: true,
                // is_valid_date ($(#"enrolementperioddate").val());
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
        },
        messages: {
            enrolmentperiod: {
                required: MSG_ONE_ENROLLMENTPERIOD,
            },
            enrolmentperioddate: {
                required: MSG_ONE_ENROLLMENTPERIOD,
            },
        },
    });

    $("#createpatron").validate({
        rules: {
            surname: {
                required: true,
            },
            firstname: {
                required: true,
            },
            cardnumber: {
                required: true,
            },
            password: {
                required: true,
                password_strong: true,
                password_no_spaces: true,
            },
            password2: {
                required: true,
                password_match: true,
            },
        },
        messages: {
            password: {
                required: MSG_PASSWORD_MISMATCH,
            },
        },
    });

    $("#createitemform").validate();
    $("#createcirculationrule").validate();
});
