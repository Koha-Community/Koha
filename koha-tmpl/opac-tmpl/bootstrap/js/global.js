/* global enquire readCookie updateBasket delCookie __ */
(function( w ){
    // if the class is already set, the font has already been loaded
    if( w.document.documentElement.className.indexOf( "fonts-loaded" ) > -1 ){
        return;
    }
    var PrimaryFont = new w.FontFaceObserver( "NotoSans", {
        weight: 400
    });

    PrimaryFont.load(null, 5000).then(function(){
        w.document.documentElement.className += " fonts-loaded";
    }, function(){
        console.log("Failed");
    });
}( this ));

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function() { return formatstr(this, arguments) }
function formatstr(str, col) {
    col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") { return "%"; }
        if (m == "%s") { return col[idx++]; }
        return col[n];
    });
};

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
function escape_str(s){
    return s != null ? s.escapeHtml() : "";
}

function confirmDelete(message) {
    return (confirm(message) ? true : false);
}

function Dopop(link) {
    newin=window.open(link,'popup','width=660,height=450,toolbar=false,scrollbars=yes,resizable=yes');
}

jQuery.fn.preventDoubleFormSubmit = function() {
    jQuery(this).submit(function() {
        if (this.beenSubmitted)
            return false;
        else
            this.beenSubmitted = true;
    });
};

function prefixOf (s, tok) {
    var index = s.indexOf(tok);
    return s.substring(0, index);
}
function suffixOf (s, tok) {
    var index = s.indexOf(tok);
    return s.substring(index + 1);
}

$("body").on("keypress", ".noEnterSubmit", function(e){
    return checkEnter(e);
});

// http://jennifermadden.com/javascript/stringEnterKeyDetector.html
function checkEnter(e){ //e is event object passed from function invocation
    var characterCode; // literal character code will be stored in this variable
    if(e && e.which){ //if which property of event object is supported (NN4)
        characterCode = e.which; //character code is contained in NN4's which property
    } else {
        characterCode = e.keyCode; //character code is contained in IE's keyCode property
    }
    if( characterCode == 13 //if generated character code is equal to ascii 13 (if enter key)
        && e.target.nodeName == "INPUT"
        && e.target.type != "submit" // Allow enter to submit using the submit button
    ){
        return false;
    } else {
        return true;
    }
}

// Adapted from https://gist.github.com/jnormore/7418776
function confirmModal(message, title, yes_label, no_label, callback) {
    $("#bootstrap-confirm-box-modal").data('confirm-yes', false);
    if($("#bootstrap-confirm-box-modal").length == 0) {
        $("body").append('<div id="bootstrap-confirm-box-modal" tabindex="-1" role="dialog" aria-hidden="true" class="modal">\
            <div class="modal-dialog">\
                <div class="modal-content">\
                    <div class="modal-header" style="min-height:40px;">\
                        <h4 class="modal-title"></h4>\
                        <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close">\
                        <span aria-hidden="true">&times;</span>\
                    </button>\
                    </div>\
                    <div class="modal-body"><p></p></div>\
                    <div class="modal-footer">\
                        <a href="#" id="bootstrap-confirm-box-modal-submit" class="btn btn-danger"><i class="fa fa-check" aria-hidden="true"></i></a>\
                        <a href="#" id="bootstrap-confirm-box-modal-cancel" data-dismiss="modal" class="btn btn-secondary"><i class="fa fa-times" aria-hidden="true"></i></a>\
                    </div>\
                </div>\
            </div>\
        </div>');
        $("#bootstrap-confirm-box-modal-submit").on('click', function () {
            $("#bootstrap-confirm-box-modal").data('confirm-yes', true);
            $("#bootstrap-confirm-box-modal").modal('hide');
            return false;
        });
        $("#bootstrap-confirm-box-modal").on('hide.bs.modal', function () {
            if(callback) callback($("#bootstrap-confirm-box-modal").data('confirm-yes'));
        });
    }

    $("#bootstrap-confirm-box-modal .modal-header h4").text( title || "" );
    if( message && message != "" ){
        $("#bootstrap-confirm-box-modal .modal-body").html( message || "" );
    } else {
        $("#bootstrap-confirm-box-modal .modal-body").remove();
    }
    $("#bootstrap-confirm-box-modal-submit").text( yes_label || 'Confirm' );
    $("#bootstrap-confirm-box-modal-cancel").text( no_label || 'Cancel' );
    $("#bootstrap-confirm-box-modal").modal('show');
}


