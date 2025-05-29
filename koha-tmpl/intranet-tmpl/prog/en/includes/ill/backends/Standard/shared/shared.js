document.addEventListener("DOMContentLoaded", function () {
    $("#add-new-fields").click(function (e) {
        e.preventDefault();
        var row =
            '<li class="form-horizontal">' +
            '<input type="text" class="custom-name ' +
            '" name="custom_key" placeholder="' +
            __("key") +
            '">' +
            " " +
            '<input type="text" id="custom-value" name="custom_value" class="' +
            '" placeholder="' +
            __("value") +
            '"> ' +
            '<button type="button" class="btn btn-danger btn-sm ' +
            'delete-new-field">' +
            '<span class="fa fa-trash-can"></span> ' +
            __("Delete") +
            "</button></li>";
        $("#standard-fields").append(row);
    });
    $("#standard-fields").on("click", ".delete-new-field", function (event) {
        event.preventDefault();
        $(event.target).parent().remove();
    });
    $("#type").change(function () {
        $("#create_form, #standard_edit_form")
            .first()
            .submit(function () {
                $(this).prepend(
                    '<input type="hidden" name="change_type" value="1" />'
                );
            })
            .submit();
    });
    $("#standard-fields").on("keyup", ".custom-name", function () {
        var val = $(this).val();
        if (core.indexOf(val.toLowerCase()) > -1) {
            $("#custom-warning")
                .text(__("The name '%s' is not permitted").format(val))
                .show();
            $("#ill-submit").attr("disabled", true);
            $("#add-new-fields").attr("disabled", true);
        } else {
            $("#custom-warning").hide();
            $("#ill-submit").attr("disabled", false);
            $("#add-new-fields").attr("disabled", false);
        }
    });
});
