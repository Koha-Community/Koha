/* global shortcut delBasket Sticky AUDIO_ALERT_PATH Cookies */
/* exported addBibToContext delBibToContext escape_str escape_price openWindow _ removeFocus toUC confirmDelete confirmClone playSound */
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
function escape_str(s){
    return s != null ? s.escapeHtml() : "";
}

/*
 * Void method for numbers, for consistency
 */
Number.prototype.escapeHtml = function() {
    return this;
};
function escape_price(p){
    return p != null ? p.escapeHtml().format_price() : "";
}

// http://stackoverflow.com/questions/14859281/select-tab-by-name-in-jquery-ui-1-10-0/16550804#16550804
$.fn.tabIndex = function () {
    return $(this).parent().children('div').index(this);
};
$.fn.selectTabByID = function (tabID) {
    $("a[href='" + tabID + "']", $(this) ).tab("show");
};

$(document).ready(function() {

    //check for a hash before setting focus
    let hash = window.location.hash;
    if ( ! hash ) {
        $(".tab-pane.active input:text:first").focus();
    }
    $("#header_search a[data-toggle='tab']").on("shown.bs.tab", function (e) {
        $( e.target.hash ).find("input:text:first").focus();
    });

    $(".close").click(function(){ window.close(); });

    $("#checkin_search form").preventDoubleFormSubmit();

    if($("#header_search #checkin_search").length > 0){
        shortcut.add('Alt+r',function (){
            $("#header_search").selectTabByID("#checkin_search");
            $("#ret_barcode").focus();
        });
    } else {
        shortcut.add('Alt+r',function (){
            location.href="/cgi-bin/koha/circ/returns.pl"; });
    }
    if($("#header_search #circ_search").length > 0){
        shortcut.add('Alt+u',function (){
            $("#header_search").selectTabByID("#circ_search");
            $("#findborrower").focus();
        });
    } else {
        shortcut.add('Alt+u',function(){ location.href="/cgi-bin/koha/circ/circulation.pl"; });
    }
    if($("#header_search #catalog_search").length > 0){
        shortcut.add('Alt+q',function (){
            $("#header_search").selectTabByID("#catalog_search");
            $("#search-form").focus();
        });
    } else {
        shortcut.add('Alt+q',function(){ location.href="/cgi-bin/koha/catalogue/search.pl"; });
    }
    if($("#header_search #renew_search").length > 0){
        shortcut.add('Alt+w',function (){
            $("#header_search").selectTabByID("#renew_search");
            $("#ren_barcode").focus();
        });
    } else {
        shortcut.add('Alt+w',function(){ location.href="/cgi-bin/koha/circ/renew.pl"; });
    }

    $('#header_search .form-extra-content-toggle').on('click', function () {
        const extraContent = $(this).closest('form').find('.form-extra-content');
        if (extraContent.is(':visible')) {
            extraContent.hide();
        } else {
            extraContent.show();
        }
    });

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
        if (typeof Sticky !== "undefined" && typeof hcSticky === "function") {
            Sticky.hcSticky('update');
        }
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

    $("#catalog-search-link a").on("mouseenter mouseleave", function(){
        $("#catalog-search-dropdown a").toggleClass("catalog-search-dropdown-hover");
    });

    if ( localStorage.getItem("lastborrowernumber") ){
        if( $("#hiddenborrowernumber").val() != localStorage.getItem("lastborrowernumber") ) {
            $("#lastborrowerlink").show();
            $("#lastborrowerlink").prop("title", localStorage.getItem("lastborrowername") + " (" + localStorage.getItem("lastborrowercard") + ")");
            $("#lastborrowerlink").prop("href", "/cgi-bin/koha/circ/circulation.pl?borrowernumber=" + localStorage.getItem("lastborrowernumber"));
            $("#lastborrower-window").css("display", "inline-flex");
        }
    }

    if( !localStorage.getItem("lastborrowernumber") || ( $("#hiddenborrowernumber").val() != localStorage.getItem("lastborrowernumber") && localStorage.getItem("currentborrowernumber") != $("#hiddenborrowernumber").val())) {
        if( $("#hiddenborrowernumber").val() ){
            localStorage.setItem("lastborrowernumber", $("#hiddenborrowernumber").val() );
            localStorage.setItem("lastborrowername", $("#hiddenborrowername").val() );
            localStorage.setItem("lastborrowercard", $("#hiddenborrowercard").val() );
        }
    }

    if( $("#hiddenborrowernumber").val() ){
        localStorage.setItem("currentborrowernumber", $("#hiddenborrowernumber").val() );
    }

    $("#lastborrower-remove").click(function() {
        removeLastBorrower();
        $("#lastborrower-window").hide();
    });

    /* Search results browsing */
    /* forms with action leading to search */
    $("form[action*='search.pl']").submit(function(){
        $('[name^="limit"]').each(function(){
            if( $(this).val() == '' ){
                $(this).prop("disabled","disabled");
            }
        });
        var disabledPrior = false;
        $(".search-term-row").each(function(){
            if( disabledPrior ){
                $(this).find('select[name="op"]').prop("disabled","disabled");
                disabledPrior = false;
            }
            if( $(this).find('input[name="q"]').val() == "" ){
                $(this).find('input').prop("disabled","disabled");
                $(this).find('select').prop("disabled","disabled");
                disabledPrior = true;
            }
        });
        resetSearchContext();
        saveOrClearSimpleSearchParams();
    });
    /* any link to launch a search except navigation links */
    $("[href*='search.pl?']").not(".nav").not('.searchwithcontext').click(function(){
        resetSearchContext();
    });
    /* any link to a detail page from the results page. */
    $("#bookbag_form a[href*='detail.pl?']").click(function(){
        resetSearchContext();
    });

});

