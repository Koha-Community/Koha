$(document).ready(function() {
    $("#branch").on("change", function() {
        var selectedBranch = $("#branch").children(
            "option:selected").val();

        $("#register_id").children().each(function() {
            // default to no-register
            if ($(this).is("#noregister")) {
                $(this).prop("selected", true)
            }
            // display branch registers
            else if ($(this).hasClass(selectedBranch)) {
                $(this).prop("disabled", false);
                $(this).show();
                // default to branch default if there is one
                if ($(this).hasClass("default")) {
                    $(this).prop("selected", true)
                }
            }
            // hide non-branch registers
            else {
                $(this).hide();
                $(this).prop("disabled", true);
            }
        });
    });
});
