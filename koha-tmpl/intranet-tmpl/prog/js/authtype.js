/* Import/export from/to a spreadsheet */

var importing = false;

$(document).ready(function() {
    $("#authtypes").dataTable($.extend(true, {}, dataTablesDefaults, {
        "aoColumnDefs": [
            { "aTargets": [ -1 ], "bSortable": false, "bSearchable": false },
            { "aTargets": [ 0, 1 ], "sType": "natural" },
        ],
        "bSort": true,
        "sPaginationType": "full"
    }));

    $("body").css("cursor", "auto");
    $('.import_export_options').hide();
    $('a.import_export_fw').click(function() {
        if (!importing) {
            $('.import_export_options').hide();
            $(this).next().show('slide');
        }
        return false;
    });

    $('.import_export_close').click(function() {
        if (!importing) {
            $('.import_export_options').fadeOut('fast');
            $("body").css("cursor", "auto");
            return false;
        }
    });

    $('.input_import').val("");

    var matches = new RegExp("\\?error_import_export=(.+)$").exec(window.location.search);
    if (matches && matches.length > 1) {
        alert(__("Error importing the authority type %s").format(decodeURIComponent(matches[1])));
    }

    $('input.input_import').change( function() {
        var filename = $(this).val();
        if ( ! /(?:\.csv|\.ods)$/.test(filename)) {
            $(this).css("background-color","yellow");
            alert(__("Please select a CSV (.csv) or ODS (.ods) spreadsheet file."));
            $(this).val("");
            $(this).css("background-color","white");
        }
    });

    $('form.form_export').submit(function() {
        $('.modal').modal("hide");
        return true;
    });

    $('form.form_import').submit(function() {
        var id = $(this).attr('id');
        var obj = $('#' + id + ' input:file');
        if (/(?:\.csv|\.ods)$/.test(obj.val())) {
            if (confirm(__("Do you really want to import the authority type fields and subfields? This will overwrite the current configuration. For safety reasons please use the export option to make a backup"))) {
                var authtypecode = $('#' + id + ' input:hidden[name=authtypecode]').val();
                $('#importing_' + authtypecode).find("span").html(__("Importing to authority type: %s. Importing from file: %s").format("<strong>" + authtypecode + "</strong>", "<i>" + obj.val().replace(new RegExp("^.+[/\\\\]"),"") + "</i>"));
                if (navigator.userAgent.toLowerCase().indexOf('msie') != -1) {
                    var timestamp = new Date().getTime();
                    $('#importing_' + authtypecode).find("img").attr('src', '[% interface | html %]/[% theme | html %]/img/loading-small.gif' + '?' +timestamp);
                }
                $('#importing_' + authtypecode).css('display', 'block');
                if (navigator.userAgent.toLowerCase().indexOf('firefox') == -1) $("body").css("cursor", "progress");
                importing = true;
                $(".modal-footer,.closebtn").hide();
                return true;
            } else {
                return false;
            }
        }
        obj.css("background-color","yellow");
        alert(__("Please select a CSV (.csv) or ODS (.ods) spreadsheet file."));
        obj.val("");
        bj.css("background-color","white");
        return false;
    });
    $("#authtypecode").on("blur",function(){
        toUC(this);
    });

});
