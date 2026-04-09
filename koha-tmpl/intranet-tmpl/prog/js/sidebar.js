(function () {
    window.$toggle_sidebar = function () {
        var sidebar = $("#sidebar-container");
        var icon = $("#toggle-sidebar i");
        var toggleWrapper = $(".sidebar-toggle-wrapper");
        var mainContainer = $("main").parent();

        if (sidebar.hasClass("collapsed")) {
            sidebar.removeClass("collapsed");
            icon.removeClass("fa-chevron-right").addClass("fa-chevron-left");
            toggleWrapper.css("left", "14%");
            mainContainer.removeClass("col-md-12").addClass("col-md-10");
        } else {
            sidebar.addClass("collapsed");
            icon.removeClass("fa-chevron-left").addClass("fa-chevron-right");
            toggleWrapper.css("left", "-15px");
            mainContainer.removeClass("col-md-10").addClass("col-md-12");
        }
    };
})();
