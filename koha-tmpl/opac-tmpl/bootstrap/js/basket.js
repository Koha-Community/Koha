/* global __ __p */
/* exported addMultiple delSingleRecord vShelfAdd openBiblio addSelToShelf delBasket sendBasket showMore showLess delSelRecords holdSel selRecord */
//////////////////////////////////////////////////////////////////////////////
// BASIC FUNCTIONS FOR COOKIE MANAGEMENT //
//////////////////////////////////////////////////////////////////////////////

function basketCount() {
    var valCookie = readCookie("bib_list");
    var basketcount = 0;
    if (valCookie) {
        var arrayRecords = valCookie.split("/");
        if (arrayRecords.length > 0) {
            basketcount = arrayRecords.length - 1;
        } else {
            basketcount = 0;
        }
    } else {
        basketcount = 0;
    }
    return basketcount;
}

function writeCookie(name, val, wd) {
    if (wd) {
        parent.opener.document.cookie = name + "=" + val + ";path=/";
    } else {
        parent.document.cookie = name + "=" + val + ";path=/";
    }
}

function readCookie(name, wd) {
    var str_name = name + "=";
    var str_cookie = "";
    if (wd) {
        str_cookie = parent.opener.document.cookie;
    } else {
        str_cookie = parent.document.cookie;
    }
    // fixed - getting the part of the basket that is bib_list
    var cookie_parts = str_cookie.split(";");
    for (var i = 0; i < cookie_parts.length; i++) {
        var c = cookie_parts[i];
        while (c.charAt(0) == " ") c = c.substring(1, c.length);
        if (c.indexOf(str_name) == 0)
            return c.substring(str_name.length, c.length);
    }
    return null;
}

function delCookie(name) {
    var exp = new Date();
    exp.setTime(exp.getTime() - 1);
    if (parent.opener) {
        parent.opener.document.cookie =
            name + "=null; path=/; expires=" + exp.toGMTString();
    } else {
        document.cookie = name + "=null; path=/; expires=" + exp.toGMTString();
    }
}

///////////////////////////////////////////////////////////////////
// SPECIFIC FUNCTIONS USING COOKIES //
///////////////////////////////////////////////////////////////////

function openBasket() {
    var strCookie = "";
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    if (valCookie) {
        strCookie = nameCookie + "=" + valCookie;
    }

    if (strCookie) {
        var iW = 820;
        var iH = 820;
        var optWin =
            "status=yes,scrollbars=yes,resizable=yes,toolbar=no,location=yes,height=" +
            iH +
            ",width=" +
            iW;
        var loc = "/cgi-bin/koha/opac-basket.pl?" + strCookie;
        var basket = open(loc, "basket", optWin);
        if (window.focus) {
            basket.focus();
        }
    } else {
        showCartUpdate(__("Your cart is currently empty"));
    }
}

function addRecord(val, selection, NoMsgAlert) {
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var write = 0;

    if (!valCookie) {
        // empty basket
        valCookie = val + "/";
        write = 1;
        updateBasket(1);
    } else {
        // is this record already in the basket ?
        var found = false;
        var arrayRecords = valCookie.split("/");
        for (var i = 0; i < valCookie.length - 1; i++) {
            if (val == arrayRecords[i]) {
                found = true;
                break;
            }
        }
        if (found) {
            if (selection) {
                return 0;
            }
            if (!NoMsgAlert) {
                showCartUpdate(
                    __p(
                        "Bibliographic record",
                        "The item is already in your cart"
                    )
                );
            }
        } else {
            valCookie += val + "/";
            write = 1;
            updateBasket(arrayRecords.length);
        }
    }

    if (write) {
        writeCookie(nameCookie, valCookie);
        if (selection) {
            // when adding a selection of records
            updateLink(val, "add");
            return 1;
        }
        if (!NoMsgAlert) {
            showCartUpdate(
                __p(
                    "Bibliographic record",
                    "The item has been added to your cart"
                )
            );
            updateLink(val, "add");
        }
    }
}

function addMultiple() {
    var c_value = "";
    if (document.bookbag_form.biblionumber.length > 0) {
        for (var i = 0; i < document.bookbag_form.biblionumber.length; i++) {
            if (document.bookbag_form.biblionumber[i].checked) {
                c_value =
                    c_value + document.bookbag_form.biblionumber[i].value + "/";
            }
        }
        addSelRecords(c_value);
    } else {
        c_value = c_value + document.bookbag_form.biblionumber.value + "/";
        addSelRecords(c_value);
    }
}

