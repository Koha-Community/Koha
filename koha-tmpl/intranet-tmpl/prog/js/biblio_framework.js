/* global __ */
/* Import/Export from/to spreadsheet */

var importing = false;

$(document).ready(function () {
    $("#table_biblio_frameworks").kohaTable({
        columnDefs: [
            { targets: [-1], orderable: false, searchable: false },
            { targets: [0, 1], type: "natural" },
        ],
        ordering: true,
        pagingType: "full",
    });

    $("body").css("cursor", "auto");
    $(".import_export_options").hide();
    $("a.import_export_fw").click(function () {
        if (!importing) {
            $(".import_export_options").hide();
            $(this).next().show("slide");
        }
        return false;
    });
    $(".import_export_close").click(function () {
        if (!importing) {
            $(".import_export_options").fadeOut("fast");
            $("body").css("cursor", "auto");
            return false;
        }
    });
    $(".input_import").val("");

    var matches = new RegExp("\\?error_import_export=(.+)$").exec(
        window.location.search
    );
    if (matches && matches.length > 1) {
        alert(
            __("Error importing the framework") +
                " %s".format(decodeURIComponent(matches[1]))
        );
    }

    $("input.input_import").change(function () {
        var filename = $(this).val();
        if (!/(?:\.csv|\.ods|\.xml)$/.test(filename)) {
            $(this).css("background-color", "yellow");
            alert(
                __("Please select a CSV (.csv) or ODS (.ods) spreadsheet file.")
            );
            $(this).val("");
            $(this).css("background-color", "white");
        }
    });
    $("form.form_export").submit(function () {
        $(".modal").modal("hide");
        return true;
    });
    $("form.form_import").submit(function () {
        var id = $(this).attr("id");
        var obj = $("#" + id + " input:file");
        if (/(?:\.csv|\.ods|\.xml)$/.test(obj.val())) {
            var frameworkcode = $(
                "#" + id + " input:hidden[name=frameworkcode]"
            ).val();
            var MSG_OVERWRITE_WARNING = __(
                "Are you sure you want to replace the fields and subfields for the %s framework structure? The existing structure will be overwritten! For safety reasons, it is recommended to use the export option to make a backup first."
            ).format(frameworkcode);
            if (confirm(MSG_OVERWRITE_WARNING)) {
                $("#importing_" + frameworkcode)
                    .find("span")
                    .html(
                        __(
                            "Importing to framework: %s. Importing from file: %s."
                        ).format(
                            "<strong>" + frameworkcode + "</strong>",
                            "<i>" +
                                obj
                                    .val()
                                    .replace(new RegExp("^.+[/\\\\]"), "") +
                                "</i>"
                        )
                    );
                if (navigator.userAgent.toLowerCase().indexOf("msie") != -1) {
                    var timestamp = new Date().getTime();
                    $("#importing_" + frameworkcode)
                        .find("img")
                        .attr(
                            "src",
                            template_path +
                                "/img/spinner-small.gif" +
                                "?" +
                                timestamp
                        );
                }
                $("#importing_" + frameworkcode).css("display", "block");
                if (navigator.userAgent.toLowerCase().indexOf("firefox") == -1)
                    $("body").css("cursor", "progress");
                importing = true;
                $(".modal-footer,.btn-close").hide();
                return true;
            } else return false;
        }
        obj.css("background-color", "yellow");
        alert(__("Please select a CSV (.csv) or ODS (.ods) spreadsheet file."));
        obj.val("");
        obj.css("background-color", "white");
        return false;
    });
    $("#frameworkcode").on("blur", function () {
        toUC(this);
    });
});