function removeLastBorrower(){
    localStorage.removeItem("lastborrowernumber");
    localStorage.removeItem("lastborrowername");
    localStorage.removeItem("lastborrowercard");
    localStorage.removeItem("currentborrowernumber");
}

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

function clearHoldFor(){
    Cookies.remove("holdfor", { path: '/', SameSite: 'Lax' });
}

function logOut(){
    if( typeof delBasket == 'function' ){
        delBasket('main', true);
    }
    clearHoldFor();
    removeLastBorrower();
    localStorage.removeItem("sql_reports_activetab");
    localStorage.removeItem("searches");
    localStorage.removeItem("bibs_selected");
    localStorage.removeItem("patron_search_selections");
}

function openHelp(){
    window.open( "/cgi-bin/koha/help.pl", "_blank");
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
    //IE <= 9 can't handle a "name" with whitespace
    try {
        window.open(link,name,'width='+width+',height='+height+',resizable=yes,toolbar=false,scrollbars=yes,top');
    } catch(e) {
        window.open(link,null,'width='+width+',height='+height+',resizable=yes,toolbar=false,scrollbars=yes,top');
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

    for (var i = 0; i < searchboxes.length - 1; i++) {
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

// Extends jQuery API
jQuery.extend({uniqueArray:function(array){
    return $.grep(array, function(el, index) {
        return index === $.inArray(el, array);
    });
}});

function removeByValue(arr, val) {
    for(var i=0; i<arr.length; i++) {
        if(arr[i] == val) {
            arr.splice(i, 1);
            break;
        }
    }
}

function addBibToContext( bibnum ) {
    bibnum = parseInt(bibnum, 10);
    var bibnums = getContextBiblioNumbers();
    bibnums.push(bibnum);
    setContextBiblioNumbers( bibnums );
    setContextBiblioNumbers( $.uniqueArray( bibnums ) );
}

function delBibToContext( bibnum ) {
    var bibnums = getContextBiblioNumbers();
    removeByValue( bibnums, bibnum );
    setContextBiblioNumbers( $.uniqueArray( bibnums ) );
}

function setContextBiblioNumbers( bibnums ) {
    localStorage.setItem('bibs_selected', JSON.stringify( bibnums ) );
}

function getContextBiblioNumbers() {
    var r = localStorage.getItem('bibs_selected');
    if ( r ) {
        return JSON.parse(r);
    }
    r = new Array();
    return r;
}

function resetSearchContext() {
    setContextBiblioNumbers( new Array() );
}

function saveOrClearSimpleSearchParams() {
    // Simple masthead search - pass value for display on details page
    var pulldown_selection;
    var searchbox_value;
    if( $("#cat-search-block select.advsearch").length ){
        pulldown_selection = $("#cat-search-block select.advsearch").val();
    } else {
        pulldown_selection ="";
    }
    if( $("#cat-search-block #search-form").length ){
        searchbox_value = $("#cat-search-block #search-form").val();
    } else {
        searchbox_value ="";
    }
    localStorage.setItem('cat_search_pulldown_selection', pulldown_selection );
    localStorage.setItem('searchbox_value', searchbox_value );
}

function patron_autocomplete(node, options) {
    let link_to;
    let url_params;
    let on_select_callback;

    if (options) {
        if (options['link-to']) {
            link_to = options['link-to'];
        }
        if (options['url-params']) {
            url_params = options['url-params'];
        }
        if (options['on-select-callback']) {
            on_select_callback = options['on-select-callback'];
        }
    }
    return node.autocomplete({
        source: function (request, response) {
            let q = buildPatronSearchQuery(request.term);

            let params = {
                '_page': 1,
                '_per_page': 10,
                'q': JSON.stringify(q),
                '_order_by': '+me.surname,+me.firstname',
            };
            $.ajax({
                data: params,
                type: 'GET',
                url: '/api/v1/patrons',
                headers: {
                    "x-koha-embed": "library"
                },
                success: function (data) {
                    return response(data);
                },
                error: function (e) {
                    if (e.state() != 'rejected') {
                        alert(__("An error occurred. Check the logs"));
                    }
                    return response();
                }
            });
        },
        minLength: 3,
        select: function (event, ui) {
            if (ui.item.link) {
                window.location.href = ui.item.link;
            } else if (on_select_callback) {
                return on_select_callback(event, ui);
            }
        },
        focus: function (event, ui) {
            event.preventDefault(); // Don't replace the text field
        },
    })
        .data("ui-autocomplete")
        ._renderItem = function (ul, item) {
            if (link_to) {
                item.link = link_to == 'circ'
                    ? "/cgi-bin/koha/circ/circulation.pl"
                    : link_to == 'reserve'
                        ? "/cgi-bin/koha/reserve/request.pl"
                        : "/cgi-bin/koha/members/moremember.pl";
                item.link += (url_params ? '?' + url_params + '&' : "?") + 'borrowernumber=' + item.patron_id;
            } else {
                item.link = null;
            }

            var cardnumber = "";
            if (item.cardnumber != "") {
                // Display card number in parentheses if it exists
                cardnumber = " (" + item.cardnumber + ") ";
            }
            if (item.library_id == loggedInLibrary) {
                loggedInClass = "ac-currentlibrary";
            } else {
                loggedInClass = "";
            }
            return $("<li></li>")
                .addClass(loggedInClass)
                .data("ui-autocomplete-item", item)
                .append(
                    ""
                    + (item.link ? "<a href=\"" + item.link + "\">" : "<a>")
                    + (item.surname ? item.surname.escapeHtml() : "") + ", "
                    + (item.firstname ? item.firstname.escapeHtml() : "")
                    + cardnumber.escapeHtml()
                    + " <small>"
                    + (item.date_of_birth
                        ? $date(item.date_of_birth)
                        + "<span class=\"age_years\"> ("
                        + $get_age(item.date_of_birth)
                        + " "
                        + __("years")
                        + ")</span>,"
                        : ""
                    ) + " "
                    + $format_address(item, { no_line_break: true, include_li: false }) + " "
                    + (!singleBranchMode
                        ?
                        "<span class=\"ac-library\">"
                        + item.library.name.escapeHtml()
                        + "</span>"
                        : "")
                    + "</small>"
                    + "</a>")
                .appendTo(ul);
        };
}


function buildPatronSearchQuery(term) {

    let q = [];
    let leading_wildcard = defaultPatronSearchMethod === 'contains' ? '%' : '';

    // Add each pattern for each search field
    let pattern_subquery_and = [];
    term.split(/[\s,]+/)
        .filter(function (s) { return s.length })
        .forEach(function (pattern, i) {
            let pattern_subquery_or = [];
            defaultPatronSearchFields.split(',').forEach(function (field, i) {
                pattern_subquery_or.push(
                    { ["me." + field]: { 'like': leading_wildcard + pattern + '%' } }
                );
            });
            pattern_subquery_and.push(pattern_subquery_or);
        });
    q.push({ "-and": pattern_subquery_and });

    // Add full search term for each search field
    let term_subquery_or = [];
    defaultPatronSearchFields.split(',').forEach(function (field, i) {
        term_subquery_or.push(
            { ["me." + field]: { 'like': leading_wildcard + term + '%' } }
        );
    });
    q.push({ "-or": term_subquery_or });


    return q;
}
