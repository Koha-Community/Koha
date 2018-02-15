/* global dataTablesDefaults */
$(document).ready(function() {
    $(".clickable").click(function() {
        window.document.location = $(this).data('url');
    });
    var table = $("#table_borrowers").dataTable($.extend(true, {}, dataTablesDefaults, {
        "aaSorting": [ 0, "asc" ],
        "sDom": "t",
        "iDisplayLength": -1
    }));
});