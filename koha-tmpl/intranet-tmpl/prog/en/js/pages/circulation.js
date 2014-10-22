$(document).ready(function() {
    $("#CheckAllExports").on("click",function(){
        $(".export:visible").attr("checked", "checked" );
        return false;
    });
    $("#UncheckAllExports").on("click",function(){
        $(".export:visible").removeAttr("checked");
        return false;
    });

    $('#patronlists').tabs({
        activate: function( event, ui ) {
            $('#'+ui.newTab.context.id).click();
        }
    });

    $("#messages ul").after("<a href=\"#\" id=\"addmessage\">"+MSG_ADD_MESSAGE+"</a>");

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
        minDate: 1, // require that renewal date is after today
        hour: 23,
        minute: 59
    });
    $("#duedatespec").datetimepicker({
        onClose: function(dateText, inst) { $("#barcode").focus(); },
        hour: 23,
        minute: 59
    });
    $("#export_submit").on("click",function(){
        var export_format = $("#export_formats").val();
        export_checkouts(export_format);
        return false;
    });

    toggle_onsite_checkout();
    $("#onsite_checkout").click(function(){
        toggle_onsite_checkout();
    });
});

function export_checkouts(format) {
    if ($("input:checkbox[name='biblionumbers'][checked]").length < 1){
        alert(MSG_EXPORT_SELECT_CHECKOUTS);
        return;
    }

    $("input:checkbox[name='biblionumbers']").each( function(){
        var input_item = $(this).siblings("input:checkbox");
        if ( $(this).is(":checked") ) {
            $(input_item).attr("checked", "checked");
        } else {
            $(input_item).attr("checked", "");
        }
    } );

    if (format == 'iso2709_995') {
        format = 'iso2709';
        $("#dont_export_item").val(0);
    } else if (format == 'iso2709') {
        $("#dont_export_item").val(1);
    }

    document.getElementById("export_format").value = format;
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
