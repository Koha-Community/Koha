// function to test all fields in forms and nav in different forms(1 ,2 or 3)
function check_form_borrowers(nav){
    var statut=0;
    var message = "";
    var message_champ="";
    if (document.form.check_member.value == 1 )
    {
        if (document.form.answernodouble) {
            if( (!(document.form.answernodouble.checked))){
                document.form.nodouble.value=0;
            } else {
                document.form.nodouble.value=1;
            }
        }
    }

    //patrons form to test if you checked no to the question of double
    if (statut!=1 && document.form.check_member.value > 0 ) {
        if (!(document.form.answernodouble.checked)){
            message_champ += __("Please confirm whether this is a duplicate patron");
            statut=1;
            document.form.nodouble.value=0;
        } else {
            document.form.nodouble.value=1;
        }
    }

    if (statut==1){
        //alert if at least 1 error
        alert(message+"\n"+message_champ);
        return false;
    } else {
        return true;
    }
}

function clear_entry(node) {
    var original = $(node).parent();
    $("textarea", original).val('');
    $("select", original).val('');
}

function clone_entry(node) {
    var original = $(node).parent();
    var clone = original.clone();

    var newId = 50 + parseInt(Math.random() * 100000);
    $("input,select,textarea", clone).attr('id', function() {
        return this.id.replace(/patron_attr_\d+/, 'patron_attr_' + newId);
    });
    $("input,select,textarea", clone).attr('name', function() {
        return this.name.replace(/patron_attr_\d+/, 'patron_attr_' + newId);
    });
    $("label", clone).attr('for', function() {
        return $(this).attr("for").replace(/patron_attr_\d+/, 'patron_attr_' + newId);
    });
    $("input#patron_attr_" + newId, clone).attr('value','');
    $("select#patron_attr_" + newId, clone).attr('value','');
    $(original).after(clone);
    return false;
}

function update_category_code(category_code) {
    if ( $(category_code).is("select") ) {
        category_code = $("#categorycode_entry").find("option:selected").val();
    }
    var mytables = $(".attributes_table");
    $(mytables).find("li").hide();
    $(mytables).find(" li[data-category_code='"+category_code+"']").show();
    $(mytables).find(" li[data-category_code='']").show();

    //Change password length hint
    var hint = $("#password").siblings(".hint").first();
    var min_length = $('select'+category_selector+' option:selected').data('pwdLength');
    var hint_string = __("Minimum password length: %s").format(min_length);
    hint.html(hint_string);
}

function select_user(borrowernumber, borrower, relationship) {
    let is_guarantor = $(`.guarantor-details[data-borrowernumber=${borrowernumber}]`).length;

    if ( is_guarantor ) {
        alert("Patron is already a guarantor for this patron");
    } else {
        $('#guarantor_id').val(borrowernumber);
        $('#guarantor_surname').val(borrower.surname);
        $('#guarantor_firstname').val(borrower.firstname);

        var fieldset = $('#guarantor_template').clone();
        fieldset.removeAttr('id');

        var guarantor_id = $('#guarantor_id').val();
        if ( guarantor_id ) {
            fieldset.find('.new_guarantor_id').first().val( guarantor_id );
            fieldset.find('.new_guarantor_id_text').first().text( borrower.cardnumber );
            fieldset.find('.new_guarantor_link').first().attr("href", "/cgi-bin/koha/members/moremember.pl?borrowernumber=" + guarantor_id );
        } else {
            fieldset.find('.guarantor_id').first().hide();
        }
        $('#guarantor_id').val("");

        var guarantor_surname = $('#guarantor_surname').val();
        fieldset.find('.new_guarantor_surname').first().val( guarantor_surname );
        fieldset.find('.new_guarantor_surname_text').first().text( guarantor_surname );
        $('#guarantor_surname').val("");

        var guarantor_firstname = $('#guarantor_firstname').val();
        fieldset.find('.new_guarantor_firstname').first().val( guarantor_firstname );
        fieldset.find('.new_guarantor_firstname_text').first().text( guarantor_firstname );
        $('#guarantor_firstname').val("");

        var guarantor_relationship = $('#relationship').val();
        fieldset.find('.new_guarantor_relationship').first().val( guarantor_relationship );
        $('#relationship').find('option:eq(0)').prop('selected', true);

        fieldset.find('.guarantor-details').first().attr( 'data-borrowernumber', borrowernumber );

        $('#guarantor_relationships').append( fieldset );
        fieldset.show();

        if ( relationship ) {
            fieldset.find('.new_guarantor_relationship').val(relationship);
        }
    }

    return 0;
}

function CalculateAge(dateofbirth) {
    var today = new Date();
    var dob = new Date(dateofbirth);
    var age = {};

    age.year = today.getFullYear() - dob.getFullYear();
    age.month = today.getMonth() - dob.getMonth();
    var day = today.getDate() - dob.getDate();

    if(day < 0) {
        age.month = parseInt(age.month) -1;
    }

    if(age.month < 0) {
        age.year = parseInt(age.year) -1;
        age.month = 12 + age.month;
    }

    return age;
}

