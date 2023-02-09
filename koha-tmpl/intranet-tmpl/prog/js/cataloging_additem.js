/* global KOHA searchid biblionumber frameworkcode popup op LABEL_EDIT_ITEM LABEL_DELETE_ITEM MSG_FORM_NOT_SUBMITTED MSG_MANDATORY_FIELDS_EMPTY MSG_ADD_MULTIPLE_ITEMS MSG_ENTER_NUM_ITEMS MSG_CONFIRM_DELETE_ITEM MSG_CONFIRM_ADD_ITEM columns_settings CheckMandatorySubfields CheckMultipleAdd */

var browser = KOHA.browser(searchid, parseInt(biblionumber, 10));
browser.show();

$(document).ready(function(){

    // Remove the onclick event defined in browser.js,
    // otherwise the deletion confirmation will not work correctly
    $('a[href*="biblionumber="]').off('click');

    if( popup && op != 'saveitem' ){
        window.close();
    }

    $("fieldset.rows input, fieldset.rows select").addClass("noEnterSubmit");
    /* Inline edit/delete links */
    var biblionumber = $("input[name='biblionumber']").val();
    $("tr.editable").each(function(){
        $(this).find("td:not(:first)").on('click', function(){
            var rowid = $(this).parent().attr("id");
            var num_rowid = rowid.replace("row","");
            $(".linktools").remove();
            var edit_link = $('<a href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&frameworkcode=' + frameworkcode + '&biblionumber=' + biblionumber + '&itemnumber=' + num_rowid + '&searchid=' + searchid + '#edititem"></a>');
            $(edit_link).text( LABEL_EDIT_ITEM );
            var delete_link = $('<a href="/cgi-bin/koha/cataloguing/additem.pl?op=delitem&frameworkcode=' + frameworkcode + '&biblionumber=' + biblionumber + '&itemnumber=' + num_rowid + '&searchid=' + searchid + '"></a>');
            $(delete_link).text( LABEL_DELETE_ITEM );
            $(delete_link).on('click', function() {
                return confirm_deletion();
            });
            var tools_node = $('<span class="linktools"></span>');
            $(tools_node).append(edit_link);
            $(tools_node).append(delete_link);
            $(this).append(tools_node);
        });
    });

    $("#addnewitem").click(function(){
        if ( confirm( MSG_CONFIRM_ADD_ITEM ) ){
            window.location.href = "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=" + biblionumber;
        }
    });

    // Skip the first column
    table_settings['columns'].unshift( { cannot_be_toggled: "1" } );

    var itemst = KohaTable("itemst", {
        'bPaginate': false,
        'bInfo': false,
        "bAutoWidth": false,
        "bKohaColumnsUseNames": true
    }, table_settings);

    var multiCopyControl = $("#add_multiple_copies_span");
    var addMultipleBlock = $("#addmultiple");
    var addSingleBlock = $("#addsingle");
    var saveAsTemplateControl = $("#save_as_template_span");
    var saveTemplateBlock = $("#savetemplate");

    multiCopyControl.hide();
    $("#add_multiple_copies").on("click",function(e){
        e.preventDefault;
        addMultipleBlock.toggle();
        saveTemplateBlock.toggle();
        addSingleBlock.toggle();
        multiCopyControl.toggle();
        $('body,html').animate({ scrollTop: $('body').height() }, 100);
    });
    $("#cancel_add_multiple").on("click",function(e){
        e.preventDefault();
        addMultipleBlock.toggle();
        saveTemplateBlock.toggle();
        addSingleBlock.toggle();
        multiCopyControl.toggle();
    });

    saveAsTemplateControl.hide();
    $("#save_as_template").on("click",function(e){
        e.preventDefault;
        saveTemplateBlock.toggle();
        saveAsTemplateControl.toggle();
        $('#template_name').focus();
    });
    $("#cancel_save_as_template").on("click",function(e){
        e.preventDefault();
        saveTemplateBlock.toggle();
        saveAsTemplateControl.toggle();
    });

    $("#template_id").on("change", function() {
        let option = $(this).find(":selected");

        if ( option.data("editor") ) {
            $("#delete_template_submit").removeAttr("disabled");
        } else {
            $("#delete_template_submit").attr("disabled", "disabled");
        }

        if ( option.val() != 0 ) {
            $("#load_template_submit").removeAttr("disabled");
        } else {
            $("#load_template_submit").attr("disabled", "disabled");
        }
    });
    $("#template_id").change(); // Trigger to enable delete button if patron's template is in use
    $("#replace_template_id").on("change", function() {
        let selected = $(this).find(":selected");
        if ( selected.val() > 0 ) {
            $("#template_name_block").hide();
            $("#template_is_shared").prop("checked", selected.data("shared"));
        } else {
            $("#template_name_block").show();
            $("#template_is_shared").prop("checked", false);
        }
    });

    // Add new item to an item group
    if ( has_item_groups ) {
        $('#item-group-add-or-create-form-description-block').hide();
        $('#item-group-add-or-create-form-no-add').attr('selected', 'selected' );

        $('#item-group-add-or-create-form-select').on('change', function(){
            if ( $(this).val() == 'create' ) {
                $('#item-group-add-or-create-form-description')
                    .addClass('required')
                    .attr( 'required', 'required' );
                $('#item-group-add-or-create-form-description-block').show();
            } else {
                $('#item-group-add-or-create-form-description')
                    .removeClass('required')
                    .removeAttr('required');
                $('#item-group-add-or-create-form-description-block').hide();
            }
        });
    }

    $('#item-group-add-or-create-form-select').on('change', function() {
        if ( ! $('input.items-enumchron').val() ) {
            let item_group_selector = '#item-group-' + $(this).val();
            let enumchron = $(item_group_selector).val();
            $('input.items-enumchron').val( enumchron );
        }
    });
});

