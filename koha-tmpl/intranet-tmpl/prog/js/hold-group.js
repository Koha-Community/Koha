$(document).ready(function () {
    $("body").on("click", "a.hold-group", function () {
        var href = $(this).attr("href");
        $("#hold-group-modal .modal-body").load(href + " #main");
        $("#hold-group-modal").modal("show");
        if (holds_table_patron_page()) {
            append_select_group_holds_button();
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

    function append_select_group_holds_button() {
        var button = document.createElement("button");
        button.type = "button";
        button.className = "btn btn-primary";
        button.id = "select-group-holds";
        button.dataset.bsDismiss = "modal";
        button.innerHTML = _("Select group holds");
        if (!$("#select-group-holds").length) {
            $("#hold-group-modal .modal-footer").prepend(button);
        }
    }
});
