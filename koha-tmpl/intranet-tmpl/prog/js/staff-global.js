/* global shortcut delBasket AUDIO_ALERT_PATH Cookies */
/* exported addBibToContext delBibToContext escape_str escape_price openWindow _ removeFocus toUC confirmDelete confirmClone playSound */
if (KOHA === undefined) var KOHA = {};

function _(s) {
    return s;
} // dummy function for gettext

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function () {
    return formatstr(this, arguments);
};
function formatstr(str, col) {
    col =
        typeof col === "object"
            ? col
            : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") {
            return "%";
        }
        if (m == "%s") {
            return col[idx++];
        }
        return col[n];
    });
}

var HtmlCharsToEscape = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
};
String.prototype.escapeHtml = function () {
    return this.replace(/[&<>]/g, function (c) {
        return HtmlCharsToEscape[c] || c;
    });
};
function escape_str(s) {
    return s != null ? s.escapeHtml() : "";
}

/*
 * Void method for numbers, for consistency
 */
Number.prototype.escapeHtml = function () {
    return this;
};
function escape_price(p) {
    return p != null ? p.escapeHtml().format_price() : "";
}

// http://stackoverflow.com/questions/14859281/select-tab-by-name-in-jquery-ui-1-10-0/16550804#16550804
$.fn.tabIndex = function () {
    return $(this).parent().children("div").index(this);
};
$.fn.selectTabByID = function (tabID) {
    $("a[href='" + tabID + "']", $(this)).tab("show");
};

