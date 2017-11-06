function _(s) { return s; } // dummy function for gettext

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function() { return formatstr(this, arguments); };
function formatstr(str, col) {
    col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") { return "%"; }
        if (m == "%s") { return col[idx++]; }
        return col[n];
    });
}

jQuery.validator.addMethod( "category_code_check", function(value,element){
    var patt = /^[A-Za-z0-9]{0,10}$/g;
    if (patt.test(element.value)) {
        return true;
    } else {
        return false;
    }
    }, MSG_LETTERS_NUMBERS_ONLY
);

jQuery.validator.addMethod( "enrollment_period", function(){
      enrolmentperiod = $("#enrolmentperiod").val();
      enrolmentperioddate = $("#enrolmentperioddate").val();
      if (( $("#enrolmentperiod").val() === "" && $("#enrolmentperioddate").val() === "") || ($("#enrolmentperiod").val() !== "" && $("#enrolmentperioddate").val() !== "")) {
             return false;
      } else {
             return true;
      }
    }, MSG_ONLY_ONE_ENROLLMENTPERIOD
);

jQuery.validator.addMethod( "password_match", function(value,element){
        var MSG_PASSWORD_MISMATCH = ( MSG_PASSWORD_MISMATCH );
        var password = document.getElementById('password').value;
        var confirmpassword = document.getElementById('password2').value;

        if ( password != confirmpassword ){
               return false;
          }
          else{
               return true;
          }
    },  MSG_PASSWORD_MISMATCH
);

function toUC(f) {
    var x=f.value.toUpperCase();
    f.value=x;
    return true;
}

$(document).ready(function() {
    if ($("#branches option:selected").length < 1) {
        $("#branches option:first").attr("selected", "selected");
    }
    $("#categorycode").on("blur",function(){
         toUC(this);
    });

    $("#enrolmentperioddate").datepicker({
        minDate: 1
    }); // Require that "until date" be in the future

    $("#category_form").validate({
        rules: {
            categorycode: {
                required: true,
                category_code_check: true
            },
            description: {
                    required:true
            },
            enrolmentperiod: {
               required: function(element){
                     return $("#enrolmentperioddate").val() === "";
               },
               digits: true,
               enrollment_period: true,
            },
            enrolmentperioddate: {
                required: function(element){
                    return $("#enrolmentperiod").val() === "";
                },
                enrollment_period: true,
                // is_valid_date ($(#"enrolementperioddate").val());
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

    $("#createpatron").validate({
        rules: {
            surname: {
                required: true
            },
            firstname: {
                required: true
            },
            cardnumber: {
                required: true
            },
            password: {
                required: true,
                password_strong: true,
                password_no_spaces: true
            },
            password2: {
                required: true,
                password_match: true
            }
        },
        messages: {
            password: {
                required: MSG_PASSWORD_MISMATCH
            },
        }

    });

    $("#createitemform").validate();
    $("#createcirculationrule").validate();
});
