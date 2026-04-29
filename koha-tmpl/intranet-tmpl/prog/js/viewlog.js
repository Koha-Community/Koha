/**
 * Recursively collect changed entries from a Struct::Diff node.
 * Returns an array of { key, before, after } objects.
 * Nested diffs are flattened with dot-separated keys.
 */
function collectDiffEntries(node, prefix) {
    var entries = [];
    Object.keys(node).forEach(function (key) {
        var change = node[key];
        var fullKey = prefix ? prefix + "." + key : key;
        if ("O" in change || "N" in change) {
            entries.push({ key: fullKey, before: change.O, after: change.N });
        } else if ("A" in change) {
            entries.push({ key: fullKey, before: undefined, after: change.A });
        } else if ("R" in change) {
            entries.push({ key: fullKey, before: change.R, after: undefined });
        } else if ("D" in change) {
            entries = entries.concat(collectDiffEntries(change.D, fullKey));
        }
    });
    return entries;
}

/**
 * Pretty-print a parsed JSON value as nested <ul> markup. Arrays become
 * ordered lists preserving MARC-in-JSON field order; objects render their
 * keys. Used by both the struct-diff renderer and the catalog info renderer.
 */
function fmtJsonValue(v) {
    if (v === undefined || v === null) return "";
    if (typeof v !== "object") return $("<span>").text(String(v)).html();
    if (Array.isArray(v)) {
        var items = v
            .map(function (item) {
                return "<li>" + fmtJsonValue(item) + "</li>";
            })
            .join("");
        return '<ul class="diff-obj">' + items + "</ul>";
    }
    var items = Object.keys(v)
        .map(function (k) {
            return (
                "<li>" +
                $("<span>").text(k).html() +
                ": " +
                fmtJsonValue(v[k]) +
                "</li>"
            );
        })
        .join("");
    return '<ul class="diff-obj">' + items + "</ul>";
}

/**
 * Render the info column for a CATALOGUING or AUTHORITIES log entry.
 * The payload is "biblio <JSON>" or "authority <JSON>" where the JSON
 * is the pre-change (MODIFY) or final (DELETE) state of the record,
 * including a MARC-in-JSON `_marc` key. Returns rendered HTML, or null
 * if the text doesn't look like a record JSON payload (e.g. the bare
 * "biblio" / "authority" prefix logged on ADD).
 */
function renderRecordInfo(raw) {
    if (!raw) return null;
    var match = raw.match(/^(?:biblio|authority)\s+(\{[\s\S]*\})\s*$/);
    if (!match) return null;
    var parsed;
    try {
        parsed = JSON.parse(match[1]);
    } catch (e) {
        return null;
    }
    return '<div class="loginfo-struct">' + fmtJsonValue(parsed) + "</div>";
}

/* global override_labels */

/**
 * Render the info column for a CIRCULATION log entry whose payload is a
 * JSON object containing `forced` and/or `confirmations` arrays of
 * override codes. Returns rendered HTML, or null if the payload doesn't
 * look like a circulation JSON object.
 */
function renderCircInfo(raw) {
    if (!raw) return null;
    var trimmed = raw.replace(/^\s+|\s+$/g, "");
    if (trimmed.charAt(0) !== "{") return null;
    var parsed;
    try {
        parsed = JSON.parse(trimmed);
    } catch (e) {
        return null;
    }
    if (!parsed || typeof parsed !== "object") return null;

    var forced =
        Array.isArray(parsed.forced) && parsed.forced.length
            ? parsed.forced
            : null;
    var confirmations =
        Array.isArray(parsed.confirmations) && parsed.confirmations.length
            ? parsed.confirmations
            : null;
    if (!forced && !confirmations) return null;

    function translate(code) {
        return override_labels[code] || escapeHtml(code);
    }

    var html = "";
    if (forced) {
        html += forced
            .map(function (c) {
                return '<div class="forced">' + translate(c) + "</div>";
            })
            .join("");
    }
    if (confirmations) {
        html += confirmations
            .map(function (c) {
                return '<div class="confirmed">' + translate(c) + "</div>";
            })
            .join("");
    }
    return html;
}

/**
 * Render Struct::Diff JSON as a human-readable before/after table.
 * Falls back to a <pre> block for non-Struct::Diff JSON or plain text.
 */