$(document).ready(function () {
    //check if sticky element is stuck, if so add floating class
    if ( $('.sticky').length ) {
      const observer = new IntersectionObserver(
        ([e]) => e.target.classList.toggle('floating', e.intersectionRatio < 1),
        {threshold: [1]}
      );

      observer.observe(document.querySelector('.sticky'));
    }

    //check for a hash before setting focus
    let hash = window.location.hash;
    if (!hash) {
        $(".tab-pane.active input:text:first").focus();
    }
    $("#header_search a[data-bs-toggle='tab']").on("shown.bs.tab", function (e) {
        $(e.target.hash).find("input:text:first").focus();
    });

    $(".close, .close_window").on("click", function (e) {
        e.preventDefault();
        window.close();
    });

    $("#checkin_search_panel form").preventDoubleFormSubmit();

    if ($("#header_search #checkin_search_panel").length > 0) {
        shortcut.add("Alt+r", function () {
            $("#header_search").selectTabByID("#checkin_search_panel");
            $("#ret_barcode").focus();
        });
    } else {
        shortcut.add("Alt+r", function () {
            location.href = "/cgi-bin/koha/circ/returns.pl";
        });
    }
    if ($("#header_search #circ_search_panel").length > 0) {
        shortcut.add("Alt+u", function () {
            $("#header_search").selectTabByID("#circ_search_panel");
            $("#findborrower").focus();
        });
    } else {
        shortcut.add("Alt+u", function () {
            location.href = "/cgi-bin/koha/circ/circulation.pl";
        });
    }
    if ($("#header_search #catalog_search_panel").length > 0) {
        shortcut.add("Alt+q", function () {
            $("#header_search").selectTabByID("#catalog_search_panel");
            $("#search-form").focus();
        });
    } else {
        shortcut.add("Alt+q", function () {
            location.href = "/cgi-bin/koha/catalogue/search.pl";
        });
    }
    if ($("#header_search #renew_search_panel").length > 0) {
        shortcut.add("Alt+w", function () {
            $("#header_search").selectTabByID("#renew_search_panel");
            $("#ren_barcode").focus();
        });
    } else {
        shortcut.add("Alt+w", function () {
            location.href = "/cgi-bin/koha/circ/renew.pl";
        });
    }

    $("#header_search .form-extra-content-toggle").on("click", function () {
        const extraContent = $(this)
            .closest("form")
            .find(".form-extra-content");
        if (extraContent.is(":visible")) {
            extraContent.hide();
            $(this).removeClass("extra-content-open");
        } else {
            extraContent.show();
            $(this).addClass("extra-content-open");
        }
    });

    $(".focus:visible").focus();

    $(".validated").each(function () {
        $(this).validate();
    });
    jQuery.validator.addClassRules("decimal", {
        number: true,
    });

    jQuery.validator.addMethod("decimal_rate", function(value, element) {
        return this.optional( element ) || /^[\-]?\d{0,2}(\.\d{0,3})*$/.test( value );
    }, __('Please enter a decimal number in the format: 0.0') );

    jQuery.validator.addClassRules("rate", {
        decimal_rate: true
    });

    $("#logout").on("click", function () {
        logOut();
    });
    $("#helper").on("click", function () {
        openHelp();
        return false;
    });

    $("body").on("keypress", ".noEnterSubmit", function (e) {
        return checkEnter(e);
    });

    $("#header_search .nav-tabs a").on("click",function(){
        var field_index = $(this).parent().index();
        keep_text(field_index);
    });

    $(".toggle_element").on("click", function (e) {
        e.preventDefault();
        $($(this).data("element")).toggle();
    });

    var navmenulist = $("#navmenulist");
    if (navmenulist.length > 0) {
        var path = location.pathname.substring(1);
        var url = window.location.toString();
        var params = "";
        if (url.match(/\?(.+)$/)) {
            params = "?" + RegExp.$1;
        }
        if ($('a[href$="/' + path + params + '"]', navmenulist).length == 0) {
            $('a[href$="/' + path + '"]', navmenulist).addClass("current");
        } else {
            $('a[href$="/' + path + params + '"]', navmenulist).addClass(
                "current"
            );
        }
    }

    $("#catalog-search-link a").on("mouseenter mouseleave", function () {
        $("#catalog-search-dropdown a").toggleClass(
            "catalog-search-dropdown-hover"
        );
    });

    if (
        localStorage.getItem("previousPatrons") ||
        $("#hiddenborrowernumber").val()
    ) {
        var previous_patrons = [];
        if (localStorage.getItem("previousPatrons")) {
            previous_patrons = JSON.parse(
                localStorage.getItem("previousPatrons")
            );
        }

        if ($("#hiddenborrowernumber").val()) {
            // Remove this patron from the list if they are already there
            previous_patrons = previous_patrons.filter(function (p) {
                return p["borrowernumber"] != $("#hiddenborrowernumber").val();
            });

            const previous_patron = {
                borrowernumber: escape_str($("#hiddenborrowernumber").val()),
                name: escape_str($("#hiddenborrowername").val()),
                card: escape_str($("#hiddenborrowercard").val())
            };

            previous_patrons.unshift(previous_patron);
            // Limit to number of patrons specified in showLastPatronCount
            if (previous_patrons.length > showLastPatronCount)
                previous_patrons.pop();
            localStorage.setItem(
                "previousPatrons",
                JSON.stringify(previous_patrons)
            );
        }

        if (previous_patrons.length) {
            let p = previous_patrons[0];
            $("#lastborrowerlink").show();
            $("#lastborrowerlink").prop("title", `${p["name"]} (${p["card"]})`);
            $("#lastborrowerlink").prop(
                "href",
                `/cgi-bin/koha/circ/circulation.pl?borrowernumber=${p["borrowernumber"]}`
            );
            $("#lastborrower-window").css("display", "inline-flex");

            previous_patrons.reverse();
            for (i in previous_patrons) {
                p = previous_patrons[i];
                const el = `<li><a class="dropdown-item" href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=${p["borrowernumber"]}">${p["name"]} (${p["card"]})</a></li>`;
                $("#lastBorrowerList").prepend(el);
            }
        }
    }

    if ($("#hiddenborrowernumber").val()) {
        localStorage.setItem(
            "currentborrowernumber",
            $("#hiddenborrowernumber").val()
        );
    }

    $("#lastborrower-remove").click(function () {
        removeLastBorrower();
        $("#lastborrower-window").hide();
    });

    /* Search results browsing */
    /* forms with action leading to search */
    $("form[action*='search.pl']").submit(function () {
        $('[name^="limit"]').each(function () {
            if ($(this).val() == "") {
                $(this).prop("disabled", "disabled");
            }
        });
        var disabledPrior = false;
        $(".search-term-row").each(function () {
            if (disabledPrior) {
                $(this).find('select[name="op"]').prop("disabled", "disabled");
                disabledPrior = false;
            }
            if ($(this).find('input[name="q"]').val() == "") {
                $(this).find("input").prop("disabled", "disabled");
                $(this).find("select").prop("disabled", "disabled");
                disabledPrior = true;
            }
        });
        resetSearchContext();
        saveOrClearSimpleSearchParams();
    });
    /* any link to launch a search except navigation links */
    $("[href*='search.pl?']")
        .not(".nav")
        .not(".searchwithcontext")
        .click(function () {
            resetSearchContext();
        });
    /* any link to a detail page from the results page. */
    $("#bookbag_form a[href*='detail.pl?']").click(function () {
        resetSearchContext();
    });

    // add back to top button on each staff page
    $("body").append('<button id="backtotop" class="btn btn-default" aria-label="' + __("Back to top") + '"><i class="fa fa-arrow-up" aria-hidden="true"></i></button>');
    $("#backtotop").hide();
    $(window).scroll(function(){
        if ( $(window).scrollTop() < 300 ) {
            $("#backtotop").fadeOut();
        } else {
            $("#backtotop").fadeIn();
        }
    });
    $("#backtotop").click(function(e) {
        e.preventDefault();
        $("html,body").animate({scrollTop: 0}, "slow");
    });

    $("body").on("change", "#set-library-branch", function () {
        var selectedBranch = $("#set-library-branch").val();
        $("#set-library-desk_id")
            .children()
            .each(function () {
                if ($(this).attr("id") === "nodesk") {
                    // set no desk by default, should be first element
                    $(this).prop("selected", true);
                    $(this).prop("disabled", false);
                    $(this).show();
                } else if ( $(this).hasClass(selectedBranch) ) {
                    $("#nodesk").prop("disabled", true); // we have desk, no need for nodesk option
                    $("#nodesk").hide();
                    $(this).prop("disabled", false);
                    $(this).show();
                    if ( selectedBranch == $(".logged-in-branch-code").html() && $(".logged-in-desk-id").length ) {
                        $("#set-library-desk_id").val( $(".logged-in-desk-id").html() );
                    } else {
                        $("#nodesk").hide();
                        $("#set-library-desk_id").val(
                            $("#set-library-desk_id option:not([disabled]):first").val()
                        );
                    }
                } else {
                    $(this).prop("disabled", true);
                    $(this).hide();
                }
            });

        $("#set-library-register_id").val("");
        $("#set-library-register_id").children().each(function() {
            // default to no-register
            if ($(this).is("#noregister")) {
                $(this).prop("selected", true)
            } else if ($(this).hasClass(selectedBranch)) {
                // display branch registers
                $(this).prop("disabled", false);
                $(this).show();
                // default to branch default if there is one
                if ($(this).hasClass("default")) {
                    $(this).prop("selected", true)
                }
            } else {
                // hide non-branch registers
                $(this).hide();
                $(this).prop("disabled", true);
            }
        });
    });

    $("body").on("click", "#setlibrary_panel #cancel_set_library", function(e){
        e.preventDefault();
        $("#setlibrary_panel").removeClass("setlibrary_panel_open").html("").hide();
    });

    $("#branch_select_cog").on("click", function(e){
        e.stopPropagation();
        let setlibrary_panel = $("#setlibrary_panel");
        if( setlibrary_panel.hasClass("setlibrary_panel_open") ){
            setlibrary_panel.removeClass("setlibrary_panel_open").html("").hide();
        } else {
            setlibrary_panel.addClass("setlibrary_panel_open").show();
            $("#setlibrary_panel").load( "/cgi-bin/koha/circ/set-library.pl #set-library-form", function(){
                // setLibraryDeskOptions();
            });
        }
    });

    $("#logged-in-dropdown").on('hidden.bs.dropdown', function () {
        $("#setlibrary_panel").removeClass("setlibrary_panel_open").html("").hide();
    });

    if ( $('[data-bs-toggle="tooltip"]').length ) {
        $('[data-bs-toggle="tooltip"]').tooltip();
    }

});

