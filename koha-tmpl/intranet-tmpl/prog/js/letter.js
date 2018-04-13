/* Variables defined in letter.tt: */
/* global _ module add_form copy_form dataTablesDefaults no_op_set MSG_EMPTY_TITLE_AND_CONTENT MSG_EMPTY_TEMPLATES code MSG_CODE_EXISTS MSG_CODE_EXISTS_FOR_LIBRARY MSG_DT_LOADING_RECORDS interface theme */

var modal_loading = "<div id=\"loading\"><img src=\"" + interface + "/" + theme + "/img/spinner-small.gif\" alt=\"\" /> "+ MSG_DT_LOADING_RECORDS +"</div>";

var editing = 0;
if( add_form == 1 && code !== '' ){
    editing = 1;
}

function checkCodes( new_lettercode, new_branchcode ){
    $(".spinner").show();
    return $.ajax({
        data: { code: new_lettercode, branchcode: new_branchcode },
        type: 'GET',
        url: '/cgi-bin/koha/svc/letters/get/',
        async: !1,
        success: function (data) {
            if ( data.letters.length > 0 ) {
                if( new_branchcode === '' ) {
                    alert( MSG_CODE_EXISTS.format(new_lettercode));
                } else {
                    alert( MSG_CODE_EXISTS_FOR_LIBRARY.format(new_lettercode, new_branchcode) );
                }
                $(".spinner").hide();
            } else {
                $(".spinner").hide();
            }
        }
    });
}

$(document).ready(function() {
    if( add_form || copy_form ){
        $('#toolbar').fixFloat();
    }

    $("#lettert:has(tbody tr)").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'nosort' ] }
        ],
        "bPaginate": false
    }));

    if( no_op_set ){
        $('#branch').change(function() {
            $('#op').val("");
            $('#selectlibrary').submit();
        });
        $('#newnotice').click(function() {
            $('#op').val("add_form");
            return true;
        });
    }

    $("#newmodule").on("change",function(){
        var branchcode;
        if( $("#branch").val() === ""){
            branchcode = "*";
        } else {
            branchcode = $("#branch").val();
        }
        window.location.href = "/cgi-bin/koha/tools/letter.pl?op=add_form&module=" + $(this).val() + "&branchcode=" + branchcode;
    });

    $("#submit_form").on("click",function(){
        $("#add_notice").submit();
    });

    $("#add_notice").validate({
        submitHandler: function(form){
            var at_least_one_exists = 0;
            var are_valid = 1;
            $("fieldset.mtt").each( function(){
                var title = $(this).find('input[name="title"]').val();
                var content = $(this).find('textarea[name="content"]').val();
                if (
                    ( title.length === 0 && content.length > 0 ) || ( title.length > 0 && content.length === 0 )
                ) {
                    var mtt = $(this).find('input[name="message_transport_type"]').val();
                    at_least_one_exists = 1; // Only one template has to be filled in for form to be valid
                    alert( MSG_EMPTY_TITLE_AND_CONTENT.format( mtt ) );
                    are_valid = 0;
                } else if ( title.length > 0 && content.length > 0 ) {
                    at_least_one_exists = 1;
                }
            });

            if ( ! at_least_one_exists ) {
                // No templates were filled out
                alert( MSG_EMPTY_TEMPLATES );
                return false;
            }

            if ( ! are_valid ){
                return false;
            }

            // Test if code already exists in DB
            if( editing == 1 ){ // This is an edit operation
                // We don't need to check for an existing Code
            } else {
                var new_lettercode = $("#code").val();
                var new_branchcode = $("#branch").val();
                var code_check = checkCodes( new_lettercode, new_branchcode );
                if( code_check.responseJSON.letters.length > 0 ){
                    return false;
                }
            }
            form.submit();
        }
    });

    var sms_limit = 160;
    $(".content_sms").on("keyup", function(){
        var length = $(this).val().length;
        var sms_counter = ("#sms_counter_" + $(this).data('lang'));
        $(sms_counter).html(length + "/" + sms_limit + _(" characters"));
        if ( length  > sms_limit ) {
            $(sms_counter).css("color", "red");
        } else {
            $(sms_counter).css("color", "black");
        }
    });

    $( ".transport-types" ).accordion({ collapsible: true, active:false, animate: 200 });

    $(".insert").on("click",function(){
        var containerid = $(this).data("containerid");
        insertValueQuery( containerid );
    });

    $("#saveandcontinue").on("click",function(e){
        e.preventDefault();
        $("#redirect").val("just_save");
        $("#submit_form").click();
    });

    $("#tabs").tabs();

    $("body").on("click", ".preview_template", function(e){
        e.preventDefault();
        var mtt = $(this).data("mtt");
        var lang = $(this).data("lang");

        var code = $("#code").val();
        var content = $("#content_"+mtt+"_"+lang).val();
        var title = $("#title_"+mtt+"_"+lang).val();

        var is_html = $("#is_html_"+mtt+"_"+lang).val();
        var page = $(this).attr("href");
        var data_preview = $("#data_preview").val();
        page += '?code='+encodeURIComponent(code);
        page += '&title='+encodeURIComponent(title);
        page += '&content='+encodeURIComponent(content);
        page += '&data_preview='+encodeURIComponent(data_preview);
        page += '&is_html='+encodeURIComponent(is_html);
        $("#preview_template .modal-body").load(page + " #main");
        $('#preview_template').modal('show');
        $("#preview_template_button").attr("href", "/cgi-bin/koha/svc/letters/convert?module="+module+"&code="+code+"&mtt="+mtt+"&lang="+lang);
    });

    $("#preview_template").on("hidden.bs.modal", function(){
        $("#preview_template_label").html("");
        $("#preview_template .modal-body").html( modal_loading );
    });

    function insertValueQuery(containerid) {
        var fieldset = $("#" + containerid);
        var myQuery = $(fieldset).find('textarea[name="content"]');
        var myListBox = $(fieldset).find('select[name="SQLfieldname"]');

        if($(myListBox).find('option').length > 0) {
            $(myListBox).find('option').each( function (){
                if ( $(this).attr('selected') && $(this).val().length > 0 ) {
                    $(myQuery).insertAtCaret("<<" + $(this).val() + ">>");
                }
            });
        }
    }

});
