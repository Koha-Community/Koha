$(document).ready(function () {
    $("body").on("click", "a.hold-group", function () {
        var href = $(this).attr("href");
        $("#hold-group-modal .modal-body").load(href + " #main");
        $("#hold-group-modal").modal("show");
        if (holds_table_patron_page()) {
            append_select_group_holds_button();
            append_ungroup_holds_button();
        }
        return false;
    });
    $("body").on("click", "button#select-group-holds", function () {
        let group_hold_ids = $(".hold-group-entry")
            .map(function () {
                return $(this).data("hold-id");
            })
            .get();

        $(".select_hold").each(function () {
            var $this = $(this);
            if (
                group_hold_ids.includes($this.data("id")) !==
                $this.prop("checked")
            ) {
                $this.click();
            }
        });
    });

    $("body").on("click", "button#ungroup-hold-group", function () {
        let hold_group_id = $("#hold-group-modal #main").data("hold-group-id");
        $.ajax({
            method: "DELETE",
            url:
                "/api/v1/patrons/" +
                borrowernumber +
                "/hold_groups/" +
                hold_group_id,
        }).done(function () {
            $("#holds-table").DataTable().ajax.reload();
        });
    });

    function append_select_group_holds_button() {
        var button = document.createElement("button");
        button.type = "button";
        button.className = "btn btn-primary";
        button.id = "select-group-holds";
        button.dataset.bsDismiss = "modal";
        button.innerHTML = __("Select group holds");
        if (!$("#select-group-holds").length) {
            $("#hold-group-modal .modal-footer").prepend(button);
        }
    }

    function append_ungroup_holds_button() {
        var button = document.createElement("button");
        button.type = "button";
        button.className = "btn btn-danger";
        button.id = "ungroup-hold-group";
        button.dataset.bsDismiss = "modal";
        button.innerHTML = __("Ungroup holds");
        if (!$("#ungroup-hold-group").length) {
            $("#hold-group-modal .modal-footer").prepend(button);
        }
    }
});
