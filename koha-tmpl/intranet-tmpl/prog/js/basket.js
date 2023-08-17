/* global __ getContextBiblioNumbers */
/* exported readCookie readCookieValue SelectAll addMultiple selRecord delSingleRecord delBasket quit sendBasket downloadBasket printBasket showMore showLess openBiblio addSelToShelf vShelfAdd */

//////////////////////////////////////////////////////////////////////////////
// BASIC FUNCTIONS FOR COOKIE MANAGEMENT //
//////////////////////////////////////////////////////////////////////////////

var CGIBIN = "/cgi-bin/koha/";

var nameCookie = "intranet_bib_list";
var nameParam = "bib_list";
var valCookie = readCookie(nameCookie);
var basketcount;

if(valCookie){
    var arrayRecords = valCookie.split("/");
    if(arrayRecords.length > 0){
        basketcount = arrayRecords.length-1;
    } else {
        basketcount = "";
    }
} else {
    basketcount = "";
}

function writeCookie(name, val, wd) {
    if (wd) {
        parent.opener.document.cookie = name + "=" + val + "; SameSite=Lax; path=/";
    }
    else {
        parent.document.cookie = name + "=" + val + "; SameSite=Lax; path=/";
    }
}

function readCookieValue (str, val_beg) {
    var val_end = str.indexOf(";", val_end);
    if (val_end == -1)
        val_end = str.length;
    return str.substring(val_beg, val_end);
}

