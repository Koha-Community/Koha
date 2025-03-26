/* global __ biblionumber count holdcount countorders countdeletedorders searchid addRecord delSingleRecord */
/* exported GetZ3950Terms PopupZ3950Confirmed */
/* IF ( CAN_user_editcatalogue_edit_catalogue ) */
/* this function open a popup to search on z3950 server.  */
function PopupZ3950() {
    var strQuery = GetZ3950Terms();
    if (strQuery) {
        window.open(
            "/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=" +
                biblionumber +
                strQuery,
            "z3950search",
            "width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes"
        );
    }
}
function PopupZ3950Confirmed() {
    if (
        confirm(
            __(
                "Please note that this external search could replace the current record."
            )
        )
    ) {
        PopupZ3950();
    }
}
/* END IF( CAN_user_editcatalogue_edit_catalogue ) */

function addToCart() {
    addRecord(biblionumber);
}

function addToShelf() {
    openWindow(
        "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=" +
            biblionumber,
        "Add_to_virtualshelf"
    );
}
function printBiblio() {
    window.print();
}

/* IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

function confirm_deletion(link) {
    var order_manage_permission = $(link).data("order-manage");
    var is_confirmed;
    if (count > 0) {
        is_confirmed = alert(
            __(
                "%s item(s) are attached to this record. You must delete all items before deleting this record."
            ).format(count)
        );
    } else if (countorders > 0) {
        if (order_manage_permission) {
            is_confirmed = confirm(
                __(
                    "Warning: This record is used in %s order(s). These orders will be cancelled. Are you sure you want to delete this record?"
                ).format(countorders)
            );
        } else {
            is_confirmed = alert(
                __(
                    "%s order(s) are using this record. You need order managing permissions to delete this record."
                ).format(countorders)
            );
        }
    } else if (countdeletedorders > 0) {
        if (order_manage_permission) {
            is_confirmed = confirm(
                __(
                    "%s deleted order(s) are using this record. Are you sure you want to delete this record?"
                ).format(countdeletedorders)
            );
        } else {
            is_confirmed = alert(
                __(
                    "%s deleted order(s) are using this record. You need order managing permissions to delete this record."
                ).format(countdeletedorders)
            );
        }
    } else if (holdcount > 0) {
        is_confirmed = confirm(
            __(
                "%s holds(s) for this record. Are you sure you want to delete this record?"
            ).format(holdcount)
        );
    } else if (subscriptionscount > 0) {
        is_confirmed = alert(
            __(
                "%s subscription(s) are attached to this record. You must delete all subscription before deleting this record."
            ).format(subscriptionscount)
        );
    } else {
        is_confirmed = confirm(
            __("Are you sure you want to delete this record?")
        );
    }
    if (is_confirmed) {
        $("#deletebiblio").unbind("click");
        return $(link).siblings("form").submit();
    } else {
        return false;
    }
}

/* END IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

/* IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

function confirm_items_deletion(link) {
    if (holdcount > 0) {
        alert(
            __(
                "%s hold(s) on this record. You must delete all holds before deleting all items."
            ).format(holdcount)
        );
    } else if (count > 0) {
        if (
            confirm(
                __(
                    "Are you sure you want to delete the %s attached items?"
                ).format(count)
            )
        ) {
            return $(link).siblings("form").submit();
        } else {
            return false;
        }
    } else {
        return false;
    }
}

/* END IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) */

$(document).ready(function () {
    $("#z3950copy").click(function () {
        PopupZ3950();
        return false;
    });
    $("#deletebiblio").click(function () {
        confirm_deletion(this);
        return false;
    });
    $("#deleteallitems").click(function () {
        confirm_items_deletion(this);
        return false;
    });
    $("#printbiblio").click(function () {
        printBiblio();
        return false;
    });

    $(".addtocart").on("click", function (e) {
        e.preventDefault();
        var selection_id = this.id;
        var biblionumber = selection_id.replace("cart", "");
        addRecord(biblionumber);
    });

    $(".cartRemove").on("click", function (e) {
        e.preventDefault();
        var selection_id = this.id;
        var biblionumber = selection_id.replace("cartR", "");
        delSingleRecord(biblionumber);
        $(".addtocart").html(
            '<i class="fa fa-shopping-cart"></i> ' + __("Add to cart")
        );
    });

    $("#export").remove(); // Hide embedded export form if JS menus available

    $(".addtolist").on("click", function (e) {
        e.preventDefault();
        var shelfnumber = $(this).data("shelfnumber");
        if ($(this).hasClass("morelists")) {
            openWindow(
                "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=" +
                    biblionumber
            );
        } else if ($(this).hasClass("newlist")) {
            openWindow(
                "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?newshelf=1&biblionumber=" +
                    biblionumber
            );
        } else {
            openWindow(
                "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?shelfnumber=" +
                    shelfnumber +
                    "&confirm=1&biblionumber=" +
                    biblionumber
            );
        }
    });
});