function renderStructDiff(raw) {
    if (!raw) return "";
    var diff;
    try {
        diff = JSON.parse(raw);
    } catch (e) {
        return $("<pre>").text(raw)[0].outerHTML;
    }
    if (!diff || !diff.D || typeof diff.D !== "object") {
        return $("<pre>").text(raw)[0].outerHTML;
    }

    var entries = collectDiffEntries(diff.D, "");
    if (!entries.length) return "";

    var rows = entries
        .map(function (e) {
            var before =
                e.before !== undefined
                    ? "<del>" + fmtJsonValue(e.before) + "</del>"
                    : "";
            var after =
                e.after !== undefined
                    ? "<ins>" + fmtJsonValue(e.after) + "</ins>"
                    : "";
            return (
                "<tr>" +
                '<td class="diff-key">' +
                $("<span>").text(e.key).html() +
                "</td>" +
                '<td class="diff-before">' +
                before +
                "</td>" +
                '<td class="diff-after">' +
                after +
                "</td>" +
                "</tr>"
            );
        })
        .join("");

    return (
        '<table class="struct-diff">' +
        "<thead><tr>" +
        "<th>" +
        __("Field") +
        "</th>" +
        "<th>" +
        __("Before") +
        "</th>" +
        "<th>" +
        __("After") +
        "</th>" +
        "</tr></thead>" +
        "<tbody>" +
        rows +
        "</tbody>" +
        "</table>"
    );
}

function tickAll(section) {
    $("input[type='checkbox'][name='" + section + "']").prop("checked", true);
    $("#" + section.slice(0, -1) + "ALL").prop("checked", true);
    $("input[type='checkbox'][name='" + section + "']").prop("disabled", true);
    $("#" + section.slice(0, -1) + "ALL").prop("disabled", false);
}

function untickAll(section) {
    $("input[type='checkbox'][name='" + section + "']").prop("checked", false);
    $("input[type='checkbox'][name='" + section + "']").prop("disabled", false);
}

function limitCheckboxes() {
    var limit = 2;
    var compare_link =
        '<a href="#" class="btn btn-link compare_link"><i class="fa fa-columns"></i> ' +
        __("View comparison") +
        "</a>";
    $(document).on("change", ".compare", function () {
        var checked = [];
        $(".compare").each(function () {
            if ($(this).prop("checked")) {
                checked.push($(this).data("actionid"));
            }
        });
        if (checked.length > 0) {
            $("#select_none").removeClass("disabled");
        } else {
            $("#select_none").addClass("disabled");
        }
        if (checked.length == 2) {
            $("a.compare_link").remove();
            $("#compare_info" + checked[0]).prepend(compare_link);
            $("#compare_info" + checked[1]).prepend(compare_link);
            $("button.compare_link").removeClass("disabled");
        } else if (checked.length > limit) {
            humanMsg.displayAlert(
                __("You can select maximum of two checkboxes")
            );
            $(this).prop("checked", false);
        } else if (checked.length < limit) {
            $("a.compare_link").remove();
            $("button.compare_link").addClass("disabled");
        }
    });
}

/* global module_labels action_labels interface_labels */

function escapeHtml(str) {
    if (str == null) return "";
    return $("<span>").text(String(str)).html();
}

function renderObject(data, type, row) {
    var mod = row.module;
    var obj = row.object;
    if (obj == null) return "";

    if (
        mod == "MEMBERS" ||
        mod == "CIRCULATION" ||
        mod == "FINES" ||
        mod == "APIKEYS"
    ) {
        var patron = row.patron;
        var name;
        if (patron && (patron.firstname || patron.surname)) {
            name = escapeHtml(
                [patron.firstname, patron.surname].filter(Boolean).join(" ")
            );
        }
        if (mod == "APIKEYS") {
            var label = name
                ? __("API keys for %s (%s)").format(name, escapeHtml(obj))
                : __("API keys for patron %s").format(escapeHtml(obj));
            return (
                '<a href="/cgi-bin/koha/members/apikeys.pl?patron_id=' +
                encodeURIComponent(obj) +
                '">' +
                label +
                "</a>"
            );
        }
        return (
            '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' +
            encodeURIComponent(obj) +
            '">' +
            (name ? name + " (" + escapeHtml(obj) + ")" : escapeHtml(obj)) +
            "</a>"
        );
    }

    if (mod == "CATALOGUING") {
        var info = row.info || "";
        if (info.substr(0, 6) == "biblio") {
            return (
                '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' +
                encodeURIComponent(obj) +
                '">' +
                __("Bibliographic record %s").format(escapeHtml(obj)) +
                "</a>"
            );
        }
        return escapeHtml(obj);
    }

    if (mod == "SERIAL") {
        return (
            '<a href="/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=' +
            encodeURIComponent(obj) +
            '">' +
            __("Subscription %s").format(escapeHtml(obj)) +
            "</a>"
        );
    }

    if (mod == "AUTHORITIES") {
        return (
            '<a href="/cgi-bin/koha/authorities/detail.pl?authid=' +
            encodeURIComponent(obj) +
            '">' +
            __("Authority %s").format(escapeHtml(obj)) +
            "</a>"
        );
    }

    if (mod == "NOTICES") {
        return escapeHtml(obj);
    }

    if (mod == "ACQUISITIONS" && row.action == "ACQUISITION ORDER" && obj) {
        if (CAN_user_acquisition_order_manage) {
            return __("Basket %s").format(
                '<a href="/cgi-bin/koha/acqui/basket.pl?basketno=' +
                    encodeURIComponent(obj) +
                    '">' +
                    escapeHtml(obj) +
                    "</a>"
            );
        }
        return __("Basket %s").format(escapeHtml(obj));
    }

    if (mod == "SUGGESTION") {
        return (
            '<a href="/cgi-bin/koha/suggestion/suggestion.pl?suggestionid=' +
            encodeURIComponent(obj) +
            '&op=show">' +
            escapeHtml(obj) +
            "</a>"
        );
    }

    return escapeHtml(obj);
}