/* function for adding a selection of biblios to the basket from the results list */
function addSelRecords(valSel) {
    var arrayRecords = valSel.split("/");
    var i = 0;
    var nbAdd = 0;
    for (i = 0; i < arrayRecords.length; i++) {
        if (arrayRecords[i]) {
            nbAdd += addRecord(arrayRecords[i], 1);
        } else {
            break;
        }
    }
    var msg = "";
    if (nbAdd) {
        if (i > nbAdd) {
            msg =
                nbAdd +
                " " +
                __p("Bibliographic record", " item(s) added to your cart") +
                ", " +
                (i - nbAdd) +
                " " +
                __("already in your cart");
        } else {
            msg =
                nbAdd +
                " " +
                __p("Bibliographic record", " item(s) added to your cart");
        }
    } else {
        if (i < 1) {
            msg = __p("Bibliographic record", "No item was selected");
        } else {
            msg =
                __p("Bibliographic record", "No item was added to your cart") +
                " (" +
                __("already in your cart") +
                ") !";
        }
    }
    showCartUpdate(msg);
}

function showCartUpdate(msg) {
    // set body of popup window
    $("#cartDetails").html(msg);
    showCart();
    setTimeout(hideCart, 2000);
}

function showListsUpdate(msg) {
    // set body of popup window
    alert(msg);
}

function selRecord(num, status) {
    var str = document.myform.records.value;
    if (status) {
        str += num + "/";
    } else {
        str = delRecord(num, str);
    }

    document.myform.records.value = str;
}

function delSingleRecord(biblionumber) {
    biblionumber = String(biblionumber);
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var arrayRecords = valCookie.split("/");
    var pos = jQuery.inArray(biblionumber, arrayRecords);
    arrayRecords.splice(pos, 1);
    valCookie = arrayRecords.join("/");
    writeCookie(nameCookie, valCookie);
    updateBasket(arrayRecords.length - 1);
    updateLink(biblionumber, "del");
    showCartUpdate(
        __p("Bibliographic record", "The item has been removed from your cart")
    );
}

function delSelRecords() {
    var recordsSel = 0;
    var end = 0;
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie, 1);
    if (valCookie) {
        var str = document.myform.records.value;
        if (str.length > 0) {
            recordsSel = 1;
            var str2 = valCookie;
            while (!end) {
                var s = str.indexOf("/");
                if (s > 0) {
                    var num = str.substring(0, s);
                    str = delRecord(num, str);
                    str2 = delRecord(num, str2);
                    updateLink(num, "del", top.opener);
                } else {
                    end = 1;
                }
            }

            if (str2.length == 0) {
                // equivalent to emptying the basket
                var rep = false;
                rep = confirm(__("Are you sure you want to empty your cart?"));
                if (rep) {
                    delCookie(nameCookie);
                    document.location = "about:blank";
                    updateBasket(0, top.opener);
                    window.close();
                } else {
                    return;
                }
            } else {
                writeCookie(nameCookie, str2, 1);
            }
        }
    }

    if (recordsSel) {
        var strCookie = "";
        valCookie = readCookie(nameCookie, 1);
        strCookie = nameCookie + "=" + valCookie;
        var arrayRecords = valCookie.split("/");
        updateBasket(arrayRecords.length - 1, top.opener);
        document.location = "/cgi-bin/koha/opac-basket.pl?" + strCookie;
    } else {
        alert(__p("Bibliographic record", "No item was selected"));
    }
}

function delRecord(n, s) {
    var re = /\d/;
    var aux = s;
    var found = 0;
    var pos = -1;

    while (!found) {
        pos = aux.indexOf(n, pos + 1);
        var charAfter = aux.charAt(pos + n.length); // character right after the researched string
        if (charAfter.match(re)) {
            // record number inside another one
            continue;
        } else {
            // good record number
            aux =
                s.substring(0, pos) + s.substring(pos + n.length + 1, s.length);
            s = aux;
            found = 1;
        }
    }

    return s;
}

function delBasket() {
    var nameCookie = "bib_list";

    var rep = false;
    rep = confirm(__("Are you sure you want to empty your cart?"));
    if (rep) {
        delCookie(nameCookie);
        updateAllLinks(top.opener);
        document.location = "about:blank";
        updateBasket(0, top.opener);
        window.close();
    }
}

function sendBasket() {
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var strCookie = nameCookie + "=" + valCookie;

    var loc = "/cgi-bin/koha/opac-sendbasket.pl?" + strCookie;

    var optWin =
        "scrollbars=yes,resizable=yes,height=600,width=900,top=50,left=100";
    open(loc, "win_form", optWin);
}

function showMore() {
    var strCookie = "";

    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    if (valCookie) {
        strCookie = nameCookie + "=" + valCookie;
    }
    var loc = "/cgi-bin/koha/opac-basket.pl?" + strCookie + "&verbose=1";
    document.location = loc;
}

