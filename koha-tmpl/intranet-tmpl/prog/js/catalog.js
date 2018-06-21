/* IF ( CAN_user_editcatalogue_edit_catalogue ) */
    /* this function open a popup to search on z3950 server.  */
    function PopupZ3950() {
        var strQuery = GetZ3950Terms();
        if(strQuery){
            window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=" + biblionumber + strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
        }
    }
    function PopupZ3950Confirmed() {
        if (confirm( MSG_REPLACE_RECORD )){
            PopupZ3950();
        }
    }
/* END IF( CAN_user_editcatalogue_edit_catalogue ) */

function addToCart() { addRecord( biblionumber ); }
function addToShelf() { window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=' + biblionumber,'Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes');
}
function printBiblio() {window.print(); }

/* IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

function confirm_deletion() {
    var order_manage_permission = $(this).data("order-manage");
    var is_confirmed;
    if (count > 0){
        is_confirmed = alert( MSG_DELETE_ALL_ITEMS.format(count) );
    } else if (countorders > 0){
        if( order_manage_permission ){
            is_confirmed = confirm( CONFIRM_RECORD_USED_IN_ORDERS.format(countorders) );
        } else {
            is_confirmed = alert( MSG_RECORD_USED_IN_ORDERS.format(countorders) );
        }
    } else if (countdeletedorders > 0){
        if( order_manage_permission ){
            is_confirmed = confirm( CONFIRM_IN_DELETED_ORDERS.format(countdeletedorders) );
        } else {
            is_confirmed = alert( MSG_IN_DELETED_ORDERS.format(countdeletedorders) );
        }
    } else if ( holdcount > 0 ) {
        is_confirmed = confirm( CONFIRM_DELETION_HOLDS.format(holdcount) );
    } else {
        is_confirmed = confirm( CONFIRM_RECORD_DELETION );
    }
    if (is_confirmed) {
        window.location="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=" + biblionumber;
    } else {
        return false;
    }
}

/* END IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

/* IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

function confirm_items_deletion() {
    if ( holdcount > 0 ) {
        alert( MSG_DELETE_ALL_HOLDS.format(holdcount) );
    } else if ( count > 0 ) {
        if( confirm( CONFIRM_DELETE_ITEMS.format(count) ) ) {
            window.location="/cgi-bin/koha/cataloguing/additem.pl?op=delallitems&amp;biblionumber=" + biblionumber;
        } else {
            return false;
        }
    } else {
        alertNoItems();
        return false;
    }
}

function alertNoItems(){
    alert( MSG_NO_ITEMS );
}

/* END IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

$(document).ready(function() {
    $("#z3950copy").click(function(){
        PopupZ3950();
        return false;
    });
    $("#deletebiblio").click(function(){
        confirm_deletion();
        return false;
    });
    $("#deleteallitems").click(function(){
        confirm_items_deletion();
        return false;
    });
    $("#printbiblio").click(function(){
        printBiblio();
        return false;
    });
    $("#addtocart").click(function(){
        addToCart();
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#addtoshelf").click(function(){
        addToShelf();
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#export").remove(); // Hide embedded export form if JS menus available
    $("#deletebiblio").tooltip();
    $("#batchedit-disabled,#batchdelete-disabled,#deleteallitems-disabled")
        .on("click",function(e){
            e.preventDefault();
            alertNoItems();
        })
        .tooltip();
 });
