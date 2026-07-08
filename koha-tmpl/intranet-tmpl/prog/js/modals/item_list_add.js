function showItemListAddModal() {
    $("#modal-item-list-add").modal("show");
    $("#modal-item-list-add-submit").removeAttr("disabled");
    $("#modal-item-list-add-submit-view").removeAttr("disabled");
}

$(document).ready(function () {
    $("#item-list-add-form-select").change(function (e) {
        const show_create = e.target.value === "";
        if (show_create) {
            $("#item-list-add-form-new-list").show();
        } else {
            $("#item-list-add-form-new-list").hide();
        }
    });
    $("#modal-item-list-add-form").validate({
        submitHandler: function (form, e) {
            $("#modal-item-list-add-submit").attr("disabled", "disabled");
            $("#modal-item-list-add-submit-view").attr("disabled", "disabled");

            const and_view =
                e.originalEvent.submitter.id ===
                "modal-item-list-add-submit-view";

            function add_to_list(item_list_id, itemnumbers) {
                const url = `/api/v1/item-lists/${item_list_id}/items`;

                var settings = {
                    url: url,
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        item_ids: itemnumbers,
                    }),
                };

                $.ajax(settings)
                    .done(function (response) {
                        $("#modal-item-list-add").modal("hide");
                        if (and_view) {
                            window.location.href =
                                "/cgi-bin/koha/lists/items/" + item_list_id;
                        }
                    })
                    .fail(function (err) {
                        var message =
                            err.responseJSON.error ||
                            err.responseJSON.errors
                                .map(e => e.message)
                                .join("\n");
                        alert(message);
                    });
            }

            let itemnumbers = new Array();
            $("input[name='itemnumber'][type='checkbox']:checked").each(
                function () {
                    const itemnumber = $(this).val();
                    itemnumbers.push(itemnumber);
                }
            );

            $(".batch-op.itemnumber > .data-plain").each(function () {
                const itemnumber = $(this).text();
                itemnumbers.push(itemnumber);
            });

            if (itemnumbers.length == 0) {
                $("#modal-item-list-add").modal("hide");
                return;
            }

            const item_list_id = $("#item-list-add-form-select").val();

            if (item_list_id === "") {
                // Create a new list
                var settings = {
                    url: "/api/v1/item-lists",
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        name: $("#item-list-add-form-new-list-name").val(),
                        visibility: "private",
                        owner: $("#item-list-add-form-new-list-owner").val(),
                    }),
                };

                $.ajax(settings)
                    .done(function (response) {
                        $("#item-list-add-form-select").append(
                            $("<option>", {
                                value: response.id,
                                text: response.name,
                            })
                        );
                        add_to_list(response.id, itemnumbers);
                    })
                    .fail(function (err) {
                        var message =
                            err.responseJSON.error ||
                            err.responseJSON.errors
                                .map(e => e.message)
                                .join("\n");
                        alert(message);
                    });
            } else {
                add_to_list(item_list_id, itemnumbers);
            }
        },
    });
});
