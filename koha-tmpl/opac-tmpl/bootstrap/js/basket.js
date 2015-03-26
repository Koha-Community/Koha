//////////////////////////////////////////////////////////////////////////////
// BASIC FUNCTIONS FOR COOKIE MANAGEMENT //
//////////////////////////////////////////////////////////////////////////////

function basketCount(){
    var valCookie = readCookie("bib_list");
    if(valCookie){
        var arrayRecords = valCookie.split("/");
        if(arrayRecords.length > 0){
            var basketcount = arrayRecords.length-1;
        } else {
            var basketcount = 0;
        }
    } else {
            var basketcount = 0;
    }
    return basketcount;
}

function writeCookie(name, val, wd) {
    if (wd) {
        parent.opener.document.cookie = name + "=" + val;
    }
    else {
        parent.document.cookie = name + "=" + val;
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
    var str_len = str_name.length;
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
            if(c.indexOf(str_name) == 0) return c.substring(str_name.length,c.length);
            }
    return null;
}

function delCookie(name) {
    var exp = new Date();
    exp.setTime(exp.getTime()-1);
    if(parent.opener){
        parent.opener.document.cookie = name + "=null; expires=" + exp.toGMTString();
    } else {
        document.cookie = name + "=null; expires=" + exp.toGMTString();
    }
}

///////////////////////////////////////////////////////////////////
// SPECIFIC FUNCTIONS USING COOKIES //
///////////////////////////////////////////////////////////////////

function openBasket() {
    var strCookie = "";
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    if ( valCookie ) {
        strCookie = nameCookie + "=" + valCookie;
    }

    if ( strCookie ) {
        var iW = 820;
        var iH = 450;
        var optWin = "status=yes,scrollbars=yes,resizable=yes,toolbar=no,location=yes,height="+iH+",width="+iW;
        var loc = "/cgi-bin/koha/opac-basket.pl?" + strCookie;
        var basket = open(loc, "basket", optWin);
        if (window.focus) {basket.focus()}
    }
    else {
        showCartUpdate(MSG_BASKET_EMPTY);
    }
}

function addRecord(val, selection,NoMsgAlert) {
    var nameCookie = "bib_list";
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
                showCartUpdate(MSG_RECORD_IN_BASKET);
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
            showCartUpdate(MSG_RECORD_ADDED);
            updateLink(val,"add");
        }

    }
}

function AllAreChecked(s){
    if (! s.length) { return false;}
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

function addMultiple(){
    var c_value = "";
    if(document.bookbag_form.biblionumber.length > 0) {
        for (var i=0; i < document.bookbag_form.biblionumber.length; i++) {
            if (document.bookbag_form.biblionumber[i].checked) {
                c_value = c_value + document.bookbag_form.biblionumber[i].value + "/";
            }
        }
        addSelRecords(c_value);
    } else {
        c_value = c_value + document.bookbag_form.biblionumber.value + "/";
        addSelRecords(c_value);
    }
}

function addSelRecords(valSel) { // function for adding a selection of biblios to the basket
                                                // from the results list
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
            msg = nbAdd+" "+MSG_NRECORDS_ADDED+", "+(i-nbAdd)+" "+MSG_NRECORDS_IN_BASKET;
        }
        else {
            msg = nbAdd+" "+MSG_NRECORDS_ADDED;
        }
    }
    else {
        if (i < 1) {
            msg = MSG_NO_RECORD_SELECTED;
        }
        else {
            msg = MSG_NO_RECORD_ADDED+" ("+MSG_NRECORDS_IN_BASKET+") !";
        }
    }
    showCartUpdate(msg);
}

function showCartUpdate(msg){
    // set body of popup window
    $("#cartDetails").html(msg);
    $("#cartmenuitem").html(MSG_IN_YOUR_CART + " " + basketCount());
    showCart();
    setTimeout("hideCart()",2000);
}

function selRecord(num, status) {
    var str = document.myform.records.value
    if (status){
        str += num+"/";
    }
    else {
        str = delRecord(num, str);
    }

    document.myform.records.value = str;
}

function delSingleRecord(biblionumber){
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var arrayRecords = valCookie.split("/");
    var pos = jQuery.inArray(biblionumber,arrayRecords);
    arrayRecords.splice(pos,1);
    valCookie = arrayRecords.join("/");
    writeCookie( nameCookie, valCookie );
    updateBasket( arrayRecords.length-1 );
    updateLink(biblionumber,"del");
    showCartUpdate(MSG_RECORD_REMOVED);
}