// Function to check errors from AJAX requests
const checkError = function(response) {
    if (response.status >= 200 && response.status <= 299) {
        return response.json();
    } else {
        console.log("Server returned an error:");
        console.log(response);
        alert("%s (%s)".format(response.statusText, response.status));
    }
};

//Add jQuery :focusable selector
(function($) {
    function visible(element) {
        return $.expr.filters.visible(element) && !$(element).parents().addBack().filter(function() {
            return $.css(this, 'visibility') === 'hidden';
        }).length;
    }

    function focusable(element, isTabIndexNotNaN) {
        var map, mapName, img, nodeName = element.nodeName.toLowerCase();
        if ('area' === nodeName) {
            map = element.parentNode;
            mapName = map.name;
            if (!element.href || !mapName || map.nodeName.toLowerCase() !== 'map') {
                return false;
            }
            img = $('img[usemap=#' + mapName + ']')[0];
            return !!img && visible(img);
        }
        return (/input|select|textarea|button|object/.test(nodeName) ?
                !element.disabled :
                'a' === nodeName ?
                element.href || isTabIndexNotNaN :
                isTabIndexNotNaN) &&
            // the element and all of its ancestors must be visible
            visible(element);
    }

    $.extend($.expr[':'], {
        focusable: function(element) {
            return focusable(element, !isNaN($.attr(element, 'tabindex')));
        }
    });
})(jQuery);

enquire.register("screen and (max-width:608px)", {
    match : function() {
        if($("body.scrollto").length > 0){
            window.scrollTo( 0, $(".maincontent").offset().top );
        }
    }
});

enquire.register("screen and (min-width:992px)", {
    match : function() {
        facetMenu( "show" );
    },
    unmatch : function() {
        facetMenu( "hide" );
    }
});

function facetMenu( action ){
    if( action == "show" ){
        $(".menu-collapse-toggle").off("click", facetHandler );
        $(".menu-collapse").show();
    } else {
        $(".menu-collapse-toggle").on("click", facetHandler ).removeClass("menu-open");
        $(".menu-collapse").hide();
    }
}

var facetHandler = function(e){
    e.preventDefault();
    $(this).toggleClass("menu-open");
    $(".menu-collapse").toggle();
};

$(document).ready(function(){
    $("html").removeClass("no-js").addClass("js");
    $(".close").click(function(){
        window.close();
    });
    $(".focus").focus();
    $(".js-show").show();
    $(".js-hide").hide();

    if( $(window).width() < 991 ){
        facetMenu("hide");
    }

    // clear the basket when user logs out
    $("#logout").click(function(){
        var nameCookie = "bib_list";
        var valCookie = readCookie(nameCookie);
        if (valCookie) { // basket has contents
            updateBasket(0,null);
            delCookie(nameCookie);
            return true;
        } else {
            return true;
        }
    });

    $(".loginModal-trigger").on("click",function(e){
        e.preventDefault();
        var button = $(this);
        var context = button.data('return');
        if ( context ) {
            let return_url = window.location.pathname;
            let params = window.location.search;
            var tab = button.data('tab');
            if ( tab ) {
                params = params ? params + '&tab=' + tab : '?tab=' + tab;
            }
            return_url += params;
            $('#modalAuth').append('<input type="hidden" name="return" value="'+return_url+'" />');
        }
        $("#loginModal").modal("show");
    });
    $("#loginModal").on("shown.bs.modal", function(){
        $("#muserid").focus();
    });

    $("#scrolltocontent").click(function() {
        var content = $(".maincontent");
        if (content.length > 0) {
            $('html,body').animate({
                scrollTop: content.first().offset().top
            },
            'slow');
            content.first().find(':focusable').eq(0).focus();
        }
    });

    $('[data-toggle="tooltip"]').tooltip();

    /* Scroll back to top button */
    $("body").append('<button id="backtotop" class="btn btn-primary" aria-label="' + __("Back to top") + '"><i class="fa fa-arrow-up" aria-hidden="true" title="' + __("Scroll to the top of the page") + '"></i></button>');
    $("#backtotop").hide();
    $(window).on("scroll", function(){
        if ( $(window).scrollTop() < 300 ) {
            $("#backtotop").fadeOut();
        } else {
            $("#backtotop").fadeIn();
        }
    });
    $("#backtotop").on("click", function(e) {
        e.preventDefault();
        $("html,body").animate({scrollTop: 0}, "slow");
    });
});
