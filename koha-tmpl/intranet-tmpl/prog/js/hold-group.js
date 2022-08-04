$(document).ready(function () {
    $("body").on("click", "a.hold-group", function () {
        var href = $(this).attr("href");
        $("#hold-group-modal .modal-body").load(href + " #main");
        $("#hold-group-modal").modal("show");
        return false;
    });
});
