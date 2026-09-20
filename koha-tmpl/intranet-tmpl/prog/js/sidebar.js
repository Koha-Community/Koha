(function () {
    var STORAGE_KEY = "sidebar-collapsed";

    function setSidebarState(collapsed) {
        var sidebar = $("#sidebar-container");
        var toggle_button = $("#toggle-sidebar");
        var icon = $("#toggle-sidebar i");
        var mainContainer = $("main").parent();

        if (collapsed) {
            sidebar.addClass("collapsed");
            icon.removeClass("fa-chevron-left").addClass("fa-chevron-right");
            mainContainer
                .removeClass("col-md-10")
                .addClass("col-md-12")
                .css("width", "90%");
            toggle_button.attr("aria-expanded", "false");
        } else {
            sidebar.removeClass("collapsed");
            icon.removeClass("fa-chevron-right").addClass("fa-chevron-left");
            mainContainer
                .removeClass("col-md-12")
                .addClass("col-md-10")
                .removeAttr("style");
            toggle_button.attr("aria-expanded", "true");
        }

        try {
            localStorage.setItem(STORAGE_KEY, collapsed ? "true" : "false");
        } catch (e) {
            // localStorage unavailable (private browsing, etc.); state just won't persist
        }
    }

    window.$toggle_sidebar = function () {
        setSidebarState(!$("#sidebar-container").hasClass("collapsed"));
    };

    window.$restore_sidebar_state = function () {
        var collapsed = false;
        try {
            collapsed = localStorage.getItem(STORAGE_KEY) === "true";
        } catch (e) {
            // localStorage unavailable; default to expanded
        }
        if (collapsed) {
            setSidebarState(true);
        }
    };
})();
