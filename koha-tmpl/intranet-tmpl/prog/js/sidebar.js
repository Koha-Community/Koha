(function () {
    var STORAGE_KEY = "sidebar-collapsed";

    function setSidebarState(collapsed) {
        var sidebar = $("#sidebar-container");
        if (!sidebar.length) {
            return;
        }

        var toggle_button = $("#toggle-sidebar");

        document.documentElement.classList.toggle(
            "sidebar-collapsed",
            collapsed
        );
        sidebar.toggleClass("collapsed", collapsed);
        toggle_button
            .find("i")
            .toggleClass("fa-chevron-right", collapsed)
            .toggleClass("fa-chevron-left", !collapsed);
        toggle_button.attr("aria-expanded", collapsed ? "false" : "true");

        try {
            localStorage.setItem(STORAGE_KEY, collapsed ? "true" : "false");
        } catch (e) {
            // localStorage unavailable (private browsing, etc.); state just won't persist
        }
    }

    window.$toggle_sidebar = function () {
        // The class on <html> is the source of truth: it is set before first
        // paint, whereas a sidebar rendered later (the Vue pages) has not yet
        // been given its own .collapsed class when the page is restored
        setSidebarState(
            !document.documentElement.classList.contains("sidebar-collapsed")
        );
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
