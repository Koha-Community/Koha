function submit_form(form) {
    let form_data = $(form).data();

    let confirm_msg = form_data.confirmationMsg;
    if (confirm_msg) {
        let confirmation = confirm(confirm_msg);
        if (!confirmation) {
            return false;
        }
        delete form_data.confirmationMsg;
    }

    let the_form = $("<form/>");
    if (form_data.method === "post") {
        form_data.csrf_token = $('meta[name="csrf-token"]').attr("content");
    }
    the_form.attr("method", form_data.method);
    the_form.attr("action", form_data.action);
    delete form_data.method;
    delete form_data.action;
    $.each(form_data, function (key, value) {
        the_form.append(
            $("<input/>", {
                type: "hidden",
                name: key,
                value: value,
            })
        );
    });
    if (form_data.new_tab) {
        the_form.attr("target", "_blank");
    }
    $("body").append(the_form);
    the_form.submit();
}

$("body").on("click", ".submit-form-link", function (e) {
    e.preventDefault();
    submit_form(this);
});