function renderInfo(data, type, row) {
    var mod = row.module;
    var info = row.info;
    var action_id = row.action_id;

    if (info == null) return "";

    if (mod == "SYSTEMPREFERENCE" || mod == "REPORTS" || mod == "NEWS") {
        var split_info = info.split(" | ");
        var filter_value = escapeHtml(split_info[0]);
        return (
            '<div class="loginfo" id="loginfo' +
            escapeHtml(action_id) +
            '">' +
            escapeHtml(info) +
            "</div>" +
            '<div class="compare_info" id="compare_info' +
            escapeHtml(action_id) +
            '"><label><input type="checkbox" name="diff" id="action_id' +
            escapeHtml(action_id) +
            '" data-actionid="' +
            escapeHtml(action_id) +
            '" data-filter="' +
            filter_value +
            '" class="compare" /> Compare</label></div>'
        );
    }

    if (mod == "NOTICES") {
        return (
            '<div class="loginfo" id="loginfo' +
            escapeHtml(action_id) +
            '">' +
            escapeHtml(info) +
            "</div>" +
            '<div class="compare_info" id="compare_info' +
            escapeHtml(action_id) +
            '"><label><input type="checkbox" name="diff" id="action_id' +
            escapeHtml(action_id) +
            '" data-actionid="' +
            escapeHtml(action_id) +
            '" data-filter="' +
            escapeHtml(row.object || "") +
            '" class="compare" /> Compare</label></div>'
        );
    }

    var body = null;
    if (mod == "CIRCULATION") {
        body = renderCircInfo(info);
    }
    if (body === null) {
        body = renderRecordInfo(info);
    }
    if (body === null) {
        body = escapeHtml(info);
    }
    return (
        '<div class="loginfo" id="loginfo' +
        escapeHtml(action_id) +
        '">' +
        body +
        "</div>"
    );
}

function buildApiFilters(params) {
    var filters = {};

    if (params.user) {
        filters.user = params.user;
    }

    if (params.object) {
        filters.object = params.object;
    }

    if (params.info) {
        filters.info = { like: "%" + params.info + "%" };
    }

    if (params.modules && params.modules.length > 0) {
        var non_empty = params.modules.filter(function (m) {
            return m !== "";
        });
        if (non_empty.length > 0) {
            filters.module = non_empty;
        }
    }

    if (params.actions && params.actions.length > 0) {
        var non_empty_actions = params.actions.filter(function (a) {
            return a !== "";
        });
        if (non_empty_actions.length > 0) {
            // Circulation uses RENEWAL, but Patrons uses RENEW
            if (non_empty_actions.indexOf("RENEW") !== -1) {
                non_empty_actions.push("RENEWAL");
            }
            filters.action = non_empty_actions;
        }
    }

    if (params.interfaces && params.interfaces.length > 0) {
        var non_empty_ifaces = params.interfaces.filter(function (i) {
            return i !== "";
        });
        if (non_empty_ifaces.length > 0) {
            filters.interface = non_empty_ifaces;
        }
    }

    // Flatpickr always submits dates in YYYY-MM-DD format (dateFormat: "Y-m-d")
    if (params.datefrom && params.dateto) {
        filters.timestamp = {
            ">=": params.datefrom + "T00:00:00Z",
            "<=": params.dateto + "T23:59:59Z",
        };
    } else if (params.datefrom) {
        filters.timestamp = {
            ">=": params.datefrom + "T00:00:00Z",
        };
    } else if (params.dateto) {
        filters.timestamp = {
            "<=": params.dateto + "T23:59:59Z",
        };
    }

    return filters;
}

