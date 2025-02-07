$(document).ready(function () {
    const client = APIClient.recall;

    $(".cancel_recall").click(function (e) {
        if (confirmDelete(__("Are you sure you want to remove this recall?"))) {
            let td_node = $(this).parents("td");
            let recall_id = $(this).data("id");
            client.recalls.cancel(recall_id).then(
                success => {
                    if (success.success == 0) {
                        message = __(
                            "The recall may have already been cancelled. Please refresh the page."
                        );
                    } else {
                        message = __("Cancelled");
                    }
                    td_node.html(message);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }
    });

    $(".expire_recall").click(function (e) {
        if (confirmDelete(__("Are you sure you want to expire this recall?"))) {
            let td_node = $(this).parents("td");
            let recall_id = $(this).data("id");
            client.recalls.expire(recall_id).then(
                success => {
                    if (success.success == 0) {
                        message = __(
                            "The recall may have already been expired. Please refresh the page."
                        );
                    } else {
                        message = __("Expired");
                    }
                    td_node.html(message);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }
    });

    $(".revert_recall").click(function (e) {
        if (
            confirmDelete(
                __(
                    "Are you sure you want to revert the waiting status of this recall?"
                )
            )
        ) {
            let td_node = $(this).parents("td");
            let recall_id = $(this).data("id");
            client.recalls.revert(recall_id).then(
                success => {
                    if (success.success == 0) {
                        message = __(
                            "The recall may have already been reverted. Please refresh the page."
                        );
                    } else {
                        message = __("Waiting status reverted");
                    }
                    td_node.html(message);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }
    });

    $(".overdue_recall").click(function (e) {
        if (
            confirmDelete(
                __("Are you sure you want to mark this recall as overdue?")
            )
        ) {
            let td_node = $(this).parents("td");
            let recall_id = $(this).data("id");
            client.recalls.overdue(recall_id).then(
                success => {
                    if (success.success == 0) {
                        message = __(
                            "The recall may have already been marked as overdue. Please refresh the page."
                        );
                    } else {
                        message = __("Marked overdue");
                    }
                    td_node.html(message);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }
    });

    $(".transit_recall").click(function (e) {
        if (
            confirmDelete(
                __(
                    "Are you sure you want to remove this recall and return the item to it's home library?"
                )
            )
        ) {
            let td_node = $(this).parents("td");
            let recall_id = $(this).data("id");
            client.recalls.transit(recall_id).then(
                success => {
                    if (success.success == 0) {
                        message = __(
                            "The recall may have already been removed. Please refresh the page."
                        );
                    } else {
                        message = __("Cancelled");
                    }
                    td_node.html(message);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }
    });

    $("#recalls-table").kohaTable({
        columnDefs: [{ type: "title-string", targets: ["title-string"] }],
        order: [[1, "asc"]],
        pagingType: "full_numbers",
    });

    $("#cancel_selected").click(function (e) {
        if ($("input[name='recall_ids']:checked").length > 0) {
            return confirmDelete(
                __("Are you sure you want to remove the selected recall(s)?")
            );
        } else {
            alert(__("Please make a selection."));
        }
    });

    $("#select_all").click(function () {
        if ($("#select_all").prop("checked")) {
            $("input[name='recall_ids']").prop("checked", true);
        } else {
            $("input[name='recall_ids']").prop("checked", false);
        }
    });

    $("#hide_old").click(function () {
        if ($("#hide_old").prop("checked")) {
            $(".old").show();
        } else {
            $(".old").hide();
        }
    });
});
