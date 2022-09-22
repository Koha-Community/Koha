/* global dataTablesDefaults allColumns Cookies */
// Set expiration date for cookies
var date = new Date();
date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));

function guess_nb_cols() {
    // This is a bit ugly, we are trying to know if there are checkboxes in the first column of the table
    if ( $("#itemst tr:first th:first").html() == "" ) {
        // First header is empty, it's a checkbox
        return 3;
    } else {
        // First header is not empty, there are no checkboxes
        return 2;
    }
}

function hideColumns() {
    var valCookie = Cookies.get("showColumns");
    var nb_cols = guess_nb_cols();
    if (valCookie) {
        valCookie = valCookie.split("/");
        $("#showall").prop("checked", false).parent().removeClass("selected");
        for ( var i = 0; i < valCookie.length; i++ ) {
            if (valCookie[i] !== '') {
                var index = valCookie[i] - nb_cols;
                $("#itemst td:nth-child(" + valCookie[i] + "),#itemst th:nth-child(" + valCookie[i] + ")").toggle();
                $("#checkheader" + index).prop("checked", false).parent().removeClass("selected");
            }
        }
    }
}

function hideColumn(num) {
    $("#hideall,#showall").prop("checked", false).parent().removeClass("selected");
    var nb_cols = guess_nb_cols();
    var valCookie = Cookies.get("showColumns");
    // set the index of the table column to hide
    $("#" + num).parent().removeClass("selected");
    var hide = Number(num.replace("checkheader", "")) + nb_cols;
    // hide header and cells matching the index
    $("#itemst td:nth-child(" + hide + "),#itemst th:nth-child(" + hide + ")").toggle();
    // set or modify cookie with the hidden column's index
    if (valCookie) {
        valCookie = valCookie.split("/");
        var found = false;
        for ( var i = 0; i < valCookie.length; i++ ) {
            if (hide == valCookie[i]) {
                found = true;
                break;
            }
        }
        if (!found) {
            valCookie.push(hide);
            var cookieString = valCookie.join("/");
            Cookies.set("showColumns", cookieString, { expires: date, path: '/', sameSite: 'Lax'  });
        }
    } else {
        Cookies.set("showColumns", hide, { expires: date, path: '/', sameSite: 'Lax'  });
    }
}

// Array Remove - By John Resig (MIT Licensed)
// http://ejohn.org/blog/javascript-array-remove/
Array.prototype.remove = function (from, to) {
    var rest = this.slice((to || from) + 1 || this.length);
    this.length = from < 0 ? this.length + from : from;
    return this.push.apply(this, rest);
};

function showColumn(num) {
    $("#hideall").prop("checked", false).parent().removeClass("selected");
    $("#" + num).parent().addClass("selected");
    var valCookie = Cookies.get("showColumns");
    // set the index of the table column to hide
    var nb_cols = guess_nb_cols();
    var show = Number(num.replace("checkheader", "")) + nb_cols;
    // hide header and cells matching the index
    $("#itemst td:nth-child(" + show + "),#itemst th:nth-child(" + show + ")").toggle();
    // set or modify cookie with the hidden column's index
    if (valCookie) {
        valCookie = valCookie.split("/");
        var found = false;
        for ( var i = 0; i < valCookie.length; i++ ) {
            if (show == valCookie[i]) {
                valCookie.remove(i);
                found = true;
            }
        }
        if (found) {
            var cookieString = valCookie.join("/");
            Cookies.set("showColumns", cookieString, { expires: date, path: '/', sameSite: 'Lax'  });
        }
    }
}

function showAllColumns() {
    var nb_cols = guess_nb_cols();
    $("#selections input:checkbox").each(function () {
        $(this).prop("checked", true);
    });
    $("#selections span").addClass("selected");
    $("#itemst td:nth-child("+nb_cols+"),#itemst tr th:nth-child("+nb_cols+")").nextAll().show();
    Cookies.remove("showColumns", { path: '/' });
    $("#hideall").prop("checked", false).parent().removeClass("selected");
}

function hideAllColumns() {
    var nb_cols = guess_nb_cols();
    $("#selections input:checkbox").each(function () {
        $(this).prop("checked", false);
    });
    $("#selections span").removeClass("selected");
    $("#itemst td:nth-child("+nb_cols+"),#itemst tr th:nth-child("+nb_cols+")").nextAll().hide();
    $("#hideall").prop("checked", true).parent().addClass("selected");
    var cookieString = allColumns.join("/");
    Cookies.set("showColumns", cookieString, { expires: date, path: '/', sameSite: 'Lax'  });
}

$(document).ready(function () {
    hideColumns();
    $("#itemst").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "aTargets": [0, 1], "bSortable": false, "bSearchable": false },
            { "aTargets": [0], "bVisible": false },
            { "sType": "anti-the", "aTargets": ["anti-the"] }
        ],
        "bPaginate": false,
    }));
    // Highlight in yellow item rows that cannot be deleted
    $(".error").parents('tr').find('td').css('background-color', '#ffff99');

    $("#selectallbutton").click(function (e) {
        e.preventDefault();
        $("#itemst input:checkbox").each(function () {
            $(this).prop("checked", true);
        });
    });
    $("#clearallbutton").click(function (e) {
        e.preventDefault();
        $("#itemst input:checkbox").each(function () {
            $(this).prop("checked", false);
        });
    });
    $("#clearonloanbutton").click(function () {
        $("#itemst input[name='itemnumber'][data-is-onloan='1']").each(function () {
            $(this).prop('checked', false);
        });
        return false;
    });
    $("#selections input").change(function (e) {
        var num = $(this).attr("id");
        if (num == 'showall') {
            showAllColumns();
            e.stopPropagation();
        } else if (num == 'hideall') {
            hideAllColumns();
            e.stopPropagation();
        } else {
            if ($(this).prop("checked")) {
                showColumn(num);
            } else {
                hideColumn(num);
            }
        }
    });
});
