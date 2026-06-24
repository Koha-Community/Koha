(function () {
    window.$toggle_sidebar = function () {
        var sidebar = $("#sidebar-container");
        var toggle_button = $("#toggle-sidebar");
        var icon = $("#toggle-sidebar i");
        var mainContainer = $("main").parent();

        if (sidebar.hasClass("collapsed")) {
            sidebar.removeClass("collapsed");
            icon.removeClass("fa-chevron-right").addClass("fa-chevron-left");
            mainContainer
                .removeClass("col-md-12")
                .addClass("col-md-10")
                .removeAttr("style");
            toggle_button.attr("aria-expanded", "true");
        } else {
            sidebar.addClass("collapsed");
            icon.removeClass("fa-chevron-left").addClass("fa-chevron-right");
            mainContainer
                .removeClass("col-md-10")
                .addClass("col-md-12")
                .css("width", "90%");
            toggle_button.attr("aria-expanded", "false");
        }
    };
})();
