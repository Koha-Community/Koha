jQuery.validator.addMethod( "letters_numbers", function(value,element){
    var patt = /^[a-zA-Z0-9\-_]+$/g;
    if (patt.test(element.value)) {
        return true;
    } else {
        return false;
    }
    }, MSG_CATEGORYCODE_CHARS
);

jQuery.validator.addMethod( "enrollment_period", function(){
        enrolmentperiod = $("#enrolmentperiod").val();
        enrolmentperioddate = $("#enrolmentperioddate").val();
        if ( $("#enrolmentperiod").val() !== "" && $("#enrolmentperioddate").val() !== "" ) {
            return false;
        } else {
            return true;
        }
    }, MSG_ONE_ENROLLMENTPERIOD
);


$(document).ready(function() {
    $("#table_categorie").dataTable($.extend(true, {}, dataTablesDefaults, {
        "aoColumnDefs": [{
            "aTargets": [-1],
            "bSortable": false,
            "bSearchable": false
        }, {
            "aTargets": [3, 4, 5],
            "sType": "natural"
        }, ],
        "aaSorting": [
            [1, "asc"]
        ],
        "sPaginationType": "four_button"
    }));

    $("#enrolmentperioddate").datepicker({
        minDate: 1
    }); // Require that "until date" be in the future

    if ($("#branches option:selected").length < 1) {
        $("#branches option:first").attr("selected", "selected");
    }

    $("#categorycode").on("blur",function(){
        toUC(this);
    });

    $("#category_form").validate({
        rules: {
            categorycode: {
                required: true,
                letters_numbers: true
            },
            description: "required",
            enrolmentperiod: {
                required: function(element){
                    return $("#enrolmentperioddate").val() === "";
                },
                digits: true,
                enrollment_period: true
            },
            enrolmentperioddate: {
                required: function(element){
                    return $("#enrolmentperiod").val() === "";
                },
                enrollment_period: true
            },
            dateofbirthrequired: {
                digits: true
            },
            upperagelimit: {
                digits: true
            },
            enrolmentfee: {
                number: true
            },
            reservefee: {
                number: true
            },
            category_type: {
                required: true
            }
        },
        messages: {
            enrolmentperiod: {
                required: MSG_ONE_ENROLLMENTPERIOD
            },
            enrolmentperioddate: {
                required: MSG_ONE_ENROLLMENTPERIOD
            }
        }

    });
});
