$(document).ready(function () {
    $(".group_hold_trigger").on("click", function (e) {
        e.preventDefault();

        var $icon = $(this).find("i");
        var $list = $(this).siblings(".group_hold_list");

        $list.toggle();

        // Swap the caret icon direction
        if ($list.is(":visible")) {
            $icon.removeClass("fa-caret-right").addClass("fa-caret-down");
            $(this).attr("aria-expanded", "true");
        } else {
            $icon.removeClass("fa-caret-down").addClass("fa-caret-right");
            $(this).attr("aria-expanded", "false");
        }
    });
});
