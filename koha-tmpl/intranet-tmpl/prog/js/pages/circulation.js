$(document).ready(function() {
    $("#CheckAllExports").on("click",function(){
        $(".export:visible").prop("checked", true);
        return false;
    });
    $("#UncheckAllExports").on("click",function(){
        $(".export:visible").prop("checked", false);
        return false;
    });

    $('#patronlists').tabs({
        activate: function( event, ui ) {
            $('#'+ui.newTab.context.id).click();
        }
    });

    $("#borrower_messages .cancel").on("click",function(){
        $("#add_message_form").hide();
        $("#addmessage").show();
    });

    $("#addmessage").on("click",function(){
        $(this).hide();
        $("#add_message_form").show();
     });

    $("input.radio").on("click",function(){
        radioCheckBox($(this));
    });

    $("#newduedate").datetimepicker({
        onClose: function(dateText, inst) {
            validate_date(dateText, inst);
        },
        minDate: 1, // require that renewal date is after today
        hour: 23,
        minute: 59
    }).on("change", function(e) {
        if ( ! is_valid_date( $(this).val() ) ) {$(this).val("");}
    });
    $("#duedatespec").datetimepicker({
        onClose: function(dateText, inst) {
            if ( validate_date(dateText, inst) ) {
                $("#barcode").focus();
            }
        },
        hour: 23,
        minute: 59
    }).on("change", function(e, value) {
        if ( ! is_valid_date( $(this).val() ) ) {$(this).val("");}
    });
    $("#export_submit").on("click",function(){
        export_checkouts($("#issues-table-output-format").val());
        return false;
    });

    var checkout_settings = $(".checkout-settings");
    var checkout_settings_icon = $(".checkout-settings-icon");

    // If any checkboxes in the checkout settings are selected, show the settings by default
    if ( $(".checkout-settings input:checked,#duedatespec[value!='']").length ) {
        checkout_settings.show();
        checkout_settings_icon.removeClass("fa-caret-right").addClass("fa-caret-down");
    } else {
        checkout_settings.hide();
        checkout_settings_icon.removeClass("fa-caret-down").addClass("fa-caret-right");
    }

    $("#show-checkout-settings a").on("click",function(){
        if( checkout_settings.is(":hidden")){
            checkout_settings.show();
            checkout_settings_icon.removeClass("fa-caret-right").addClass("fa-caret-down");
        } else {
            $("#barcode").focus();
            checkout_settings.hide();
            checkout_settings_icon.removeClass("fa-caret-down").addClass("fa-caret-right");
        }
    });

    $(".circ_setting").on("click",function(){
        $("#barcode").focus();
    });

    $("#itemSearchFallback").ready(function(){
        $("#itemSearchFallback").modal("show");
    });

    // Debarments
    $("div#reldebarments .remove_restriction").on("click",function(){
        return confirm(_("Remove restriction?"));
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
        mrlink.show();
        mrform.hide();
        e.preventDefault();
    });
    $(".clear-date").on("click",function(e){
        e.preventDefault();
        var fieldID = this.id.replace("clear-date-","");
        $("#" + fieldID).val("");
    });


});

function export_checkouts(format) {
    if ($("input:checkbox[name='biblionumbers']:checked").length < 1){
        alert(MSG_EXPORT_SELECT_CHECKOUTS);
        return;
    }

    $("input:checkbox[name='biblionumbers']").each( function(){
        var input_item = $(this).siblings("input:checkbox");
        if ( $(this).is(":checked") ) {
            $(input_item).prop("checked", true);
        } else {
            $(input_item).prop("checked", false);
        }
    } );

    if (format == 'iso2709_995') {
        format = 'iso2709';
        $("#dont_export_item").val(0);
    } else if (format == 'iso2709') {
        $("#dont_export_item").val(1);
    }

    document.getElementById("output_format").value = format;
    document.issues.submit();
}

function validate1(date) {
    var today = new Date();
    if ( date < today ) {
        return true;
     } else {
        return false;
     }
}