function CheckTemplateForm(f) {
    if ( $('#replace_template_id').val() == "0" &&  $('#template_name').val() == "" ) {
        alert(__("Template name is required."));
        return false;
    } else {
        return true;
    }
}

function Check(f) {
    var total_mandatory = CheckMandatorySubfields(f);
    var total_important = CheckImportantSubfields(f);
    var alertString2;
    if (total_mandatory==0) {
        // Explanation about this line:
        // In case of limited edition permission, we have to prevent user from modifying some fields.
        // But there is no such thing as readonly attribute for select elements.
        // So we use disabled instead. But disabled prevent values from being passed through the form at submit.
        // So we "un-disable" the elements just before submitting.
        // That's a bit clumsy, and if someone comes up with a better solution, feel free to improve that.
        $("select.input_marceditor").prop('disabled', false);
    } else {
        alertString2 = MSG_FORM_NOT_SUBMITTED;
        alertString2 += "\n------------------------------------------------------------------------------------\n";
        alertString2 += "\n- " + MSG_MANDATORY_FIELDS_EMPTY.format(total_mandatory);
    }
    if(total_important > 0){
        if( !alertString2 ){
            alertString2 = "";
        }
        alertString2 += "\n\n " + MSG_IMPORTANT_FIELDS_EMPTY.format(total_important);
        alertString2 += "\n\n " + MSG_CONFIRM_SAVE;
    }
    if(alertString2){
        if(total_mandatory){
             alert(alertString2);
        }else{
            var a = confirm(alertString2);
            if( a ){
                return true;
            }
        }
        return false;
    }
    return true;
}

function CheckMultipleAdd(f) {

    if (!f || isNaN(f) || !parseInt(f) == f || f <= 0) {
        alert( MSG_ENTER_NUM_ITEMS );
        return false;
    }
    // Add a soft-limit of 99 with a reminder about potential data entry error
    if (f>99) {
        return confirm( MSG_ADD_MULTIPLE_ITEMS.format(f));
    }
}

function Dopop(link,i) {
    var defaultvalue=document.forms[0].field_value[i].value;
    var newin=window.open(link+"&result=" + defaultvalue,"valuebuilder",'width=500,height=400,toolbar=false,scrollbars=yes');
}

function confirm_deletion() {
    return confirm( MSG_CONFIRM_DELETE_ITEM );
}
