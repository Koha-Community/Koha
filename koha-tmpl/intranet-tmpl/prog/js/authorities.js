/* global __  Cookies */
function mergeAuth(authid, summary) {
    var alreadySelected = Cookies.get("auth_to_merge");
    if (alreadySelected !== undefined) {
        alreadySelected = JSON.parse(alreadySelected);
        Cookies.remove("auth_to_merge");
        var refstring = "";
        if (typeof alreadySelected.mergereference !== "undefined") {
            refstring = "&mergereference=" + alreadySelected.mergereference;
        }
        window.location.href =
            "/cgi-bin/koha/authorities/merge.pl?authid=" +
            authid +
            "&authid=" +
            alreadySelected.authid +
            refstring;
    } else {
        Cookies.set(
            "auth_to_merge",
            JSON.stringify({ authid: authid, summary: summary }),
            { path: "/", sameSite: "Lax" }
        );
        showMergingInProgress();
    }
}

function showMergingInProgress() {
    var alreadySelected = Cookies.get("auth_to_merge");
    if (alreadySelected) {
        alreadySelected = JSON.parse(alreadySelected);
        $("#merge_in_progress")
            .show()
            .html(
                __("Merging with authority: ") +
                    "<a href='detail.pl?authid=" +
                    alreadySelected.authid +
                    "'><span class='authorizedheading'>" +
                    alreadySelected.summary +
                    "</span> (" +
                    alreadySelected.authid +
                    ")</a> <a href='#' id='cancel_merge'>" +
                    __("Cancel merge") +
                    "</a>"
            );
        $("#cancel_merge").click(function (event) {
            event.preventDefault();
            Cookies.remove("auth_to_merge");
            $("#merge_in_progress").hide().empty();
        });
    } else {
        $("#merge_in_progress").hide().empty();
    }
}

$(document).ready(function () {
    showMergingInProgress();

    $(".form_delete").submit(function () {
        if (confirm(__("Are you sure you want to delete this authority?"))) {
            return true;
        }
        // FIXME Close the dropdown $(this).closest('ul.dropdown-menu').dropdown('toggle');
        return false;
    });

    $(".merge_auth").click(function (event) {
        event.preventDefault();
        mergeAuth(
            $(this).parents("tr").attr("data-authid"),
            $(this).parents("tr").find("div.authorizedheading").text()
        );
    });

    $("#delAuth").click(function () {
        $(".form_delete").submit();
    });

    $("#z3950_new").click(function (e) {
        e.preventDefault();
        window.open(
            "/cgi-bin/koha/cataloguing/z3950_auth_search.pl",
            "z3950search",
            "width=800,height=550,location=yes,toolbar=no,scrollbars=yes,resize=yes"
        );
    });

    if (typeof authid !== undefined) {
        $("#z3950_replace").click(function (e) {
            e.preventDefault();
            window.open(
                "/cgi-bin/koha/cataloguing/z3950_auth_search.pl?authid=" +
                    authid,
                "z3950search",
                "width=800,height=500,location=yes,toolbar=no,scrollbars=yes,resize=yes"
            );
        });
    }

    if (searchType) {
        if ("mainmainentry" == searchType.valueOf()) {
            $("#header_search a[href='#mainmain_heading_panel']").tab("show");
        } else if ("mainentry" == searchType.valueOf()) {
            $("#header_search a[href='#main_heading_panel']").tab("show");
        } else if ("match" == searchType.valueOf()) {
            $("#header_search a[href='#matchheading_search_panel']").tab(
                "show"
            );
        } else if ("all" == searchType.valueOf()) {
            $("#header_search a[href='#entire_record_panel']").tab("show");
        }
    }
});
