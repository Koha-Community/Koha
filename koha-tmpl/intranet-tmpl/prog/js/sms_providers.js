$(document).ready(function () {
    $("#submit_update").hide();
    $("#name").focus();
    $("#sms_add_form").hide();
    $("#new_provider").on("click", function () {
        add_provider();
    });
    $(".edit").on("click", function (e) {
        e.preventDefault();
        var providerid = $(this).data("providerid");
        edit_provider(providerid);
    });
    $(".delete").on("click", function (e) {
        e.preventDefault();
        var providerid = $(this).data("providerid");
        var patrons_using = $(this).data("patrons_using");
        if (patrons_using !== "") {
            delete_provider(providerid, patrons_using);
        } else {
            delete_provider(providerid);
        }
    });
    $(".cancel_edit").on("click", function (e) {
        e.preventDefault();
        cancel_edit();
    });
});

function clear_form() {
    $("#id,#name,#domain").val("");
}

function add_provider() {
    clear_form();
    $(".dialog").hide();
    $("legend").text(__("Add an SMS cellular provider"));
    $("#toolbar,#submit_update,#providers").hide();
    $("#sms_add_form,#submit_save").show();
    $("#name").focus();
}

function edit_provider(id) {
    clear_form();
    $("legend").text(__("Edit provider %s").format($("#name_" + id).text()));
    $("#sms_add_form,#submit_update").show();

    $("#id").val(id);
    $("#name").val($("#name_" + id).text());
    $("#domain").val($("#domain_" + id).text());

    $("#toolbar,#submit_save,#providers").hide();

    $("#name").focus();
}

function cancel_edit() {
    clear_form();
    $(".dialog").show();
    $("#sms_add_form,#submit_update").hide();
    $("#toolbar,#submit_save,#providers").show();
}

function delete_provider(id, users) {
    var c;
    if (users) {
        c = confirm(
            __(
                "Are you sure you want to delete %s? %s patron(s) are using it!"
            ).format($("#name_" + id).html(), users)
        );
    } else {
        c = confirm(
            __("Are you sure you want to delete %s?").format(
                $("#name_" + id).html()
            )
        );
    }

    if (c) {
        $("#op").val("cud-delete");
        $("#id").val(id);
        $("#sms_form").submit();
    }
}
