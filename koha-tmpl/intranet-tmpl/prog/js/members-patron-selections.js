function persistPatronSelections(form) {
    var selected_patrons;
    var persistence_checkbox = $("#maintain_selections_" + form)[0];
    var persist = persistence_checkbox.checked;
    if (form === "patron-merge-form" && persist) {
        // We should only keep the id for the patron that is being kept in the merge
        var keeper_checkboxes = $(".keeper");
        var patron_to_keep = keeper_checkboxes.filter(":checked");
        var patron_id = patron_to_keep[0].value;
        selected_patrons = [patron_id];
    } else {
        selected_patrons = persist
            ? JSON.parse(localStorage.getItem("patron_search_selections"))
            : [];
    }
    localStorage.setItem(
        "patron_search_selections",
        JSON.stringify(selected_patrons)
    );
}

function showPatronSelections(number) {
    if (number === 0) {
        $("#table_search_selections").hide();
    } else {
        $("#table_search_selections")
            .show()
            .find("span")
            .text(__("Patrons selected: %s").format(number));
    }
}

function prepSelections() {
    var selected_patrons = JSON.parse(
        localStorage.getItem("patron_search_selections")
    );
    if (selected_patrons && selected_patrons.length > 0) {
        showPatronSelections(selected_patrons.length);

        $("#merge-patrons").prop("disabled", true);
        $("input.selection").each(function () {
            var cardnumber = $(this).val();
            if (selected_patrons.indexOf(cardnumber) >= 0) {
                $(this).prop("checked", true);
            }
        });

        if (selected_patrons.length > 1) {
            $("#batch-mod-patrons, #merge-patrons, #patronlist-menu")
                .removeClass("disabled")
                .prop("disabled", false);
        }
    } else {
        showPatronSelections(0);
        $("#merge-patrons").prop("disabled", true);
        $("input.selection").each(function () {
            $(this).prop("checked", false);
        });
        $("#batch-mod-patrons, #merge-patrons, #patronlist-menu")
            .addClass("disabled")
            .prop("disabled", true);
    }
}

$(document).ready(function () {
    var form_identifier = $("#form-identifier").data();
    if (
        form_identifier &&
        form_identifier.hasOwnProperty("identifier") &&
        form_identifier.identifier
    ) {
        var form_id = form_identifier.identifier;
        if (form_id !== "new-patron-list_form") {
            $("#" + form_id).on("submit", function (e) {
                persistPatronSelections(form_id);
            });
        }
    }
});
