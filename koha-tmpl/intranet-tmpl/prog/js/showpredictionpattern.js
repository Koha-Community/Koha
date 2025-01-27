function Check_boxes(dow) {
    if ($(":checkbox[data-dow='" + dow + "']:first").is(":checked")) {
        $("#predictionst :checkbox[data-dow='" + dow + "']").each(function () {
            $(this).prop("checked", true);
        });
    } else {
        $("#predictionst :checkbox[data-dow='" + dow + "']").each(function () {
            $(this).prop("checked", false);
        });
    }
}
$(document).ready(function () {
    $("#displayexample").on("change", ".skipday", function () {
        Check_boxes($(this).data("dow"));
    });
});