function removeLastBorrower() {
    localStorage.removeItem("previousPatrons");
}

// http://jennifermadden.com/javascript/stringEnterKeyDetector.html
function checkEnter(e) {
    //e is event object passed from function invocation
    var characterCode; // literal character code will be stored in this variable
    if (e && e.which) {
        //if which property of event object is supported (NN4)
        characterCode = e.which; //character code is contained in NN4's which property
    } else {
        characterCode = e.keyCode; //character code is contained in IE's keyCode property
    }
    if (
        characterCode == 13 && //if generated character code is equal to ascii 13 (if enter key)
        e.target.nodeName == "INPUT" &&
        e.target.type != "submit" // Allow enter to submit using the submit button
    ) {
        return false;
    } else {
        return true;
    }
}

function clearHoldFor() {
    Cookies.remove("holdfor", { path: "/", SameSite: "Lax" });
}

function logOut() {
    if (typeof delBasket == "function") {
        delBasket("main", true);
    }
    clearHoldFor();
    removeLastBorrower();
    localStorage.removeItem("sql_reports_activetab");
    localStorage.removeItem("searches");
    localStorage.removeItem("bibs_selected");
    localStorage.removeItem("patron_search_selections");
    localStorage.removeItem("item_search_selections");
    localStorage.removeItem("copiedPermissions");

    // Remove DataTables states
    Object.keys(localStorage).forEach(k => {if (k.match(/^DataTables_/)) { localStorage.removeItem(k)}});
}