$(document).ready(function () {
    limitCheckboxes();

    if ($('input[type="checkbox"][name="modules"]:checked').length == 0) {
        tickAll("modules");
    }
    $("#moduleALL").change(function () {
        if (this.checked == true) {
            tickAll("modules");
        } else {
            untickAll("modules");
        }
    });
    $("input[type='checkbox'][name='modules']").change(function () {
        if (
            $("input[name='modules']:checked").length ==
            $("input[name='modules']").length - 1
        ) {
            tickAll("modules");
        }
    });

    if ($('input[name="actions"]:checked').length == 0) {
        tickAll("actions");
    }
    $("#actionALL").change(function () {
        if (this.checked == true) {
            tickAll("actions");
        } else {
            untickAll("actions");
        }
    });
    $("input[name='actions']").change(function () {
        if (
            $("input[name='actions']:checked").length ==
            $("input[name='actions']").length - 1
        ) {
            tickAll("actions");
        }
    });

    if ($('input[name="interfaces"]:checked').length == 0) {
        tickAll("interfaces");
    }
    $("#interfaceALL").change(function () {
        if (this.checked == true) {
            tickAll("interfaces");
        } else {
            untickAll("interfaces");
        }
    });
    $("input[name='interfaces']").change(function () {
        if (
            $("input[name='interfaces']:checked").length ==
            $("input[name='interfaces']").length - 1
        ) {
            tickAll("interfaces");
        }
    });

    if (do_it && typeof search_params !== "undefined") {
        var api_filters = buildApiFilters(search_params);

        $("#logst").kohaTable(
            {
                ajax: {
                    url: "/api/v1/action_logs",
                },
                embed: ["librarian", "patron"],
                order: [[0, "desc"]],
                pagingType: "full",
                autoWidth: false,
                columns: [
                    {
                        data: "timestamp",
                        title: __("Date"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row) {
                            if (type == "sort" || type == "type") {
                                return data;
                            }
                            return $datetime(data);
                        },
                    },
                    {
                        data: "user",
                        title: __("Librarian"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row) {
                            if (!data) return "";
                            var librarian = row.librarian;
                            var label;
                            if (
                                librarian &&
                                (librarian.firstname || librarian.surname)
                            ) {
                                label =
                                    escapeHtml(
                                        [librarian.firstname, librarian.surname]
                                            .filter(Boolean)
                                            .join(" ")
                                    ) +
                                    " (" +
                                    escapeHtml(data) +
                                    ")";
                            } else {
                                label = escapeHtml(data);
                            }
                            return (
                                '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' +
                                encodeURIComponent(data) +
                                '" title="' +
                                __("Display detail for this librarian") +
                                '">' +
                                label +
                                "</a>"
                            );
                        },
                    },
                    {
                        data: "module",
                        title: __("Module"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row) {
                            return module_labels[data] || escapeHtml(data);
                        },
                    },
                    {
                        data: "action",
                        title: __("Action"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row) {
                            return action_labels[data] || escapeHtml(data);
                        },
                    },
                    {
                        data: "object",
                        title: __("Object"),
                        searchable: true,
                        orderable: true,
                        render: renderObject,
                    },
                    {
                        data: "info",
                        title: __("Info"),
                        searchable: true,
                        orderable: false,
                        render: renderInfo,
                    },
                    {
                        data: "interface",
                        title: __("Interface"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row) {
                            if (!data) return "";
                            return (
                                interface_labels[data.toUpperCase()] ||
                                escapeHtml(data)
                            );
                        },
                    },
                    {
                        data: "diff",
                        title: __("Diff"),
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row) {
                            if (!data) return "";
                            return renderStructDiff(data);
                        },
                    },
                ],
            },
            table_settings,
            0,
            api_filters
        );
    }

    $("body").on("click", ".compare_link", function (e) {
        e.preventDefault();
        if ($(this).hasClass("disabled")) {
            humanMsg.displayAlert(__("You must select two entries to compare"));
        } else {
            var firstid = $(".compare:checked").eq(0).data("actionid");
            var secondid = $(".compare:checked").eq(1).data("actionid");
            var firstvalue = $("#loginfo" + firstid).text();
            var secondvalue = $("#loginfo" + secondid).text();
            var diffs = diffString(secondvalue, firstvalue);
            $("#col1 pre,#col2 pre").html(diffs);
            $("#compareInfo").modal("show");
        }
    });
    $("#compareInfo").on("hidden.bs.modal", function () {
        $("#col1 pre,#col2 pre").html("");
    });

    $("#select_none").on("click", function (e) {
        e.preventDefault();
        $(".compare:checked").prop("checked", false).change();
    });

    patron_autocomplete($("#user"), {
        "on-select-callback": function (event, ui) {
            $("#user").val(ui.item.patron_id);
            return false;
        },
    });

    $(".log-disabled")
        .each(function () {
            if (CAN_user_parameters_manage_sysprefs) {
                let pref = $(this).data("log");
                url =
                    "/cgi-bin/koha/admin/preferences.pl?op=search&searchfield=";
                $(this).wrap(
                    "<a href='" + url + pref + "' target='_blank'></a>"
                );
            }
        })
        .tooltip();
});
