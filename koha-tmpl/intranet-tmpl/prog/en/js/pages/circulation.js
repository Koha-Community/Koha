$(document).ready(function() {
    $('#patronlists').tabs();
    var allcheckboxes = $(".checkboxed");
    $("#renew_all").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=items]");
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]");
    });
    $("#CheckAllitems").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=items]");
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]"); return false;
    });
    $("#CheckNoitems").on("click",function(){
        allcheckboxes.unCheckCheckboxes(":input[name*=items]"); return false;
    });
    $("#CheckAllreturns").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=barcodes]");
        allcheckboxes.unCheckCheckboxes(":input[name*=items]"); return false;
    });
    $("#CheckNoreturns" ).on("click",function(){
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]"); return false;
    });

    $("#CheckAllexports").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=biblionumbers]");
        allcheckboxes.unCheckCheckboxes(":input[name*=items]");
        return false;
    });
    $("#CheckNoexports").on("click",function(){
        allcheckboxes.unCheckCheckboxes(":input[name*=biblionumbers]");
        return false;
    });

    $("#relrenew_all").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=items]");
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]");
    });
    $("#relCheckAllitems").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=items]");
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]"); return false;
    });
    $("#relCheckNoitems").on("click",function(){
        allcheckboxes.unCheckCheckboxes(":input[name*=items]"); return false;
    });
    $("#relCheckAllreturns").on("click",function(){
        allcheckboxes.checkCheckboxes(":input[name*=barcodes]");
        allcheckboxes.unCheckCheckboxes(":input[name*=items]"); return false;
    });
    $("#relCheckNoreturns").on("click",function(){
        allcheckboxes.unCheckCheckboxes(":input[name*=barcodes]"); return false;
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
    // Clicking the table cell checks the checkbox inside it
    $("td").on("click",function(e){
        if(e.target.tagName.toLowerCase() == 'td'){
           $(this).find("input:checkbox:visible").each( function() {
                if($(this).attr("checked")){
                    $(this).removeAttr("checked");
                } else {
                    $(this).attr("checked","checked");
                    radioCheckBox($(this));
                }
           });
        }
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
    document.issues.action="/cgi-bin/koha/tools/export.pl";
    document.getElementById("export_format").value = format;
    document.issues.submit();

    /* Reset form action to its initial value */
    document.issues.action="/cgi-bin/koha/reserve/renewscript.pl";

}

function validate1(date) {
    var today = new Date();
    if ( date < today ) {
        return true;
     } else {
        return false;
     }
}

// prevent adjacent checkboxes from being checked simultaneously
function radioCheckBox(box){
    box.parents("td").siblings().find("input:checkbox:visible").each(function(){
        if($(this).attr("checked")){
            $(this).removeAttr("checked");
        }
    });
 }
