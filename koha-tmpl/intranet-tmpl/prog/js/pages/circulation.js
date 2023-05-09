/* global borrowernumber */
$(document).ready(function() {
    $("#CheckAllExports").on("click",function(){
        $(".export:visible").prop("checked", true);
        return false;
    });
    $("#UncheckAllExports").on("click",function(){
        $(".export:visible").prop("checked", false);
        return false;
    });

    $("#finesholdsissues a[data-toggle='tab']").on("shown.bs.tab", function(e){
        $(this).click();
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

    $(".clear_date").on("click", function(){
        $("#stickyduedate").prop( "checked", false );
    });

    $("#export_submit").on("click",function(){
        export_checkouts($("#issues-table-output-format").val());
        return false;
    });

    var circ_settings = $(".circ-settings");
    var circ_settings_icon = $(".circ-settings-icon");

    // If any checkboxes in the circ settings are selected, show the settings by default
    if ( $(".circ-settings input:checked,#duedatespec[value!='']").length ) {
        circ_settings.show();
        circ_settings_icon.removeClass("fa-caret-right").addClass("fa-caret-down");
    } else {
        circ_settings.hide();
        circ_settings_icon.removeClass("fa-caret-down").addClass("fa-caret-right");
    }

    $("#show-circ-settings a").on("click",function(){
        if( circ_settings.is(":hidden")){
            circ_settings.show();
            circ_settings_icon.removeClass("fa-caret-right").addClass("fa-caret-down");
        } else {
            $("#barcode").focus();
            circ_settings.hide();
            circ_settings_icon.removeClass("fa-caret-down").addClass("fa-caret-right");
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
        return confirm( __("Remove restriction?") );
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

    /* Preselect Bootstrap tab based on location hash */
    var hash = window.location.hash.substring(1);
    if( hash ){
        var activeTab = $('a[href="#' + hash + '"]');
        activeTab && activeTab.tab('show');
    }

    if ( $('#clubs_panel').length ) {
        $('#clubs-tab').on('click', function() {
            $('#clubs_panel').text(_("Loading..."));
            $('#clubs_panel').load('/cgi-bin/koha/clubs/patron-clubs-tab.pl?borrowernumber=' + borrowernumber );
        });
    }
});

function export_checkouts(format) {
    if ($("input:checkbox[name='biblionumbers']:checked").length < 1){
        alert( __("You must select checkout(s) to export") );
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
