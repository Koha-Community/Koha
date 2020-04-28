$(document).ready(function() {
    $("#desk_id").children().each(function() {
        var selectedBranch = $("#branch"). children("option:selected"). val();
        if ($(this).attr('id') === "nodesk") { //set no desk by default, should be first element
            $(this).prop("selected", true);
            $(this).prop("disabled", false);
            $(this).show();
        }
        else if ($(this).hasClass(selectedBranch)) {
            $('#nodesk').prop("disabled", true); // we have desk, no need for nodesk option
            $('#nodesk').hide();
            $(this).prop("disabled", false);
            $(this).show();
            $(this).prop("selected", true)
        } else {
            $(this).prop("disabled", true);
            $(this).hide();
        }
    });

    $("#branch").on("change", function() {

        $("#desk_id").children().each(function() {
            var selectedBranch = $("#branch"). children("option:selected"). val();
            if ($(this).attr('id') === "nodesk") { //set no desk by default, should be first element
                $(this).prop("selected", true);
                $(this).prop("disabled", false);
                $(this).show();
            }
            else if ($(this).hasClass(selectedBranch)) {
                $('#nodesk').prop("disabled", true); // we have desk, no need for nodesk option
                $('#nodesk').hide();
                $(this).prop("disabled", false);
                $(this).show();
                $(this).prop("selected", true)
            } else {
                $(this).prop("disabled", true);
                $(this).hide();
            }
        });
    });
}) ;
