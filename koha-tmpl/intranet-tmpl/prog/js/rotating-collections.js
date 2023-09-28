/* global _ dataTablesDefaults */

$(document).ready(function(){
    $("#barcode").focus();

    $(".confirmdelete").click(function(){
        $(this).parents('tr').addClass("warn");
        if(confirm(__("Are you sure you want to delete this rotating collection?"))){
            return true;
        } else {
            $(this).parents('tr').removeClass("warn");
            return false;
        }
    });

    if( $('#rotating-collections-table').length > 0 ){
        $('#rotating-collections-table').dataTable($.extend(true, {}, dataTablesDefaults, {
            "autoWidth": false,
            "columnDefs":  [
                { "targets":  [ -1 ], "orderable":  false, "searchable":  false },
            ],
            "pagingType":  "full"
        } ));
    }


});
