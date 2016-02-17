/* Import/Export from/to spreadsheet */

    var importing = false;

    $(document).ready(function() {
        $("#table_biblio_frameworks").dataTable($.extend(true, {}, dataTablesDefaults, {
            "aoColumnDefs": [
                { "aTargets": [ -1 ], "bSortable": false, "bSearchable": false },
                { "aTargets": [ 0, 1 ], "sType": "natural" },
            ],
            "bSort": true,
            "sPaginationType": "four_button"
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
            alert( MSG_IMPORT_ERROR + " %s".format(decodeURIComponent(matches[1])));
        }

        $('input.input_import').change( function() {
            var filename = $(this).val();
            if ( ! /(?:\.csv|\.ods|\.xml)$/.test(filename)) {
                $(this).css("background-color","yellow");
                alert( MSG_SELECT_FILE_FORMAT );
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
            if (/(?:\.csv|\.ods|\.xml)$/.test(obj.val())) {
                if (confirm( MSG_OVERWRITE_WARNING )) {
                    var frameworkcode = $('#' + id + ' input:hidden[name=frameworkcode]').val();
                    $('#importing_' + frameworkcode).find("span").html(MSG_IMPORTING_TO_FRAMEWORK.format("<strong>" + frameworkcode + "</strong>", "<i>" + obj.val().replace(new RegExp("^.+[/\\\\]"),"") + "</i>"));
                    if (navigator.userAgent.toLowerCase().indexOf('msie') != -1) {
                        var timestamp = new Date().getTime();
                        $('#importing_' + frameworkcode).find("img").attr('src', template_path + '/img/loading-small.gif' + '?' +timestamp);
                    }
                    $('#importing_' + frameworkcode).css('display', 'block');
                    if (navigator.userAgent.toLowerCase().indexOf('firefox') == -1) $("body").css("cursor", "progress");
                    importing = true;
                    $(".modal-footer,.closebtn").hide();
                    return true;
                } else
                    return false;
            }
            obj.css("background-color","yellow");
            alert( MSG_SELECT_FILE_FORMAT );
            obj.val("");
            obj.css("background-color","white");
            return false;
        });
    });