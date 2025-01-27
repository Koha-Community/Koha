/* global __ */
function holdMultiple() {
    var checkedBiblioNums = ""; // Separated by "/"
    var checkedCount = 0;
    if (document.bookbag_form.biblionumber.length > 0) {
        for (var i = 0; i < document.bookbag_form.biblionumber.length; i++) {
            if (document.bookbag_form.biblionumber[i].checked) {
                checkedBiblioNums +=
                    document.bookbag_form.biblionumber[i].value + "/";
                checkedCount++;
            }
        }
    }

    if (checkedCount > 0) {
        holdBiblioNums(checkedBiblioNums);
    } else {
        alert(__("No item was selected"));
    }
}

function holdBiblioNums(numList) {
    // numList: biblio numbers separated by "/"
    $("#hold_form_biblios").attr("value", numList);
    $("#hold_form").submit();
}

function enableCheckboxActions() {
    // Enable/disable controls if checkboxes are checked
    var checkedBoxes = $(".cb:checked");
    var controls = $(
        ".selections-toolbar .links a, .selections-toolbar .links input, .selections-toolbar .links select, .selections-toolbar .links label, .selections-toolbar .links button"
    );
    if ($(checkedBoxes).size()) {
        $(".selections").html(__("With selected titles: "));
        $(controls).removeClass("disabled");
    } else {
        $(".selections").html(__("Select titles to: "));
        $(controls).addClass("disabled");
    }
}

function cartList() {
    let addtoOption = $("#addto").find("option:selected");
    let addtoval = addtoOption.val();
    if (addtoval == "addtolist") {
        var shelfnumber = addtoOption.attr("id").replace("s", "");
        if (vShelfAdd()) {
            Dopop(
                "/cgi-bin/koha/opac-addbybiblionumber.pl?selectedshelf=" +
                    shelfnumber +
                    "&" +
                    vShelfAdd()
            );
        }
        return false;
    } else if (addtoval == "newlist") {
        if (loggedinusername) {
            if (vShelfAdd()) {
                Dopop(
                    "/cgi-bin/koha/opac-addbybiblionumber.pl?newshelf=1&" +
                        vShelfAdd()
                );
            }
        } else {
            alert(__("You must be logged in to create or add to lists"));
        }
        return false;
    } else if (addtoval == "morelists") {
        if (loggedinusername) {
            if (vShelfAdd()) {
                Dopop("/cgi-bin/koha/opac-addbybiblionumber.pl?" + vShelfAdd());
            }
        } else {
            alert(__("You must be logged in to create or add to lists"));
        }
        return false;
    }
    if (addtoval == "addtocart" || $("#addto").attr("class") == "addtocart") {
        addMultiple();
        return false;
    }
}

function tagSelected() {
    var checkedBoxes = $(".searchresults :checkbox:checked");
    if ($(checkedBoxes).size() == 0) {
        alert(__("No item was selected"));
    } else {
        $("#tagsel_tag").hide();
        $(".resort").hide();
        $("#tagsel_form").show();
    }
}

function tagCanceled() {
    $("#tagsel_form").hide();
    $("#tagsel_tag").show();
    $(".resort").show();
    $("#tagsel_new").val("");
    $("#tagsel_status, .tagstatus").empty().hide();
}

function tagAdded() {
    var checkedBoxes = $(".searchresults :checkbox:checked");
    if ($(checkedBoxes).size() == 0) {
        alert(__("No item was selected"));
        return false;
    }

    var tag = $("#tagsel_new").val();
    if (!tag || tag == "") {
        alert(__("No tag was specified."));
        return false;
    }

    var bibs = [];
    for (var i = 0; i < $(checkedBoxes).size(); i++) {
        var box = $(checkedBoxes).get(i);
        bibs[i] = $(box).val();
    }

    KOHA.Tags.add_multitags_button(bibs, tag);
    return false;
}

$(document).ready(function () {
    $(".cb").click(function () {
        enableCheckboxActions();
    });
    enableCheckboxActions();

    if (opacbookbag == 1 || virtualshelves == 1) {
        if (virtualshelves == 1) {
            $("#addto").on("change", function () {
                cartList();
            });
            $(".addto")
                .find("input:submit")
                .click(function () {
                    cartList();
                    return false;
                });
        } else {
            $("#addto").on("click", function () {
                cartList();
                return false;
            });
        }
    }

    $("#addtocart").on("click", function (e) {
        e.preventDefault();
        addMultiple();
    });

    $(".addtolist").on("click", function (e) {
        e.preventDefault();
        var shelfnumber = $(this).data("shelfnumber");
        var vshelf = vShelfAdd();
        if (vshelf) {
            if ($(this).hasClass("morelists")) {
                Dopop("/cgi-bin/koha/opac-addbybiblionumber.pl?" + vshelf);
            } else if ($(this).hasClass("newlist")) {
                Dopop(
                    "/cgi-bin/koha/opac-addbybiblionumber.pl?newshelf=1&" +
                        vshelf
                );
            } else {
                Dopop(
                    "/cgi-bin/koha/opac-addbybiblionumber.pl?selectedshelf=" +
                        shelfnumber +
                        "&" +
                        vshelf
                );
            }
        }
    });

    $("#CheckAll").on("click", function (e) {
        e.preventDefault();
        $(".cb").prop("checked", true);
        enableCheckboxActions();
    });
    $("#CheckNone").on("click", function (e) {
        e.preventDefault();
        $(".cb").prop("checked", false);
        enableCheckboxActions();
    });

    $(".hold").on("click", function (e) {
        e.preventDefault();
        holdMultiple();
    });

    $("#tagsel_tag")
        .show()
        .click(function () {
            tagSelected();
            return false;
        });
    $("#tagsel_cancel").click(function () {
        tagCanceled();
        return false;
    });
    $("#tagsel_button").click(function () {
        tagAdded();
        return false;
    });

    $(".tag_add").click(function () {
        var thisid = $(this).attr("id");
        thisid = thisid.replace("tag_add", "");
        $(this).addClass("hidden");
        $("#tagform" + thisid).show();
        $("#newtag" + thisid).focus();
        $("#newtag" + thisid + "_status")
            .empty()
            .hide();
        return false;
    });
    $(".cancel_tag_add").click(function () {
        var thisid = $(this).attr("id");
        thisid = thisid.replace("cancel", "");
        $("#tagform" + thisid).hide();
        $("#tag_add" + thisid).removeClass("hidden");
        $("#newtag" + thisid).val("");
        $("#newtag" + thisid + "_status")
            .empty()
            .hide();
        return false;
    });
    $(".tagbutton").click(function () {
        var thisid = $(this).attr("title");
        var tag = $("#newtag" + thisid).val();
        if (!tag || tag == "") {
            alert(__("No tag was specified."));
            return false;
        }
        KOHA.Tags.add_tag_button(thisid, tag);
        return false;
    });
});
