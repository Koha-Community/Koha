$(document).ready(function () {
    $("#cashupSummaryModal").on("show.bs.modal", function (e) {
        var button = $(e.relatedTarget);
        var cashup = button.data("cashup");
        var description = button.data("register");
        var summary_modal = $(this);
        summary_modal.find("#register_description").text(description);
        $.ajax({
            url: "/api/v1/cashups/" + cashup,
            headers: {
                "x-koha-embed": "summary",
            },
            async: false,
            success: function (data) {
                let from_date = $datetime(data.summary.from_date);
                summary_modal.find("#from_date").text(from_date);
                let to_date = $datetime(data.summary.to_date);
                summary_modal.find("#to_date").text(to_date);

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

                // 1. Total (sum of all transactions)
                tfoot.append(
                    "<tr class='total-row'><td><strong>Total</strong></td><td><strong>" +
                        data.summary.total.format_price() +
                        "</strong></td></tr>"
                );

                // Add separator line
                tfoot.append(
                    "<tr class='reconciliation-separator'><td colspan='2'><hr></td></tr>"
                );

                // 2. Cash collected (amount recorded as removed from register)
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
                    tfoot.append(
                        "<tr><td><strong>Cash collected</strong></td><td><strong>" +
                            cashCollected.format_price() +
                            "</strong></td></tr>"
                    );
                }

                // 3. Other payment types collected (excluding CASH)
                for (type of data.summary.total_grouped) {
                    if (
                        type.total !== 0 &&
                        type.payment_type !== "Cash" &&
                        type.payment_type !== "CASH"
                    ) {
                        tfoot.append(
                            "<tr><td><strong>" +
                                escape_str(type.payment_type) +
                                " collected" +
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
                        reconciliationLabel = "Cashup surplus";
                        reconciliationAmount =
                            "+" + Math.abs(surplus).format_price();
                        reconciliationNote = data.summary.surplus_note;
                    } else if (deficit) {
                        reconciliationClass =
                            "reconciliation-result text-danger";
                        reconciliationLabel = "Cashup deficit";
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
                        tfoot.append(
                            "<tr class='" +
                                reconciliationClass +
                                "'><td colspan='2'><em>" +
                                __("Note:") +
                                " " +
                                escape_str(reconciliationNote) +
                                "</em></td></tr>"
                        );
                    }
                }
            },
        });
    });
});
