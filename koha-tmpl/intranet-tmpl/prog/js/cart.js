
function placeHold () {
    var checkedItems = $("input:checkbox:checked");
    if ($(checkedItems).size() === 0) {
        alert(MSG_NO_RECORD_SELECTED);
        return false;
    }

    var newloc;

    if ($(checkedItems).size() > 1) {
        var bibs = "";
        $(checkedItems).each(function() {
            var bib = $(this).val();
            bibs += bib + "/";
        });

        newloc = "/cgi-bin/koha/reserve/request.pl?biblionumbers=" + bibs + "&multi_hold=1";
    } else {
        var bib = checkedItems[0].value;
        newloc = "/cgi-bin/koha/reserve/request.pl?biblionumber=" + bib;
    }

    window.opener.location = newloc;
    window.close();
}

function batchDelete(){
    var checkedItems = $("input:checkbox:checked");
    if ($(checkedItems).size() === 0) {
        alert(MSG_NO_RECORD_SELECTED);
        return false;
    }
    var newloc;

    var bibs = "";
    checkedItems.each(function() {
        var bib = $(this).val();
        bibs += bib + "/";
    });

    newloc = "/cgi-bin/koha/tools/batch_delete_records.pl?op=list&type=biblio&bib_list=" + bibs;

    window.opener.location = newloc;
    window.close();
}

function batchModify(){
    var checkedItems = $("input:checkbox:checked");
    if ($(checkedItems).size() === 0) {
        alert(MSG_NO_RECORD_SELECTED);
        return false;
    }
    var newloc;

    var bibs = "";
    $(checkedItems).each(function() {
        var bib = $(this).val();
        bibs += bib + "/";
    });
    newloc = "/cgi-bin/koha/tools/batch_record_modification.pl?op=list&amp;bib_list=" + bibs + "&type=biblio";

    window.opener.location = newloc;
    window.close();
}

$(document).ready(function(){
    $("#items-popover").popover();
    $("#CheckAll").click(function(){
    var checked = [];
    $("#bookbag_form").checkCheckboxes("*", true).each(
        function() {
            selRecord(this.value,true);
            $(this).change();
        }
    );
        return false;
    });
    $("#CheckNone").click(function(){
    var checked = [];
    $("#bookbag_form").unCheckCheckboxes("*",true).each(
        function() {
            selRecord(this.value,false);
            $(this).change();
        }
    );
        return false;
    });
    $(".holdsep").text("| ");
    $(".hold").text(_("Place hold"));
    $("#downloadcartc").empty();

    $("#itemst").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
            { "sType": "anti-the", "aTargets" : [ "anti-the" ] },
            { "sType": "callnumbers", "aTargets" : [ "callnumbers"] }
        ],
        "aaSorting": [[ 1, "asc" ]],
        "bPaginate": false
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
    $(".open_title").on("click",function(e){
        e.preventDefault();
        openBiblio( this.href );
    });
    $(".select_record").on("change",function(){
        selRecord( this.value, this.checked );
    });
});
