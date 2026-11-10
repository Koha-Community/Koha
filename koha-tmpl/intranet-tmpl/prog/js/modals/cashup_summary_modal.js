$(document).ready(function () {
    $("#cashupSummaryModal").on("show.bs.modal", function (e) {
        var button = $(e.relatedTarget);
        var cashup = button.data("cashup");
        var description = button.data("register");
        var inProgress = button.data("in-progress") || false;
        var summary_modal = $(this);

        // Update title based on whether this is a preview
        if (inProgress) {
            summary_modal
                .find("#cashupSummaryLabel")
                .text(__("Cashup summary preview"));
        } else {
            summary_modal
                .find("#cashupSummaryLabel")
                .text(__("Cashup summary"));
        }

        summary_modal.find("#register_description").text(description);
        $.ajax({
            url: "/api/v1/cashups/" + cashup,
            headers: {
                "x-koha-embed": "summary",
            },
            success: function (data) {
                let from_date = $datetime(data.summary.from_date);
                summary_modal.find("#from_date").text(from_date);
                let to_date = $datetime(data.summary.to_date);
                summary_modal.find("#to_date").text(to_date);

                // Add preview notice if this is an in-progress cashup
                if (inProgress) {
                    var previewNotice = summary_modal.find(".preview-notice");
                    if (previewNotice.length === 0) {
                        summary_modal
                            .find(".modal-body > ul")
                            .before(
                                '<div class="alert alert-info preview-notice">' +
                                    '<i class="fa-solid fa-info-circle"></i> ' +
                                    "<strong>" +
                                    __("Preview:") +
                                    "</strong> " +
                                    __(
                                        "This summary shows the expected cashup amounts. A reconciliation record may be added when you complete the cashup."
                                    ) +
                                    "</div>"
                            );
                    }
                } else {
                    summary_modal.find(".preview-notice").remove();
                }

                // The presence of any per-type entry in reconciliations_grouped
                // tells us a CASHUP_SURPLUS / CASHUP_DEFICIT line was created
                // for this cashup — equivalent to the old surplus_total /
                // deficit_total scalars.
                var grouped = data.summary.reconciliations_grouped || [];
                var hasReconciliation = grouped.length > 0;
                var expectedAmount = data.summary.total;

                // The CASHUP action's `amount` is the actual total counted
                // across *every* configured payment type, not cash alone —
                // don't use it as "actual cash". Instead derive the cash-only
                // actual as expected-cash + the CASH-specific discrepancy
                // recorded in reconciliations_grouped (there is none when the
                // cashup balanced).
                function actualForPaymentType(expected, paymentType) {
                    var entry = grouped.find(function (g) {
                        return g.payment_type === paymentType;
                    });
                    if (!entry) {
                        return expected;
                    }
                    var difference = entry.surplus_total
                        ? -entry.surplus_total
                        : entry.deficit_total
                          ? -entry.deficit_total
                          : 0;
                    return expected + difference;
                }

                var tbody = summary_modal.find("tbody");
                tbody.empty();
                for (out of data.summary.payout_grouped) {
                    if (out.credit_type_code == "REFUND") {
                        tbody.append(
                            "<tr><td>" +
                                __x(
                                    "{credit_type_description} against {debit_type_description}",
                                    {
                                        credit_type_description: escape_str(
                                            out.credit_type.description
                                        ),
                                        debit_type_description: escape_str(
                                            out.related_debit.debit_type
                                                .description
                                        ),
                                    }
                                ) +
                                "</td><td>- " +
                                out.total.format_price() +
                                "</td></tr>"
                        );
                    } else {
                        tbody.append(
                            "<tr><td>" +
                                escape_str(out.credit_type.description) +
                                "</td><td>- " +
                                out.total.format_price() +
                                "</td></tr>"
                        );
                    }
                }

                for (income of data.summary.income_grouped) {
                    tbody.append(
                        "<tr><td>" +
                            escape_str(income.debit_type.description) +
                            "</td><td>" +
                            income.total.format_price() +
                            "</td></tr>"
                    );
                }

                var tfoot = summary_modal.find("tfoot");
                tfoot.empty();

                // Determine if this is a negative cashup (float deficit scenario)
                var isNegativeCashup = data.summary.total < 0;

                // Add informational notice for negative cashups
                if (isNegativeCashup) {
                    var noticeText = __(
                        "This cashup shows a negative amount because refunds exceeded collections during this session. " +
                            "The register float was topped up to restore the expected balance."
                    );
                    tbody.prepend(
                        "<tr class='reconciliation-info'><td colspan='2'>" +
                            "<i class='fa-solid fa-info-circle'></i> " +
                            "<strong>" +
                            __("Float deficit:") +
                            "</strong> " +
                            noticeText +
                            "</td></tr>"
                    );
                }

                // 1. Total (sum of all transactions)
                var totalLabel = isNegativeCashup
                    ? __("Total float deficit")
                    : __("Total");

                tfoot.append(
                    "<tr class='total-row'><td><strong>" +
                        totalLabel +
                        "</strong></td><td><strong>" +
                        data.summary.total.format_price() +
                        "</strong></td></tr>"
                );

                // Add separator line
                tfoot.append(
                    "<tr class='reconciliation-separator'><td colspan='2'><hr></td></tr>"
                );

                // 2. Payment types, in two groups that together make up the
                // total: those held in the register and reconciled at cashup
                // (CashupPaymentTypes) and everything else that was collected.
                // Each group is a heading row carrying the group total, with
                // the per-type rows indented beneath it.
                var cashedUpRows = [];
                var otherRows = [];
                for (type of data.summary.total_grouped) {
                    var typeLabel = type.label || type.payment_type;
                    if (type.cashed_up) {
                        var expected = type.total;
                        var actual = hasReconciliation
                            ? actualForPaymentType(expected, type.payment_type)
                            : expected;
                        var hasEntry = grouped.some(function (g) {
                            return g.payment_type === type.payment_type;
                        });
                        if (expected === 0 && actual === 0 && !hasEntry) {
                            continue;
                        }
                        cashedUpRows.push({
                            label: typeLabel,
                            amount: actual,
                            expected:
                                hasReconciliation && !inProgress
                                    ? expected
                                    : null,
                        });
                    } else if (type.total !== 0) {
                        otherRows.push({
                            label: typeLabel,
                            amount: type.total,
                            expected: null,
                        });
                    }
                }

                function appendGroup(rows, headings, showDetail) {
                    var groupTotal = rows.reduce(function (sum, r) {
                        return sum + r.amount;
                    }, 0);
                    var heading = groupTotal >= 0 ? headings[0] : headings[1];
                    var detail = showDetail || rows.length > 1;
                    if (rows.length === 1 && !detail) {
                        heading = __x("{heading} ({payment_type})", {
                            heading: heading,
                            payment_type: escape_str(rows[0].label),
                        });
                    }
                    tfoot.append(
                        "<tr class='payment-group'><td><strong>" +
                            heading +
                            "</strong></td><td><strong>" +
                            groupTotal.format_price() +
                            "</strong></td></tr>"
                    );
                    if (!detail) {
                        return;
                    }
                    rows.forEach(function (r) {
                        var rowLabel = escape_str(r.label);
                        if (r.expected !== null && r.expected !== r.amount) {
                            rowLabel = __x(
                                "{payment_type}, expected {amount}",
                                {
                                    payment_type: rowLabel,
                                    amount: r.expected.format_price(),
                                }
                            );
                        }
                        tfoot.append(
                            "<tr class='payment-group-row'><td><span class='ms-4 fw-normal'>" +
                                rowLabel +
                                "</span></td><td><span class='fw-normal'>" +
                                r.amount.format_price() +
                                "</span></td></tr>"
                        );
                    });
                }

                appendGroup(
                    cashedUpRows,
                    [__("Held in register"), __("Paid out of register")],
                    hasReconciliation && !inProgress
                );
                if (otherRows.length > 0) {
                    appendGroup(
                        otherRows,
                        [__("Taken elsewhere"), __("Paid out elsewhere")],
                        false
                    );
                }

                // 4. Per-payment-type cashup surplus / deficit rows.
                if (hasReconciliation) {
                    tfoot.append(
                        "<tr class='reconciliation-separator'><td colspan='2'><hr></td></tr>"
                    );

                    grouped.forEach(function (entry) {
                        var entrySurplus = entry.surplus_total;
                        var entryDeficit = entry.deficit_total;
                        var pt =
                            cashupPaymentTypeLabels.get(entry.payment_type) ||
                            entry.payment_type ||
                            "";
                        var label;
                        var amountText;
                        var rowClass;

                        if (entrySurplus) {
                            rowClass = "reconciliation-result text-warning";
                            label = __x("{payment_type} surplus", {
                                payment_type: escape_str(pt),
                            });
                            amountText =
                                "+" + Math.abs(entrySurplus).format_price();
                        } else if (entryDeficit) {
                            rowClass = "reconciliation-result text-danger";
                            label = __x("{payment_type} deficit", {
                                payment_type: escape_str(pt),
                            });
                            amountText =
                                "-" + Math.abs(entryDeficit).format_price();
                        } else {
                            return;
                        }

                        tfoot.append(
                            "<tr class='" +
                                rowClass +
                                "'><td><strong>" +
                                label +
                                "</strong></td><td><strong>" +
                                amountText +
                                "</strong></td></tr>"
                        );

                        if (entry.note) {
                            var noteDisplay = entry.note;
                            if (
                                typeof reconciliation_note_avs !==
                                    "undefined" &&
                                reconciliation_note_avs[entry.note]
                            ) {
                                noteDisplay =
                                    reconciliation_note_avs[entry.note];
                            }
                            tfoot.append(
                                "<tr class='" +
                                    rowClass +
                                    "'><td colspan='2'><em>" +
                                    __("Note:") +
                                    " " +
                                    escape_str(noteDisplay) +
                                    "</em></td></tr>"
                            );
                        }
                    });
                }
            },
        });
    });
});
