function tickAll(section) {
    $("input[type='checkbox'][name='" + section + "']").prop("checked", true);
    $("#" + section.slice(0, -1) + "ALL").prop("checked", true);
    $("input[type='checkbox'][name='" + section + "']").prop("disabled", true);
    $("#" + section.slice(0, -1) + "ALL").prop("disabled", false);
}

function untickAll(section) {
    $("input[type='checkbox'][name='" + section + "']").prop("checked", false);
    $("input[type='checkbox'][name='" + section + "']").prop("disabled", false);
}

function limitCheckboxes() {
    var checkboxes = $(".compare");
    var limit = 2;
    var compare_link =
        '<a href="#" class="btn btn-link compare_link"><i class="fa fa-columns"></i> ' +
        __("View comparison") +
        "</a>";
    checkboxes.each(function () {
        $(this).on("change", function () {
            var checked = [];
            checkboxes.each(function () {
                if ($(this).prop("checked")) {
                    checked.push($(this).data("actionid"));
                }
            });
            if (checked.length > 0) {
                $("#select_none").removeClass("disabled");
            } else {
                $("#select_none").addClass("disabled");
                $("#logst").DataTable().search("").draw();
            }
            if (checked.length == 1) {
                $("#logst").DataTable().search($(this).data("filter")).draw();
                humanMsg.displayAlert(
                    __("Showing results for %s").format($(this).data("filter"))
                );
            }
            if (checked.length == 2) {
                $("#compare_info" + checked[0]).prepend(compare_link);
                $("#compare_info" + checked[1]).prepend(compare_link);
                $("button.compare_link").removeClass("disabled");
            } else if (checked.length > limit) {
                humanMsg.displayAlert(
                    __("You can select maximum of two checkboxes")
                );
                $(this).prop("checked", false);
            } else if (checked.length < limit) {
                $("a.compare_link").remove();
                $("button.compare_link").addClass("disabled");
            }
        });
    });
}

$(document).ready(function () {
    limitCheckboxes();

    if ($(".compare_info").length == 0) {
        /* Remove toolbar if there are no system preference
           entries to compare */
        $("#toolbar").remove();
    }

    if ($('input[type="checkbox"][name="modules"]:checked').length == 0) {
        tickAll("modules");
    }
    $("#moduleALL").change(function () {
        if (this.checked == true) {
            tickAll("modules");
        } else {
            untickAll("modules");
        }
    });
    $("input[type='checkbox'][name='modules']").change(function () {
        if (
            $("input[name='modules']:checked").length ==
            $("input[name='modules']").length - 1
        ) {
            tickAll("modules");
        }
    });

    if ($('input[name="actions"]:checked').length == 0) {
        tickAll("actions");
    }
    $("#actionALL").change(function () {
        if (this.checked == true) {
            tickAll("actions");
        } else {
            untickAll("actions");
        }
    });
    $("input[name='actions']").change(function () {
        if (
            $("input[name='actions']:checked").length ==
            $("input[name='actions']").length - 1
        ) {
            tickAll("actions");
        }
    });

    if ($('input[name="interfaces"]:checked').length == 0) {
        tickAll("interfaces");
    }
    $("#interfaceALL").change(function () {
        if (this.checked == true) {
            tickAll("interfaces");
        } else {
            untickAll("interfaces");
        }
    });
    $("input[name='interfaces']").change(function () {
        if (
            $("input[name='interfaces']:checked").length ==
            $("input[name='interfaces']").length - 1
        ) {
            tickAll("interfaces");
        }
    });

    var logst = $("#logst").kohaTable(
        {
            autoWidth: false,
            order: [[0, "desc"]],
            pagingType: "full",
        },
        table_settings
    );

    $("body").on("click", ".compare_link", function (e) {
        e.preventDefault();
        if ($(this).hasClass("disabled")) {
            humanMsg.displayAlert(__("You must select two entries to compare"));
        } else {
            var firstid = $(".compare:checked").eq(0).data("actionid");
            var secondid = $(".compare:checked").eq(1).data("actionid");
            var firstvalue = $("#loginfo" + firstid).text();
            var secondvalue = $("#loginfo" + secondid).text();
            var diffs = diffString(secondvalue, firstvalue);
            $("#col1 pre,#col2 pre").html(diffs);
            $("#compareInfo").modal("show");
        }
    });
    $("#compareInfo").on("hidden.bs.modal", function () {
        $("#col1 pre,#col2 pre").html("");
    });

    $("#select_none").on("click", function (e) {
        e.preventDefault();
        $(".compare:checked").prop("checked", false).change();
    });
    patron_autocomplete($("#user"), {
        "on-select-callback": function (event, ui) {
            $("#user").val(ui.item.patron_id);
            return false;
        },
    });

    $(".log-disabled")
        .each(function () {
            if (CAN_user_parameters_manage_sysprefs) {
                let pref = $(this).data("log");
                url =
                    "/cgi-bin/koha/admin/preferences.pl?op=search&searchfield=";
                $(this).wrap(
                    "<a href='" + url + pref + "' target='_blank'></a>"
                );
            }
        })
        .tooltip();
});
