/* global dataTablesDefaults ERR_NO_RECORD_SELECTED ERR_INVALID_QUANTITY ERR_FUNDS_MISSING MSG_LOADING */

$(document).ready(function() {
    $("#files").dataTable($.extend(true, {}, dataTablesDefaults, {
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
            { "sType": "anti-the", "aTargets" : [ "anti-the" ] },
            { "sType": "title-string", "aTargets" : [ "title-string" ] }
        ],
        "sPaginationType": "four_button",
        "aaSorting": []
    }) );

    var all_budget_id = $("#all_budget_id");

    if( !all_budget_id.val() ){
        $(".fund label, .fund select").addClass("required").prop("required", true);
        $(".fund span.required").show();
    }

    all_budget_id.on("change", function(){
        if( $(this).val() != "" ){
            $(".fund label, .fund select").removeClass("required").prop("required", false);
            $(".fund select").each(function(){
                if( $(this).val() == '' ){
                    $(this).val( all_budget_id.val() );
                }
            });
            $(".fund span.required").hide();
        } else {
            $(".fund label, .fund select").addClass("required").prop("required", true);
            $(".fund span.required").show();
        }
    });

    $("#records_to_import fieldset.rows div").hide();
    $('input:checkbox[name="import_record_id"]').change(function(){
        var container = $(this).parents("fieldset");
        if ( $(this).is(':checked') ) {
            $(container).addClass("selected");
            $(container).removeClass("unselected");
            $(container).find("div").toggle(true);
        } else {
            $(container).addClass("unselected");
            $(container).removeClass("selected");
            $(container).find("div").toggle(false);
        }
    } );

    $("input:checkbox").prop("checked", false);
    $("div.biblio.unselected select").prop('disabled', false);
    $("div.biblio.unselected input").prop('disabled', false);

    $("#checkAll").click(function(){
        $("#Aform").checkCheckboxes();
        $("input:checkbox[name='import_record_id']").change();
        return false;
    });
    $("#unCheckAll").click(function(){
        $("#Aform").unCheckCheckboxes();
        $("input:checkbox[name='import_record_id']").change();
        return false;
    });

    $("#Aform").on("submit", function(){
        if ( $("input:checkbox[name='import_record_id']:checked").length < 1 ) {
            alert( ERR_NO_RECORD_SELECTED );
            return false;
        }

        var error = 0;
        $("input:checkbox[name='import_record_id']:checked").parents('fieldset').find('input[name="quantity"]').each(function(){
            if ( $(this).val().length < 1 || isNaN( $(this).val() ) ) {
                error++;
            }
        });
        if ( error > 0 ) {
            alert( error + " " + ERR_INVALID_QUANTITY );
            return false;

        }

        if (! all_budget_id.val() ) {
            // If there is no default fund
            error = 0;
            $(".selected [name='budget_id']").each(function(){
                if (!$(this).val()) {
                    error++;
                }
            });
            if ( error > 0 ) {
                alert( ERR_FUNDS_MISSING );
                return false;
            }
        }

        return disableUnchecked($(this));
    });

    $('#tabs').tabs();
    $(".previewData").on("click", function(e){
        e.preventDefault();
        var ltitle = $(this).text();
        var page = $(this).attr("href");
        $("#dataPreviewLabel").text(ltitle);
        $("#dataPreview .modal-body").load(page + " div");
        $('#dataPreview').modal({show:true});
    });
    $("#dataPreview").on("hidden.bs.modal", function(){
        $("#dataPreviewLabel").html("");
        $("#dataPreview .modal-body").html("<div id=\"loading\"><img src=\"[% interface | html %]/[% theme | html %]/img/spinner-small.gif\" alt=\"\" /> " + MSG_LOADING + "</div>");
    });
});

function disableUnchecked(){
    $("fieldset.biblio.unselected").each(function(){
        $(this).remove();
    });
    return 1;
}