if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
* A namespace for Tags related functions.

$.ajaxSetup({
    url: "/cgi-bin/koha/opac-tags.pl",
    type: "POST",
    dataType: "script"
});
*/
KOHA.Tags = {
    add_tag_button: function (bibnum, tag) {
        var mynewtag = "newtag" + bibnum;
        var mytagid = "#" + mynewtag;
        var mydata = {};
        mydata[mynewtag] = tag;
        mydata["csrf_token"] = $('meta[name="csrf-token"]').attr("content");
        mydata["op"] = "cud-add";
        var response; // AJAX from server will assign value to response.
        $.post(
            "/cgi-bin/koha/opac-tags.pl",
            mydata,
            function (data) {
                // alert("AJAX Response: " + data);
                eval(data);
                // alert("counts: " + response["added"] + response["deleted"] + response["errors"]);
                KOHA.Tags.set_tag_status(
                    mytagid + "_status",
                    KOHA.Tags.common_status(
                        response["added"],
                        response["deleted"],
                        response["errors"]
                    )
                );
                if (response.alerts) {
                    alert(response.alerts.join("\n\n"));
                }
            },
            "script"
        );
        return false;
    },
    common_status: function (addcount, delcount, errcount) {
        var cstat = "";
        if (addcount && addcount > 0) {
            cstat += __("Tags added: ") + addcount + ".  ";
        }
        if (delcount && delcount > 0) {
            cstat += __("Tags deleted: ") + delcount + ".  ";
        }
        if (errcount && errcount > 0) {
            cstat += __("Errors: ") + errcount + ". ";
        }
        return cstat;
    },
    set_tag_status: function (tagid, newstatus) {
        $(tagid).html(newstatus);
        $(tagid).show();
    },
    append_tag_status: function (tagid, newstatus) {
        $(tagid).append(newstatus);
        $(tagid).show();
    },
    clear_all_tag_status: function () {
        $(".tagstatus").empty().hide();
    },

    tag_message: {
        tagsdisabled: function (arg) {
            return __("Sorry, tags are not enabled on this system.");
        },
        scrubbed_all_bad: function (arg) {
            return __(
                "Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text."
            );
        },
        badparam: function (arg) {
            return __("Error! Illegal parameter") + " " + arg;
        },
        scrubbed: function (arg) {
            return (
                __(
                    "Note: your tag contained markup code that was removed. The tag was added as "
                ) +
                " " +
                arg
            );
        },
        failed_add_tag: function (arg) {
            return (
                __("Error! Adding tags failed at") +
                " '" +
                arg +
                "'. \n" +
                __(
                    "Note: you can only tag an item with a given term once.  Check 'Tags' to see your current tags."
                )
            );
        },
        failed_delete: function (arg) {
            return (
                __("Error! You cannot delete the tag") +
                " '" +
                arg +
                "'. \n" +
                __("Note: you can only delete your own tags.")
            );
        },
        login: function (arg) {
            return __("You must be logged in to add tags.");
        },
    },

    // Used to tag multiple items at once.  The main difference
    // is that status is displayed on a per item basis.
    add_multitags_button: function (bibarray, tag) {
        var mydata = {};
        for (var i = 0; i < bibarray.length; i++) {
            var mynewtag = "newtag" + bibarray[i];
            mydata[mynewtag] = tag;
        }
        mydata["csrf_token"] = $('meta[name="csrf-token"]').attr("content");
        mydata["op"] = "cud-add";
        var response; // AJAX from server will assign value to response.
        $.post(
            "/cgi-bin/koha/opac-tags.pl",
            mydata,
            function (data) {
                eval(data);
                KOHA.Tags.clear_all_tag_status();
                var bibErrors = false;

                // Display the status for each tagged bib
                for (var i = 0; i < bibarray.length; i++) {
                    var bib = bibarray[i];
                    var mytagid = "#newtag" + bib;
                    var status = "";

                    // Number of tags added.
                    if (response[bib]) {
                        var added = response[bib]["added"];
                        if (added > 0) {
                            status = __("Tags added: ") + added + ".  ";
                            KOHA.Tags.set_tag_status(
                                mytagid + "_status",
                                status
                            );
                        }

                        // Show a link that opens an error dialog, if necessary.
                        var errors = response[bib]["errors"];
                        if (errors.length > 0) {
                            bibErrors = true;
                            var errid = "tagerr_" + bib;
                            var errstat =
                                '<a id="' +
                                errid +
                                '" class="tagerror" href="#">';
                            errstat += __("Errors: ") + errors.length + ". ";
                            errstat += "</a>";
                            KOHA.Tags.append_tag_status(
                                mytagid + "_status",
                                errstat
                            );
                            var errmsg = "";
                            for (var e = 0; e < errors.length; e++) {
                                if (e) {
                                    errmsg += "\n\n";
                                }
                                errmsg += errors[e];
                            }
                            $("#" + errid).click(function () {
                                alert(errmsg);
                            });
                        }
                    }
                }

                if (bibErrors || response["global_errors"]) {
                    var msg = "";
                    if (bibErrors) {
                        msg = __("Unable to add one or more tags.");
                    }

                    // Show global errors in a dialog.
                    if (response["global_errors"]) {
                        var global_errors = response["global_errors"];
                        var msg;
                        for (var e = 0; e < global_errors.length; e++) {
                            msg += "\n\n";
                            msg += response.alerts[global_errors[e]];
                        }
                    }
                    alert(msg);
                }
            },
            "script"
        );
        return false;
    },
};