function delSelRecords() {
    var recordsSel = 0;
    var end = 0;
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie, 1);
    if (valCookie) {
        var str = document.myform.records.value;
        if (str.length > 0){
            recordsSel = 1;
            var str2 = valCookie;
            while (!end){
                s = str.indexOf("/");
                if (s>0){
                    num = str.substring(0, s);
                    str = delRecord(num,str);
                    str2 = delRecord(num,str2);
                    updateLink(num,"del",top.opener);
                } else {
                    end = 1;
                }
            }

            if (str2.length == 0) { // equivalent to emptying the basket
                var rep = false;
                rep = confirm(MSG_CONFIRM_DEL_BASKET);
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
        var nameCookie = "bib_list";
        var valCookie = readCookie(nameCookie, 1);
        strCookie = nameCookie + "=" + valCookie;
        var arrayRecords = valCookie.split("/");
        updateBasket(arrayRecords.length-1,top.opener);
        document.location = "/cgi-bin/koha/opac-basket.pl?" + strCookie;
    }
    else {
        alert(MSG_NO_RECORD_SELECTED);
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


function delBasket() {
    var nameCookie = "bib_list";

    var rep = false;
    rep = confirm(MSG_CONFIRM_DEL_BASKET);
    if (rep) {
        delCookie(nameCookie);
        updateAllLinks(top.opener);
        document.location = "about:blank";
        updateBasket(0,top.opener);
        window.close();
    }
}


function quit() {
    if (document.myform.records.value) {
        var rep = false;
        rep = confirm(MSG_CONFIRM_DEL_RECORDS);
        if (rep) {
            delSelRecords();
        }
    }
    updateBasket(arrayRecords.length-1,top.opener);
    window.close();
}

function sendBasket() {
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var strCookie = nameCookie + "=" + valCookie;

    var loc = "/cgi-bin/koha/opac-sendbasket.pl?" + strCookie;

    var optWin="scrollbars=yes,resizable=yes,height=600,width=900,top=50,left=100";
    var win_form = open(loc,"win_form",optWin);
}

function downloadBasket() {
    var nameCookie = "bib_list";
    var valCookie = readCookie(nameCookie);
    var strCookie = nameCookie + "=" + valCookie;

    var loc = "/cgi-bin/koha/opac-downloadcart.pl?" + strCookie;

    open(loc,"win_form",'scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
}

function printBasket() {
    var loc = document.location + "&print=1";
    document.location = loc;
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
    var items = document.getElementById('records').value;
    if (items) {
        parent.opener.document.location = "/cgi-bin/koha/opac-reserve.pl?biblionumbers=" + items;
        window.close();
    } else {
        alert(MSG_NO_RECORD_SELECTED);
    }
}

function updateBasket(updated_value,target) {
    if(updated_value > 0){
        bcount = "<span>"+updated_value+"</span>";
    } else {
        bcount = "";
    }
    if(target){
        target.$('#basketcount').html(bcount);
        target.$('.cart-message').html(MSG_IN_YOUR_CART+updated_value);
    } else {
        $('#basketcount').html(bcount);
        $('.cart-message').html(MSG_IN_YOUR_CART+updated_value);
    }
}

function openBiblio(dest,biblionumber) {
    openerURL=dest+"?biblionumber="+biblionumber;
    opener.document.location = openerURL;
    opener.focus();
}

function addSelToShelf() {
    var items = document.getElementById('records').value;
    if(items){
        var iW = 820;
        var iH = 450;
        var optWin = "status=yes,scrollbars=yes,resizable=yes,toolbar=no,location=yes,height="+iH+",width="+iW;
        var loc = "/cgi-bin/koha/opac-addbybiblionumber.pl?biblionumber="+items;
        var shelf = open(loc, "shelf", optWin);
    } else {
        alert(MSG_NO_RECORD_SELECTED);
    }
}

///  vShelfAdd()  builds url string for multiple-biblio adds.

function vShelfAdd() {
        bibs= new Array;
        if(document.bookbag_form.biblionumber.length > 0) {
                for (var i=0; i < document.bookbag_form.biblionumber.length; i++) {
                        if (document.bookbag_form.biblionumber[i].checked) {
                                bibs.push("biblionumber=" +  document.bookbag_form.biblionumber[i].value);
                        }
                }
        if (bibs.length == 0) { showListsUpdate(MSG_NO_RECORD_SELECTED); }
            return bibs.join("&");
        } else {
            if (document.bookbag_form.biblionumber.checked) {
                return "biblionumber=" + document.bookbag_form.biblionumber.value;
            }
        }
}

function showCart(){
    var position = $("#cartmenulink").offset();
    var scrolld = $(window).scrollTop();
    var top = position.top + $("#cartmenulink").outerHeight();
    if( scrolld > top ){
        top = scrolld + 15;
    }
    var menuWidth = 200;
    var buttonWidth = $("#cartmenulink").innerWidth();
    var buttonOffset = menuWidth - buttonWidth;
    var left = position.left -  0 // buttonOffset;
    $("#cartDetails")
        .css({"position":"absolute", "top":top, "left":left})
        .fadeIn("fast");
}

function hideCart(){
    $("#cartDetails").fadeOut("fast");
}

function updateLink(val,op,target){
    if(target){
        if(op == "add"){
            target.$("a.cart"+val).html(MSG_ITEM_IN_CART).addClass("incart");
            target.$("a.cartR"+val).show();
        } else {
            target.$("a.cart"+val).html(MSG_ITEM_NOT_IN_CART).removeClass("incart").addClass("addtocart cart"+val);
            target.$("a.cartR"+val).hide();
        }
    } else {
        if(op == "add"){
            $("a.cart"+val).html(MSG_ITEM_IN_CART).addClass("incart");
            $("a.cartR"+val).show();
        } else {
            $("a.cart"+val).html(MSG_ITEM_NOT_IN_CART).removeClass("incart").addClass("addtocart cart"+val);
            $("a.cartR"+val).hide();
        }
    }
}

function updateAllLinks(target){
    if(target){
        target.$("a.incart").html(MSG_ITEM_NOT_IN_CART).removeClass("incart").addClass("addtocart");
        target.$("a.cartRemove").hide();
    } else {
        $("a.incart").html(MSG_ITEM_NOT_IN_CART).removeClass("incart").addClass("addtocart");
        $("a.cartRemove").hide();
    }
}

$("#cartDetails").ready(function(){
    $("#cartDetails,#cartmenuitem,#cartmenulink").on("click",function(){ hideCart(); });
    $("#cartmenuitem").click(function(e){
        e.preventDefault();
        openBasket();
        $("li").closest().removeClass("open");
    });
    updateBasket(basketCount());
});
