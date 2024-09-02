/* Variables defined in letter.tt: */
/* global _ module add_form copy_form no_op_set code interface theme KohaTable table_settings */

var modal_loading = "<div id=\"loading\"><img src=\"" + interface + "/" + theme + "/img/spinner-small.gif\" alt=\"\" /> "+ __('Loading...') +"</div>";

var editing = 0;
if( add_form == 1 && code !== '' || copy_form == 1 && code !== ''){
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
                    alert(__("A default letter with the code '%s' already exists.").format(new_lettercode));
                } else {
                    alert(__("A letter with the code '%s' already exists for '%s'.").format(new_lettercode, new_branchcode));
                }
                $(".spinner").hide();
            } else {
                $(".spinner").hide();
            }
        }
    });
}

function confirmOverwrite( new_lettercode, new_branchcode ){
    var letter_exists;
    $.ajax({
        data: { code: new_lettercode, branchcode: new_branchcode },
        type: 'GET',
        url: '/cgi-bin/koha/svc/letters/get/',
        async: !1,
        success: function (data) {
            if ( data.letters.length > 0 ) {
                letter_exists = 1;
            }
        }
    });
    if(letter_exists){
        return confirm(__("A letter with the code '%s' already exists for '%s'. Overwrite this letter?").format(new_lettercode, new_branchcode));
    }
}

var Sticky;

$(document).ready(function() {
    if( add_form || copy_form ){
        Sticky = $("#toolbar");
        Sticky.hcSticky({
            stickTo: ".main",
            stickyClass: "floating"
        });
    }

    var ntable = KohaTable("lettert", {
        "autoWidth": false,
        "paging": false,
    }, table_settings);

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
                    alert(__("Please specify title and content for %s").format(mtt));
                    are_valid = 0;
                } else if ( title.length > 0 && content.length > 0 ) {
                    at_least_one_exists = 1;
                }
            });

            if ( ! at_least_one_exists ) {
                // No templates were filled out
                alert( __("Please fill at least one template.") );
                return false;
            }

            if ( ! are_valid ){
                return false;
            }

            // Test if code already exists in DB
            if( editing == 1 ){ // This is an edit operation
                // We don't need to check for an existing Code
                // However if we're copying, provide confirm
                // pop up of overwriting existing notice or slip
                if(copy_form == 1){
                    var new_lettercode = $("#code").val();
                    var new_branchcode = $("#branch").val();
                    var confirm = confirmOverwrite( new_lettercode, new_branchcode );
                    if(confirm === false){
                        return false;
                    }
                }
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
        $(sms_counter).html(length + "/" + sms_limit + __(" characters"));
        if ( length  > sms_limit ) {
            $(sms_counter).css("color", "red");
        } else {
            $(sms_counter).css("color", "black");
        }
    });

    let section = $("#section").val();
    if( section != "" ){
        $("a[href='#" + section + "']").click();
    }

    $(".panel-group").on("shown.bs.collapse", function (e) {
        $("#section").val( e.target.id );
    }).on("hidden.bs.collapse", function (e) {
        $("#section").val("");
    });

    if( $("#tabs").length > 0 ){
        let langtab = $("#langtab").val();
        $("#tabs a[data-toggle='tab']").on("shown.bs.tab", function (e) {
            var link = e.target.hash.replace("#","");
            $("#langtab").val( link );
        });

        if( langtab != "" ){
            $("#tabs a[href='#" + langtab + "']").tab("show");
        } else {
            $("#tabs a[href='#lang_default_panel']").tab("show");
        }
    }

    $(".insert").on("click",function(){
        var containerid = $(this).data("containerid");
        insertValueQuery( containerid );
    });

    $("#saveandcontinue").on("click",function(e){
        e.preventDefault();
        $("#redirect").val("just_save");
        $("#submit_form").click();
    });

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
        $("#preview_template .modal-body").load(page + " .main");
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
                if ( $(this).prop('selected') && $(this).val().length > 0 ) {
                    $(myQuery).insertAtCaret("<<" + $(this).val() + ">>");
                }
            });
        }
    }

});