function readCookie(name, wd) {
    var str_name = name + "=";
    var str_cookie = "";
    if (wd) {
        str_cookie = parent.opener.document.cookie;
    }
    else {
        str_cookie = parent.document.cookie;
    }
    // fixed - getting the part of the basket that is bib_list
    var cookie_parts = str_cookie.split(";");
    for(var i=0;i < cookie_parts.length;i++) {
        var c = cookie_parts[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if(c.indexOf(str_name) === 0) return c.substring(str_name.length,c.length);
    }
    return null;
}

function delCookie(name) {
    var exp = new Date();
    exp.setTime(exp.getTime()-1);
    if(parent.opener){
        parent.opener.document.cookie = name + "=null; SameSite=Lax; path=/; expires=" + exp.toGMTString();
    } else {
        document.cookie = name + "=null; SameSite=Lax; path=/; expires=" + exp.toGMTString();
    }
}

///////////////////////////////////////////////////////////////////
// SPECIFIC FUNCTIONS USING COOKIES //
///////////////////////////////////////////////////////////////////

function openBasket() {
    var strCookie = "";
    var valCookie = readCookie(nameCookie);
    if ( valCookie ) {
        strCookie = nameParam + "=" + valCookie;
    }

    if ( strCookie ) {
        var iW = 820;
        var iH = 450;
        var optWin = "status=yes,scrollbars=yes,resizable=yes,toolbar=no,location=yes,height="+iH+",width="+iW;
        var loc = CGIBIN + "basket/basket.pl?" + strCookie;
        var basket = open(loc, "basket", optWin);
        if (window.focus) { basket.focus(); }
    }
    else {
        showCartUpdate( __("Your cart is currently empty") );
    }
}

function addRecord(val, selection,NoMsgAlert) {
    var valCookie = readCookie(nameCookie);
    var write = 0;

    if ( ! valCookie ) { // empty basket
        valCookie = val + '/';
        write = 1;
        updateBasket(1);
    }
    else {
        // is this record already in the basket ?
        var found = false;
        var arrayRecords = valCookie.split("/");
        for (var i = 0; i < valCookie.length - 1; i++) {
            if (val == arrayRecords[i]) {
                found = true;
                break;
            }
        }
        if ( found ) {
            if (selection) {
                return 0;
            }
            if (! NoMsgAlert ) {
                showCartUpdate( __("This item is already in your cart") );
            }
        }
        else {
            valCookie += val + '/';
            write = 1;
            updateBasket(arrayRecords.length);
        }
    }

    if (write) {
        writeCookie(nameCookie, valCookie);
        if (selection) { // when adding a selection of records
            updateLink(val,"add");
            return 1;
        }
        if (! NoMsgAlert ) {
            showCartUpdate( __("This item has been added to your cart") );
            updateLink(val,"add");
        }
    }
}

function AllAreChecked(s){
    if (! s.length){ return false;}
    var l = s.length;
    for (var i=0; i < l; i++) {
        if(! s[i].checked) { return false; }
    }
    return true;
}

function SelectAll(){
    if(document.bookbag_form.biblionumber.length > 0) {
        var checky = AllAreChecked(document.bookbag_form.biblionumber);
        var l = document.bookbag_form.biblionumber.length;
        for (var i=0; i < l; i++) {
            document.bookbag_form.biblionumber[i].checked = (checky) ? false : true;
        }
    }
}

function addMultiple(biblist){
    var c_value = "";
    var i = 0;
    if( biblist && biblist.length > 0 ) {
        for ( i=0; i < biblist.length; i++ ) {
            if (biblist[i].checked) {
                c_value = c_value + biblist[i].value + "/";
            }
        }
    } else {
        var bibnums = getContextBiblioNumbers();
        if ( bibnums.length > 0 ) {
            for ( i = 0 ; i < bibnums.length ; i++ ) {
                c_value = c_value + bibnums[i] + "/";
            }
        } else {
            if(document.bookbag_form.biblionumber.length > 0) {
                for ( i=0; i < document.bookbag_form.biblionumber.length; i++ ) {
                    if (document.bookbag_form.biblionumber[i].checked) {
                        c_value = c_value + document.bookbag_form.biblionumber[i].value + "/";
                    }
                }
            } else {
                c_value = c_value + document.bookbag_form.biblionumber.value + "/";
            }
        }
    }
    addSelRecords(c_value);
}

/* function for adding a selection of biblios to the basket
   from the results list */
function addSelRecords(valSel) {
    var arrayRecords = valSel.split("/");
    var i = 0;
    var nbAdd = 0;
    for (i=0;i<arrayRecords.length;i++) {
        if (arrayRecords[i]) {
            nbAdd += addRecord(arrayRecords[i], 1);
        }
        else {
            break;
        }
    }
    var msg = "";
    if (nbAdd) {
        if (i > nbAdd) {
            msg = __("%s item(s) added to your cart").format(nbAdd);
            msg += "<br/>";
            msg += __("%s already in your cart").format((i-nbAdd));
        }
        else {
            msg = __("%s item(s) added to your cart").format(nbAdd);
        }
    }
    else {
        if (i < 1) {
            msg = __("No item was selected");
        }
        else {
            msg = __("No item was added to your cart (already in your cart)!");
        }
    }
    showCartUpdate(msg);
}

function showCartUpdate(msg){
    // set body of popup window
    $("#cartDetails").html(msg);
    showCart();
    setTimeout(hideCart,2000);
}

function showListsUpdate(msg){
    // set body of popup window
    alert(msg);
}

function selRecord(num, status) {
    var str = document.myform.records.value;
    if (status){
        str += num+"/";
    }
    else {
        str = delRecord(num, str);
    }

    document.myform.records.value = str;
}

function delSingleRecord(biblionumber){
    var valCookie = readCookie(nameCookie);
    var arrayRecords = valCookie.split("/");
    var pos = jQuery.inArray(biblionumber,arrayRecords);
    arrayRecords.splice(pos,1);
    valCookie = arrayRecords.join("/");
    writeCookie( nameCookie, valCookie );
    updateBasket( arrayRecords.length-1 );
    updateLink(biblionumber,"del");
    showCartUpdate(__("The item has been removed from your cart"));
}

function delSelRecords() {
    var recordsSel = 0;
    var end = 0;
    var valCookie = readCookie(nameCookie, 1);
    var s;
    if (valCookie) {
        var str = document.myform.records.value;
        if (str.length > 0){
            recordsSel = 1;
            var str2 = valCookie;
            while (!end){
                s = str.indexOf("/");
                if (s>0){
                    var num = str.substring(0, s);
                    str = delRecord(num,str);
                    str2 = delRecord(num,str2);
                    updateLink(num,"del",top.opener);
                } else {
                    end = 1;
                }
            }

            if (str2.length === 0) { // equivalent to emptying the basket
                var rep = false;
                rep = confirm(__("Are you sure you want to empty your cart?"));
                if (rep) {
                    delCookie(nameCookie);
                    document.location = "about:blank";
                    updateBasket(0,top.opener);
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
        strCookie = nameParam + "=" + valCookie;
        var arrayRecords = valCookie.split("/");
        updateBasket(arrayRecords.length-1,top.opener);
        document.location = CGIBIN + "basket/basket.pl?" + strCookie;
    }
    else {
        alert(__("No item was selected"));
    }
}

function delRecord (n, s) {
    var re = /\d/;
    var aux = s;
    var found = 0;
    var pos = -1;

    while (!found) {
        pos = aux.indexOf(n, pos+1);
        var charAfter = aux.charAt(pos+n.length); // character right after the researched string
        if (charAfter.match(re)) { // record number inside another one
            continue;
        }
        else { // good record number
            aux = s.substring(0, pos)+ s.substring(pos+n.length+1, s.length);
            s = aux;
            found = 1;
        }
    }

    return s;
}

function delBasket(context,rep) {
    if (rep === undefined){
        rep = confirm(__("Are you sure you want to empty your cart?"));
    }
    if (rep) {
        if(context == "popup"){
            delCookie(nameCookie);
            updateAllLinks(top.opener);
            document.location = "about:blank";
            updateBasket(0,top.opener);
            window.close();
        } else {
            delCookie(nameCookie);
            updateBasket(0,top.opener);
        }
    }
}

function quit() {
    if (document.myform.records.value) {
        var rep = false;
        rep = confirm(__("Are you sure you want to remove the selected items?"));
        if (rep) {
            delSelRecords();
        }
    }
    updateBasket(arrayRecords.length-1,top.opener);
    window.close();
}

function sendBasket() {
    var valCookie = readCookie(nameCookie);
    var strCookie = nameParam + "=" + valCookie;
    var loc = CGIBIN + "basket/sendbasket.pl?" + strCookie;
    openWindow( loc, "win_form" );
}

function downloadBasket() {
    var valCookie = readCookie(nameCookie);
    var strCookie = nameParam + "=" + valCookie;

    var loc = CGIBIN + "basket/downloadcart.pl?" + strCookie;

    open(loc,"win_form",'scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
}

function printBasket() {
    window.print();
}

function showMore() {
    var strCookie = "";

    var valCookie = readCookie(nameCookie);
    if (valCookie) {
        strCookie = nameParam + "=" + valCookie;
    }
    var loc = CGIBIN + "basket/basket.pl?" + strCookie + "&verbose=1";
    document.location = loc;
}

function showLess() {
    var strCookie = "";

    var valCookie = readCookie(nameCookie);
    if (valCookie) {
        strCookie = nameParam + "=" + valCookie;
    }
    var loc = CGIBIN + "basket/basket.pl?" + strCookie + "&verbose=0";
    document.location = loc;
}

function updateBasket(updated_value,target) {
    if(target){
        target.$('#basketcount').html(" <span>("+updated_value+")</span>");
        target.$('#cartDetails').html(__("Items in your cart: %s").format(updated_value));
    } else {
        $('#basketcount').html(" <span>("+updated_value+")</span>");
        $('#cartDetails').html(__("Items in your cart: %s").format(updated_value));
    }
}

function openBiblio(openerURL) {
    opener.document.location = openerURL;
    opener.focus();
}

function addSelToShelf() {
    var items = document.getElementById('records').value;
    if(items){
        document.location = "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber="+items;
    } else {
        alert(__("No item was selected"));
    }
}

///  vShelfAdd()  builds url string for multiple-biblio adds.

function vShelfAdd(biblist) {
    var bibs = new Array;
    var i;
    if( biblist && biblist.length > 0 ) {
        for ( i=0; i < biblist.length; i++ ) {
            if (biblist[i].checked) {
                bibs.push("biblionumber=" +  biblist[i].value);
            }
        }
        if (bibs.length === 0) { showListsUpdate(__("No item was selected")); }
        return bibs.join("&");
    } else {
        var bibnums = getContextBiblioNumbers();
        if ( bibnums.length > 0 ) {
            for ( i = 0 ; i < bibnums.length ; i++ ) {
                bibs.push("biblionumber=" + bibnums[i]);
            }
            return bibs.join("&");
        } else {
            showListsUpdate(__("No item was selected"));
        }
    }
}

function showCart(){
    var position = $("#cartmenulink").offset();
    var toolbarh = $(".floating").outerHeight();
    var scrolld = $(window).scrollTop();
    var top = position.top + $("#cartmenulink").outerHeight();
    if( scrolld > top ){
        top = scrolld + toolbarh + 15;
    }
    var left = position.left;
    $("#cartDetails")
        .css("position","absolute")
        .css("top",top)
        .css("left",left)
        .css("z-index",1000);
    $("#cartDetails").fadeIn("fast");
}

function hideCart(){
    $("#cartDetails").fadeOut("fast");
}

function updateLink(val, op, target){
    var cart = target ? target.$("#cart" + val) : $("#cart" + val);
    var cartR = target ? target.$("#cartR" + val) : $("#cartR" + val);

    if(op == "add"){
        if( cart.hasClass("btn") ){
            /* Cart link is a button with an icon */
            cart.html("<i class=\"fa fa-shopping-cart\"></i> " + __("Add to cart")).addClass("incart");
            cart.hide();
        } else {
            cart.html( __("In your cart") ).addClass("incart");
        }
        cartR.show();
    } else {
        if (cart.hasClass("btn")) {
            cart.html("<i class=\"fa fa-shopping-cart\"></i> " + __("Add to cart")).addClass("addtocart");
            cart.show();
        } else {
            cart.html(__("Add to cart")).addClass("addtocart");
        }
        cartR.hide();
    }
}

function updateAllLinks(target){
    var cart = target ? target.$("a.incart") : $("a.incart");
    var cartR = target ? target.$(".cartRemove") : $(".cartRemove");
    if( cart.hasClass("btn") ){
        /* Cart link is a button with an icon */
        cart.html("<i class=\"fa fa-shopping-cart\"></i> " + __("Add to cart")).addClass("incart");
        cartR.hide();
    } else {
        cart.html( __("In your cart") ).addClass("incart");
    }
    cart.show();
}

$(document).ready(function(){
    $("#cartmenulink").click(function( e ){
        e.preventDefault();
        openBasket();
    });
    if(basketcount){ updateBasket(basketcount); }
});
