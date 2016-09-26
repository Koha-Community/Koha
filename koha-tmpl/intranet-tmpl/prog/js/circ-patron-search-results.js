/* global dataTablesDefaults */
$(document).ready(function() {
    $(".clickable").click(function() {
        window.document.location = $(this).data('url');
    });
    var table = KohaTable("table_borrowers",
        {
            "aaSorting": [ 0, "asc" ],
            "sDom": "t",
            "iDisplayLength": -1
        },
        columns_settings_borrowers_table, null);
});