function write_age() {
    var hint = $("#dateofbirth_hint");
    hint.html(dateformat);

    var age = CalculateAge(document.form.dateofbirth.value);

    if (!age.year && !age.month) {
        return;
    }

    var age_string;
    if (age.year || age.month) {
        age_string = __("Age") + ": ";
    }

    if (age.year) {
        age_string += age.year > 1 ? __("%s years").format(age.year) : __("%s year").format(age.year);
        age_string += " ";
    }

    if (age.month) {
        age_string += age.month > 1 ? __("%s months").format(age.month) : __("%s month").format(age.month);
    }

    hint.html(age_string);
}

$(document).ready(function(){
    if($("#yesdebarred").is(":checked")){
        $("#debarreduntil").show();
    } else {
        $("#debarreduntil").hide();
    }
    $("#yesdebarred,#nodebarred").change(function(){
        if($("#yesdebarred").is(":checked")){
            $("#debarreduntil").show();
            $("#datedebarred").focus();
        } else {
            $("#debarreduntil").hide();
        }
    });
    var mandatory_fields = $("input[name='BorrowerMandatoryField']").val().split ('|');
    $(mandatory_fields).each(function(){
        let input = $("[name='"+this+"']")
        if ( input.hasClass('flatpickr') ) {
            $(input).siblings('.flatpickr_wrapper').find('input.flatpickr').prop('required', true)
        }
        input.prop('required', true);
    });

    $("fieldset.rows input, fieldset.rows select").addClass("noEnterSubmit");

    $('body').on('click', '#guarantor_search', function(e) {
        e.preventDefault();
        var newin = window.open('/cgi-bin/koha/members/search.pl?columns=cardnumber,name,category,branch,dateofbirth,address-library,action','popup','width=1024,height=768,resizable=no,toolbar=false,scrollbars=yes,top');
    });

    $('#guarantor_relationships').on('click', '.guarantor_cancel', function(e) {
        e.preventDefault();
        $(this).parents('fieldset').first().remove();
    });

    $(document.body).on('change','.select_city',function(){
        var selected_city = $(this).val();
        var addressfield = $(this).data("addressfield");
        var myRegEx=new RegExp(/(.*)\|(.*)\|(.*)\|(.*)/);
        var matches = selected_city.match( myRegEx );
        $("#" + addressfield + "zipcode").val( matches[1] );
        $("#" + addressfield + "city").val( matches[2] );
        $("#" + addressfield + "state").val( matches[3] );
        $("#" + addressfield + "country").val( matches[4] );
    });

    dateformat = $("#dateofbirth").siblings(".hint").first().html();

    if( $('#dateofbirth').length ) {
        write_age();
    }

    $.validator.addMethod(
        "phone",
        function(value, element, phone) {
            let e164_re = /^((\+?|(0{2})?)?[1-9]{0,2})?\d{1,12}$/;
            let has_plus = value.charAt(0) === '+';
            value = value.replace(/\D/g,'');
            if ( has_plus ) value = '+' + value;
            element.value = value;

            return this.optional(element) || e164_re.test(value);
        },
        jQuery.validator.messages.phone);

    $("#entryform").validate({
        rules: {
            email: {
                email: true
            },
            emailpro: {
                email: true
            },
            B_email: {
                email: true
            },
            password: {
               password_strong: true,
               password_no_spaces: true
            },
            password2: {
               password_match: true
            },
            SMSnumber: {
               phone: true,
            }
        },
        submitHandler: function(form) {
            $("body, form input[type='submit'], form button[type='submit'], form a").addClass('waiting');
            if (form.beenSubmitted)
                return false;
            else
                form.beenSubmitted = true;
                form.submit();
            }
    });

    var mrform = $("#manual_restriction_form");
    var mrlink = $("#add_manual_restriction");
    mrform.hide();
    mrlink.on("click",function(e){
        $(this).hide();
        mrform.show();
        e.preventDefault();
    });

    $("#cancel_manual_restriction").on("click",function(e){
        $('#debarred_expiration').val('');
        $('#add_debarment').val(0);
        $('#debarred_comment').val('');
        mrlink.show();
        mrform.hide();
        e.preventDefault();
    });
    $('#floating-save').css( { bottom: parseInt( $('#floating-save').css('bottom') ) + $('#changelanguage').height() + 'px' } );
    $('#qa-save').css( {
        bottom: parseInt( $('#qa-save').css('bottom') ) + $('#changelanguage').height() + 'px' ,
        "background-color": "rgba(185, 216, 217, 0.6)",
        "bottom": "3%",
        "position": "fixed",
        "right": "1%",
        "width": "150px",
    } );
});
