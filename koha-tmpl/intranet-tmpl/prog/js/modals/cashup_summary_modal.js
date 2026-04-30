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

                // Check for reconciliation (surplus or deficit) from dedicated fields
                var surplus = data.summary.surplus_total;
                var deficit = data.summary.deficit_total;
                var expectedAmount = data.summary.total;
                var actualAmount = data.amount;

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

                // cashCollected = expected cash from session transactions (excludes
                // CASHUP_SURPLUS/DEFICIT). actualAmount = cash recorded at cashup. When
                // they differ we display both so the surplus/deficit row below is the
                // visible difference.
                var cashCollected = null;
                for (type of data.summary.total_grouped) {
                    if (
                        type.payment_type === "Cash" ||
                        type.payment_type === "CASH"
                    ) {
                        cashCollected = type.total;
                        break;
                    }
                }
                if (cashCollected !== null) {
                    var hasReconciliation = !!(surplus || deficit);

                    if (hasReconciliation && !inProgress) {
                        var expectedLabel =
                            cashCollected >= 0
                                ? __("Expected cash total")
                                : __("Expected cash to add to register");
                        tfoot.append(
                            "<tr><td><strong>" +
                                expectedLabel +
                                "</strong></td><td><strong>" +
                                cashCollected.format_price() +
                                "</strong></td></tr>"
                        );

                        var actualLabel =
                            actualAmount >= 0
                                ? __("Cash removed from register")
                                : __("Cash added to register");
                        tfoot.append(
                            "<tr><td><strong>" +
                                actualLabel +
                                "</strong></td><td><strong>" +
                                actualAmount.format_price() +
                                "</strong></td></tr>"
                        );
                    } else {
                        var cashLabel =
                            cashCollected >= 0
                                ? __("Cash removed from register")
                                : __("Cash added to register");

                        tfoot.append(
                            "<tr><td><strong>" +
                                cashLabel +
                                "</strong></td><td><strong>" +
                                cashCollected.format_price() +
                                "</strong></td></tr>"
                        );
                    }
                }

                // 3. Other payment types collected (excluding CASH)
                for (type of data.summary.total_grouped) {
                    if (
                        type.total !== 0 &&
                        type.payment_type !== "Cash" &&
                        type.payment_type !== "CASH"
                    ) {
                        var paymentTypeLabel =
                            type.total >= 0
                                ? __x("{payment_type} collected", {
                                      payment_type: escape_str(
                                          type.payment_type
                                      ),
                                  })
                                : __x("{payment_type} to add", {
                                      payment_type: escape_str(
                                          type.payment_type
                                      ),
                                  });

                        tfoot.append(
                            "<tr><td><strong>" +
                                paymentTypeLabel +
                                "</strong></td><td><strong>" +
                                type.total.format_price() +
                                "</strong></td></tr>"
                        );
                    }
                }

                // 4. Cashup surplus OR deficit (highlighted)
                if (surplus || deficit) {
                    // Add separator before reconciliation
                    tfoot.append(
                        "<tr class='reconciliation-separator'><td colspan='2'><hr></td></tr>"
                    );

                    var reconciliationClass,
                        reconciliationLabel,
                        reconciliationAmount,
                        reconciliationNote;

                    if (surplus) {
                        reconciliationClass =
                            "reconciliation-result text-warning";
                        reconciliationLabel = __("Cashup surplus");
                        reconciliationAmount =
                            "+" + Math.abs(surplus).format_price();
                        reconciliationNote = data.summary.surplus_note;
                    } else if (deficit) {
                        reconciliationClass =
                            "reconciliation-result text-danger";
                        reconciliationLabel = __("Cashup deficit");
                        reconciliationAmount =
                            "-" + Math.abs(deficit).format_price();
                        reconciliationNote = data.summary.deficit_note;
                    }

                    tfoot.append(
                        "<tr class='" +
                            reconciliationClass +
                            "'><td><strong>" +
                            reconciliationLabel +
                            "</strong></td><td><strong>" +
                            reconciliationAmount +
                            "</strong></td></tr>"
                    );

                    // Add note if present
                    if (reconciliationNote) {
                        // Check if note is an authorized value code and use description if available
                        var noteDisplay = reconciliationNote;
                        if (
                            typeof reconciliation_note_avs !== "undefined" &&
                            reconciliation_note_avs[reconciliationNote]
                        ) {
                            noteDisplay =
                                reconciliation_note_avs[reconciliationNote];
                        }

                        tfoot.append(
                            "<tr class='" +
                                reconciliationClass +
                                "'><td colspan='2'><em>" +
                                __("Note:") +
                                " " +
                                escape_str(noteDisplay) +
                                "</em></td></tr>"
                        );
                    }
                }
            },
        });
    });
});