function openHelp() {
    window.open("/cgi-bin/koha/help.pl", "_blank");
}

jQuery.fn.preventDoubleFormSubmit = function () {
    jQuery(this).submit(function () {
        $(
            "body, form input[type='submit'], form button[type='submit'], form a"
        ).addClass("waiting");
        if (this.beenSubmitted) return false;
        else this.beenSubmitted = true;
    });
};

function openWindow(link, name, width, height) {
    name = typeof name == "undefined" ? "popup" : name;
    width = typeof width == "undefined" ? "600" : width;
    height = typeof height == "undefined" ? "400" : height;
    //IE <= 9 can't handle a "name" with whitespace
    try {
        window.open(
            link,
            name,
            "width=" +
                width +
                ",height=" +
                height +
                ",resizable=yes,toolbar=false,scrollbars=yes,top"
        );
    } catch (e) {
        window.open(
            link,
            null,
            "width=" +
                width +
                ",height=" +
                height +
                ",resizable=yes,toolbar=false,scrollbars=yes,top"
        );
    }
}

// Use this function to remove the focus from any element for
// repeated scanning actions on errors so the librarian doesn't
// continue scanning and miss the error.
function removeFocus() {
    $(":focus").blur();
}

function toUC(f) {
    var x = f.value.toUpperCase();
    f.value = x;
    return true;
}

function confirmDelete(message) {
    return confirm(message) ? true : false;
}

function confirmClone(message) {
    return confirm(message) ? true : false;
}

