/* global __ dataTablesDefaults showMore showLess delSelRecords addSelToShelf sendBasket printBasket delBasket openBiblio selRecord */

function placeHold () {
    var checkedItems = $("input:checkbox:checked");
    if ($(checkedItems).size() === 0) {
        alert( __("No item was selected") );
        return false;
    }

    var bib_params = [];
    $(checkedItems).each(function() {
        var bib = $(this).val();
        bib_params.push("biblionumber=" + bib);
    });

    if (bib_params.length > 1) {
        bib_params.push('multi_hold=1');
    }

    window.opener.location = "/cgi-bin/koha/reserve/request.pl?" + bib_params.join('&');
    window.close();
}

function resultsBatchProcess( op ){
    if( op == "edit" || op == "delete" ){
        let checkedItems = $(".select_record:checked");
        if ( checkedItems.size() === 0 ) {
            alert( __("No item was selected") );
            return false;
        } else {
            /* form markup for batch edit or delete operations */
            let params = [];
            const body = window.opener.document.getElementsByTagName("body");
            let f = document.createElement("form");
            f.setAttribute("method", "post");
            if( op == "edit" ){
                /* batch edit selected records */
                f.setAttribute("action", "/cgi-bin/koha/tools/batch_record_modification.pl");
            } else if( op == "delete" ){
                /* batch delete selected records */
                f.setAttribute("action", "/cgi-bin/koha/tools/batch_delete_records.pl");
            }
            f.innerHTML = '<input type="hidden" name="recordtype" value="biblio" /><input type="hidden" name="op" value="cud-list" />';
            /* Get token from parent window */
            csrf = window.opener.document.querySelectorAll('[name="csrf_token"]');
            f.append( csrf[0] );
            let textarea = document.createElement("textarea");
            textarea.setAttribute("name", "bib_list");
            textarea.setAttribute("style", "display:none");

            checkedItems.each(function() {
                params.push( $(this).val() );
            });

            textarea.value = params.join("/");
            f.append( textarea );
            body[0].append( f );
            f.submit();
            window.close();
        }
    } else {
        return false;
    }
}

$(document).ready(function(){
    $("#items-popover").popover();

    $("#CheckAll").click(function (e) {
        e.preventDefault();
        $(".select_record").each(function () {
            $(this).prop("checked", true).change();
        });
    });

    $("#CheckNone").click(function (e) {
        e.preventDefault();
        $(".select_record").each(function () {
            $(this).prop("checked", false).change();
        });
    });

    $(".holdsep").text("| ");
    $(".hold").text( __("Place hold") );
    $("#downloadcartc").empty();

    $("#itemst").dataTable($.extend(true, {}, dataTablesDefaults, {
        "dom":  't',
        "columnDefs":  [
            { "orderable":  false, "searchable":  false, "targets":  [ 'NoSort' ] },
            { "type":  "anti-the", "targets":  [ "anti-the" ] },
            { "type":  "callnumbers", "targets":  [ "callnumbers"] }
        ],
        "order":  [[ 1, "asc" ]],
        "paging":  false
    }));

    $(".showdetails").on("click",function(e){
        e.preventDefault();
        if( $(this).hasClass("showmore") ){
            showMore();
        } else {
            showLess();
        }
    });

    $("#batch_modify").on("click",function(e){
        e.preventDefault();
        batchModify();
    });
    $("#batch_delete").on("click",function(e){
        e.preventDefault();
        batchDelete();
    });

    $("#remove_from_cart").on("click",function(e){
        e.preventDefault();
        delSelRecords();
    });

    $("#add_to_list").on("click",function(e){
        e.preventDefault();
        addSelToShelf();
    });

    $("#place_hold").on("click",function(e){
        e.preventDefault();
        placeHold();
    });

    $("#send_cart").on("click",function(e){
        e.preventDefault();
        sendBasket();
    });

    $("#print_cart").on("click",function(e){
        e.preventDefault();
        printBasket();
    });

    $("#empty_cart").on("click",function(e){
        e.preventDefault();
        delBasket('popup');
    });
    $(".title").on("click",function(e){
        e.preventDefault();
        openBiblio( this.href );
    });
    $(".select_record").on("change",function(){
        selRecord( this.value, this.checked );
    });

    $(".results_batch_op").on("click", function(e){
        e.preventDefault();
        var op = $(this).data("op");
        resultsBatchProcess( op );
    });
});