function showLess() {
    var strCookie = "";

    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    if (valCookie) {
        strCookie = nameCookie + "=" + valCookie;
    }
    var loc = "/cgi-bin/koha/opac-basket.pl?" + strCookie + "&verbose=0";
    document.location = loc;
}

function holdSel() {
    var items = document.getElementById("records").value;
    if (items) {
        parent.opener.document.location =
            "/cgi-bin/koha/opac-reserve.pl?biblionumbers=" + items;
        window.close();
    } else {
        alert(__p("Bibliographic record", "No item was selected"));
    }
}

function updateBasket(updated_value, target) {
    var bcount = "";
    if (updated_value > 0) {
        bcount = "<span>" + updated_value + "</span>";
    }
    if (target) {
        target.$("#basketcount").html(bcount);
    } else {
        $("#basketcount").html(bcount);
    }
}

function openBiblio(dest, biblionumber) {
    var openerURL = dest + "?biblionumber=" + biblionumber;
    opener.document.location = openerURL;
    opener.focus();
}

function addSelToShelf() {
    var items = document.getElementById("records").value;
    if (items) {
        var iW = 820;
        var iH = 450;
        var optWin =
            "status=yes,scrollbars=yes,resizable=yes,toolbar=no,location=yes,height=" +
            iH +
            ",width=" +
            iW;
        var loc =
            "/cgi-bin/koha/opac-addbybiblionumber.pl?biblionumber=" + items;
        open(loc, "shelf", optWin);
    } else {
        alert(__p("Bibliographic record", "No item was selected"));
    }
}

///  vShelfAdd()  builds url string for multiple-biblio adds.

function vShelfAdd() {
    var bibs = new Array();
    if (document.bookbag_form.biblionumber.length > 0) {
        for (var i = 0; i < document.bookbag_form.biblionumber.length; i++) {
            if (document.bookbag_form.biblionumber[i].checked) {
                bibs.push(
                    "biblionumber=" +
                        document.bookbag_form.biblionumber[i].value
                );
            }
        }
        if (bibs.length == 0) {
            showListsUpdate(
                __p("Bibliographic record", "No item was selected")
            );
        }
        return bibs.join("&");
    } else {
        if (document.bookbag_form.biblionumber.checked) {
            return "biblionumber=" + document.bookbag_form.biblionumber.value;
        }
    }
}

function showCart() {
    $("#cartDetails").fadeIn("fast");
}

function hideCart() {
    $("#cartDetails").fadeOut("fast");
}

function updateLink(val, op, target) {
    if (target) {
        if (op == "add") {
            target
                .$("a.cart" + val)
                .html(
                    '<i class="fa fa-fw fa-shopping-cart"></i> ' +
                        __("In your cart")
                )
                .addClass("incart");
            target.$("a.cartR" + val).show();
        } else {
            target
                .$("a.cart" + val)
                .html(
                    '<i class="fa fa-fw fa-shopping-cart"></i> ' +
                        __("Add to cart")
                )
                .removeClass("incart")
                .addClass("addtocart cart" + val);
            target.$("a.cartR" + val).hide();
        }
    } else {
        if (op == "add") {
            $("a.cart" + val)
                .html(
                    '<i class="fa fa-fw fa-shopping-cart"></i> ' +
                        __("In your cart")
                )
                .addClass("incart");
            $("a.cartR" + val).show();
        } else {
            $("a.cart" + val)
                .html(
                    '<i class="fa fa-fw fa-shopping-cart"></i> ' +
                        __("Add to cart")
                )
                .removeClass("incart")
                .addClass("addtocart cart" + val);
            $("a.cartR" + val).hide();
        }
    }
}

function updateAllLinks(target) {
    if (target) {
        target
            .$("a.incart")
            .html(
                '<i class="fa fa-fw fa-shopping-cart"></i> ' + __("Add to cart")
            )
            .removeClass("incart")
            .addClass("addtocart");
        target.$("a.cartRemove").hide();
    } else {
        $("a.incart")
            .html(
                '<i class="fa fa-fw fa-shopping-cart"></i> ' + __("Add to cart")
            )
            .removeClass("incart")
            .addClass("addtocart");
        $("a.cartRemove").hide();
    }
}

$("#cartDetails").ready(function () {
    $("#cartDetails,#cartmenulink").on("click", function () {
        hideCart();
    });
    $("#cartmenulink").click(function (e) {
        e.preventDefault();
        openBasket();
        $("li").closest().removeClass("open");
    });
    updateBasket(basketCount());
});