function playSound(sound) {
    if (!(sound.indexOf("http://") === 0 || sound.indexOf("https://") === 0)) {
        sound = AUDIO_ALERT_PATH + sound;
    }
    document.getElementById("audio-alert").innerHTML =
        '<audio src="' +
        sound +
        '" autoplay="autoplay" autobuffer="autobuffer"></audio>';
}

// For keeping the text when navigating the search tabs
function keep_text(clicked_index) {
    var searchboxes = document.getElementsByClassName("head-searchbox");
    var persist = searchboxes[0].value;

    for (var i = 0; i < searchboxes.length - 1; i++) {
        if (searchboxes[i].value != searchboxes[i + 1].value) {
            if (i === searchboxes.length - 2) {
                if (searchboxes[i].value != searchboxes[0].value) {
                    persist = searchboxes[i].value;
                } else if (searchboxes.length === 2) {
                    if (clicked_index === 0) {
                        persist = searchboxes[1].value;
                    }
                } else {
                    persist = searchboxes[i + 1].value;
                }
            } else if (searchboxes[i + 1].value != searchboxes[i + 2].value) {
                persist = searchboxes[i + 1].value;
            }
        }
    }

    for (i = 0; i < searchboxes.length; i++) {
        searchboxes[i].value = persist;
    }
}

// Extends jQuery API
jQuery.extend({
    uniqueArray: function (array) {
        return $.grep(array, function (el, index) {
            return index === $.inArray(el, array);
        });
    },
});

function removeByValue(arr, val) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] == val) {
            arr.splice(i, 1);
            break;
        }
    }
}

function addBibToContext(bibnum) {
    bibnum = parseInt(bibnum, 10);
    var bibnums = getContextBiblioNumbers();
    bibnums.push(bibnum);
    setContextBiblioNumbers(bibnums);
    setContextBiblioNumbers($.uniqueArray(bibnums));
}

function delBibToContext(bibnum) {
    var bibnums = getContextBiblioNumbers();
    removeByValue(bibnums, bibnum);
    setContextBiblioNumbers($.uniqueArray(bibnums));
}

function setContextBiblioNumbers(bibnums) {
    localStorage.setItem("bibs_selected", JSON.stringify(bibnums));
}

function getContextBiblioNumbers() {
    var r = localStorage.getItem("bibs_selected");
    if (r) {
        return JSON.parse(r);
    }
    r = new Array();
    return r;
}

function resetSearchContext() {
    setContextBiblioNumbers(new Array());
}

function saveOrClearSimpleSearchParams() {
    // Simple masthead search - pass value for display on details page
    var pulldown_selection;
    var searchbox_value;
    if ($("#cat-search-block select.advsearch").length) {
        pulldown_selection = $("#cat-search-block select.advsearch").val();
    } else {
        pulldown_selection = "";
    }
    if ($("#cat-search-block #search-form").length) {
        searchbox_value = $("#cat-search-block #search-form").val();
    } else {
        searchbox_value = "";
    }
    localStorage.setItem("cat_search_pulldown_selection", pulldown_selection);
    localStorage.setItem("searchbox_value", searchbox_value);
}

