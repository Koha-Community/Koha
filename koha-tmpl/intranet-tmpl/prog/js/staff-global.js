// staff-global.js
if ( KOHA === undefined ) var KOHA = {};

function _(s) { return s; } // dummy function for gettext

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function() { return formatstr(this, arguments); };
function formatstr(str, col) {
    col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") { return "%"; }
        if (m == "%s") { return col[idx++]; }
        return col[n];
    });
}

var HtmlCharsToEscape = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;'
};
String.prototype.escapeHtml = function() {
    return this.replace(/[&<>]/g, function(c) {
        return HtmlCharsToEscape[c] || c;
    });
};

// http://stackoverflow.com/questions/14859281/select-tab-by-name-in-jquery-ui-1-10-0/16550804#16550804
$.fn.tabIndex = function () {
    return $(this).parent().children('div').index(this);
};
$.fn.selectTabByID = function (tabID) {
    $(this).tabs("option", "active", $(tabID).tabIndex());
};

 $(document).ready(function() {
    $('#header_search').tabs().on( "tabsactivate", function(e, ui) { $(this).find("div:visible").find('input').eq(0).focus(); });

    $(".close").click(function(){ window.close(); });

    if($("#header_search #checkin_search").length > 0){ shortcut.add('Alt+r',function (){ $("#header_search").selectTabByID("#checkin_search"); $("#ret_barcode").focus(); }); } else { shortcut.add('Alt+r',function (){ location.href="/cgi-bin/koha/circ/returns.pl"; }); }
    if($("#header_search #circ_search").length > 0){ shortcut.add('Alt+u',function (){ $("#header_search").selectTabByID("#circ_search"); $("#findborrower").focus(); }); } else { shortcut.add('Alt+u',function(){ location.href="/cgi-bin/koha/circ/circulation.pl"; }); }
    if($("#header_search #catalog_search").length > 0){ shortcut.add('Alt+q',function (){ $("#header_search").selectTabByID("#catalog_search"); $("#search-form").focus(); }); } else { shortcut.add('Alt+q',function(){ location.href="/cgi-bin/koha/catalogue/search.pl"; }); }
    if($("#header_search #renew_search").length > 0){ shortcut.add('Alt+w',function (){ $("#header_search").selectTabByID("#renew_search"); $("#ren_barcode").focus(); }); } else { shortcut.add('Alt+w',function(){ location.href="/cgi-bin/koha/circ/renew.pl"; }); }

    $("#header_search > ul > li").show();

    $(".focus").focus();
    $(".validated").each(function() {
        $(this).validate();
    });

    $("#logout").on("click",function(){
        logOut();
    });
    $("#helper").on("click",function(){
        openHelp();
        return false;
    });

    $("body").on("keypress", ".noEnterSubmit", function(e){
        return checkEnter(e);
    });

    $(".keep_text").on("click",function(){
        var field_index = $(this).parent().index();
        keep_text( field_index );
    });

    $(".toggle_element").on("click",function(e){
        e.preventDefault();
        $( $(this).data("element") ).toggle();
    });

    var navmenulist = $("#navmenulist");
    if( navmenulist.length > 0 ){
        var path = location.pathname.substring(1);
        var url = window.location.toString();
        var params = '';
        if ( url.match(/\?(.+)$/) ) {
            params = "?" + RegExp.$1;
        }
        $("a[href$=\"/" + path + params + "\"]", navmenulist).addClass("current");
    }

});

// http://jennifermadden.com/javascript/stringEnterKeyDetector.html
function checkEnter(e){ //e is event object passed from function invocation
    var characterCode; // literal character code will be stored in this variable
    if(e && e.which){ //if which property of event object is supported (NN4)
        characterCode = e.which; //character code is contained in NN4's which property
    } else {
        characterCode = e.keyCode; //character code is contained in IE's keyCode property
    }

    if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
        return false;
    } else {
        return true;
    }
}

function clearHoldFor(){
    $.removeCookie("holdfor", { path: '/' });
}

function logOut(){
    if( typeof delBasket == 'function' ){
        delBasket('main', true);
    }
    clearHoldFor();
}

function openHelp(){
    openWindow("/cgi-bin/koha/help.pl","KohaHelp",600,600);
}

jQuery.fn.preventDoubleFormSubmit = function() {
    jQuery(this).submit(function() {
    $("body, form input[type='submit'], form button[type='submit'], form a").addClass('waiting');
        if (this.beenSubmitted)
            return false;
        else
            this.beenSubmitted = true;
    });
};

function openWindow(link,name,width,height) {
    name = (typeof name == "undefined")?'popup':name;
    width = (typeof width == "undefined")?'600':width;
    height = (typeof height == "undefined")?'400':height;
    var newwin;
    //IE <= 9 can't handle a "name" with whitespace
    try {
        newin=window.open(link,name,'width='+width+',height='+height+',resizable=yes,toolbar=false,scrollbars=yes,top');
    } catch(e) {
        newin=window.open(link,null,'width='+width+',height='+height+',resizable=yes,toolbar=false,scrollbars=yes,top');
    }
}

// Use this function to remove the focus from any element for
// repeated scanning actions on errors so the librarian doesn't
// continue scanning and miss the error.
function removeFocus() {
    $(':focus').blur();
}

function toUC(f) {
    var x=f.value.toUpperCase();
    f.value=x;
    return true;
}

function confirmDelete(message) {
    return (confirm(message) ? true : false);
}

function confirmClone(message) {
    return (confirm(message) ? true : false);
}

function playSound( sound ) {
    if ( ! ( sound.indexOf('http://') === 0 || sound.indexOf('https://') === 0  ) ) {
        sound = AUDIO_ALERT_PATH + sound;
    }
    document.getElementById("audio-alert").innerHTML = '<audio src="' + sound + '" autoplay="autoplay" autobuffer="autobuffer"></audio>';
}

// For keeping the text when navigating the search tabs
function keep_text(clicked_index) {
    var searchboxes = document.getElementsByClassName("head-searchbox");
    var persist = searchboxes[0].value;

    for (i = 0; i < searchboxes.length - 1; i++) {
        if (searchboxes[i].value != searchboxes[i+1].value) {
            if (i === searchboxes.length-2) {
                if (searchboxes[i].value != searchboxes[0].value) {
                    persist = searchboxes[i].value;
                } else if (searchboxes.length === 2) {
                    if (clicked_index === 0) {
                        persist = searchboxes[1].value;
                    }
                } else {
                    persist = searchboxes[i+1].value;
                }
            } else if (searchboxes[i+1].value != searchboxes[i+2].value) {
                persist = searchboxes[i+1].value;
            }
        }
    }

    for (i = 0; i < searchboxes.length; i++) {
        searchboxes[i].value = persist;
    }
}