function patron_autocomplete(node, options) {
    let link_to;
    let url_params;
    let on_select_callback;

    if (options) {
        if (options["link-to"]) {
            link_to = options["link-to"];
        }
        if (options["url-params"]) {
            url_params = options["url-params"];
        }
        if (options["on-select-callback"]) {
            on_select_callback = options["on-select-callback"];
        }
    }
    return (node
        .autocomplete({
            source: function (request, response) {
                let q = buildPatronSearchQuery(request.term);

                let params = {
                    _page: 1,
                    _per_page: 10,
                    q: JSON.stringify(q),
                    _order_by: "+me.surname,+me.firstname",
                };
                $.ajax({
                    data: params,
                    type: "GET",
                    url: "/api/v1/patrons",
                    headers: {
                        "x-koha-embed": "library",
                    },
                    success: function (data) {
                        return response(data);
                    },
                    error: function (e) {
                        if (e.state() != "rejected") {
                            alert(
                                __(
                                    "An error occurred. Check the logs for details."
                                )
                            );
                        }
                        return response();
                    },
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
        .data("ui-autocomplete")._renderItem = function (ul, item) {
        if (link_to) {
            item.link =
                link_to == "circ"
                    ? "/cgi-bin/koha/circ/circulation.pl"
                    : link_to == "reserve"
                    ? "/cgi-bin/koha/reserve/request.pl"
                    : "/cgi-bin/koha/members/moremember.pl";
            item.link +=
                (url_params ? "?" + url_params + "&" : "?") +
                "borrowernumber=" +
                item.patron_id;
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
                "" +
                    (item.link ? '<a href="' + item.link + '">' : "<a>") +
                    (item.surname ? item.surname.escapeHtml() : "") +
                    ", " +
                    (item.preferred_name ? item.preferred_name.escapeHtml() : item.firstname ? item.firstname.escapeHtml() : "") +
                    " " +
                    (item.middle_name ? item.middle_name.escapeHtml() : "") +
                    " " +
                    (item.other_name ? "(" + item.other_name.escapeHtml() + ")" : "") +
                    cardnumber.escapeHtml() +
                    " " +
                    (item.date_of_birth
                        ? $date(item.date_of_birth) +
                          '<span class="age_years"> (' +
                          $get_age(item.date_of_birth) +
                          " " +
                          __("years") +
                          ")</span>,"
                        : "") +
                    " " +
                    $format_address(item, {
                        no_line_break: true,
                        include_li: false,
                    }) +
                    " " +
                    (!singleBranchMode
                        ? '<span class="badge ac-library">' +
                          item.library.name.escapeHtml() +
                          "</span>"
                        : "") +
                    (item.expired
                        ? '<span class="badge text-bg-warning">' +
                          __("Expired") +
                          "</span>"
                        : "") +
                    (item.restricted
                        ? '<span class="badge text-bg-danger">' +
                          __("Restricted") +
                          "</span>"
                        : "") +
                    "</a>"
            )
            .appendTo(ul);
    });
}

function expandPatronSearchFields(search_fields) {
    switch (search_fields) {
        case "standard":
            return defaultPatronSearchFields;
            break;
        case "full_address":
            return "streetnumber|streettype|address|address2|city|state|zipcode|country";
            break;
        case "all_emails":
            return "email|emailpro|B_email";
            break;
        case "all_phones":
            return "phone|phonepro|B_phone|altcontactphone|mobile";
            break;
        default:
            return search_fields;
    }
}

/**
 * Build patron search query
 * - term: The full search term input by the user
 * You can then pass a list of options:
 * - search_type: (String) 'contains' or 'starts_with', defaults to defaultPatronSearchMethod (see js_includes.inc)
 * - search_fields: (String) comma-separated list of specific fields, defaults to defaultPatronSearchFields (see js_includes.inc)
 * - extended_attribute_types: (JSON object) contains the patron searchable attribute types to be searched on (see patron-search.inc)
 * - table_prefix: (String) table name to prefix the fields with, defaults to 'me'
 */
function buildPatronSearchQuery(term, options) {
    let q = [];
    let table_prefix;
    let leading_wildcard;
    let search_fields = [];
    let patterns = term.split(/[\s,]+/).filter(function (s) {
        return s.length;
    });

    // Bail if no patterns
    if (patterns.length == 0) {
        return q;
    }

    // Table prefix: If table_prefix options exists, use that
    if (typeof options !== "undefined" && options.table_prefix) {
        table_prefix = options.table_prefix;
        // If not, default to 'me'
    } else {
        table_prefix = "me";
    }

    // Leading wildcard: If search_type option exists, use that
    if (typeof options !== "undefined" && options.search_type) {
        leading_wildcard = options.search_type === "contains" ? "%" : "";
        // If not, use DefaultPatronSearchMethod system preference instead
    } else {
        leading_wildcard = defaultPatronSearchMethod === "contains" ? "%" : "";
    }

    let searched_attribute_fields = [];
    // Search fields: If search_fields option exists, we use that
    if (typeof options !== "undefined" && options.search_fields) {
        expand_fields = expandPatronSearchFields(options.search_fields);
        expand_fields.split("|").forEach(function (field, i) {
            if (field.startsWith("_ATTR_")) {
                let attr_field = field.replace("_ATTR_", "");
                searched_attribute_fields.push(attr_field);
            } else {
                search_fields.push(field);
            }
        });
        // If not, we use DefaultPatronSearchFields system preference instead
    } else {
        search_fields = defaultPatronSearchFields.split("|");
    }

    // Add each pattern for each search field
    let pattern_subquery_and = [];
    patterns.forEach(function (pattern, i) {
        let pattern_subquery_or = [];
        search_fields.forEach(function (field, i) {
            pattern_subquery_or.push({
                [table_prefix + "." + field]: {
                    like: leading_wildcard + pattern + "%",
                },
            });
            if (field == "dateofbirth") {
                try {
                    let d = $date_to_rfc3339(pattern);
                    pattern_subquery_or.push({
                        [table_prefix + "." + field]: d,
                    });
                } catch {
                    // Hide the warning if the date is not correct
                }
            }
        });
        pattern_subquery_and.push(pattern_subquery_or);
    });
    q.push({ "-and": pattern_subquery_and });

    // Add full search term for each search field
    let term_subquery_or = [];
    search_fields.forEach(function (field, i) {
        term_subquery_or.push({
            [table_prefix + "." + field]: {
                like: leading_wildcard + term + "%",
            },
        });
    });
    q.push({ "-or": term_subquery_or });

    // Add each pattern for each extended patron attributes
    if (
        typeof options !== "undefined" &&
        ((options.search_fields == "standard" &&
            options.extended_attribute_types &&
            options.extended_attribute_types.length > 0) ||
            searched_attribute_fields.length > 0) &&
        extendedPatronAttributes
    ) {
        extended_attribute_codes_to_search =
            searched_attribute_fields.length > 0
                ? searched_attribute_fields
                : options.extended_attribute_types;
        extended_attribute_subquery_and = [];
        patterns.forEach(function (pattern, i) {
            let extended_attribute_sub_or = [];
            extended_attribute_sub_or.push({
                "extended_attributes.value": {
                    like: leading_wildcard + pattern + "%",
                },
                "extended_attributes.code": extended_attribute_codes_to_search,
            });
            extended_attribute_subquery_and.push(extended_attribute_sub_or);
        });
        q.push({ "-and": extended_attribute_subquery_and });
    }
    return q;
}

function selectBsTabByHash(tabs_container_id) {
    /* Check for location.hash in the page URL */
    /* If present the location hash will be used to activate the correct tab */
    var hash = document.location.hash;
    if (hash !== "") {
        $("#" + tabs_container_id + ' a[href="' + hash + '"]').tab("show");
    } else {
        $("#" + tabs_container_id + " a:first").tab("show");
    }
}

/**
 * Fades out a Font Awesome icon, fades in a replacement, and back
 * @param {object} element - jQuery object representing the icon's container
 * @param {string} start - The icon which will be temporarily replaced
 * @param {string} replacement - The icon which will be the temporary replacement
 */
function toggleBtnIcon( element, start, replacement ){
    let icon = element.find( "." + start );
    icon.fadeOut( 1000, function(){
        $(this).removeClass( start ).addClass( replacement ).fadeIn( 1000, function(){
            $(this).fadeOut( 1000, function(){
                $(this).removeClass( replacement ).addClass( start ).fadeIn( 1000 );
            });
        });
    });
}
