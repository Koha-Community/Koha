/**
 * Cashup Modal JavaScript Module
 * Shared initialization functions for cashup modals across POS register pages
 */

/**
 * Initialize trigger cashup modal behavior
 * @param {string} modalSelector - jQuery selector for the modal (e.g., '#triggerCashupModal')
 * @param {object} options - Configuration options
 * @param {number} options.registerFloat - Starting float amount (for register.tt)
 * @param {number} options.bankableAmount - Bankable amount (for register.tt)
 */
function initTriggerCashupModal(modalSelector, options) {
    options = options || {};

    $(modalSelector).on("shown.bs.modal", function (e) {
        var button = $(e.relatedTarget);
        var modal = $(this);

        // Get data from button (for registers.tt) or options (for register.tt)
        var register = button.data("register");
        var bankable = button.data("bankable");
        var rfloat = button.data("float");
        var rid = button.data("registerid");

        // For register.tt, use options if provided
        if (options.bankableAmount !== undefined) {
            bankable = options.bankableAmount;
        }
        if (options.registerFloat !== undefined) {
            rfloat = options.registerFloat;
        }

        // Populate register description if available
        if (register) {
            modal.find(".register-description").text(register);
        }

        // Set register ID if available
        if (rid) {
            modal.find(".register-id-field").val(rid);
        }

        // Guard against undefined/null bankable value
        if (bankable === undefined || bankable === null) {
            console.error("Bankable amount is undefined");
            return;
        }

        // Parse bankable amount (remove currency formatting, keep minus sign)
        var bankableAmount = String(bankable).replace(/[^0-9.-]/g, "");
        var numericAmount = parseFloat(bankableAmount);
        var isNegative = numericAmount < 0;

        // Format amounts for display
        var absAmountFormatted = Math.abs(numericAmount).format_price();
        var floatFormatted = rfloat;
        if (typeof rfloat === "number") {
            floatFormatted = rfloat.format_price();
        }

        // Update Start cashup instructions
        var startInstructions;
        if (isNegative) {
            startInstructions =
                "<li>" +
                __("Count cash in the register") +
                "</li>" +
                "<li>" +
                __("The register can continue operating during counting") +
                "</li>" +
                "<li>" +
                __("Complete the cashup by adding cash to restore the float") +
                "</li>";
        } else {
            startInstructions =
                "<li>" +
                __("Remove cash from the register for counting") +
                "</li>" +
                "<li>" +
                __("The register can continue operating during counting") +
                "</li>" +
                "<li>" +
                __("Complete the cashup once counted") +
                "</li>";
        }
        modal.find(".start-cashup-instructions").html(startInstructions);

        // Update Quick cashup instructions
        var quickInstructions;
        if (isNegative) {
            quickInstructions =
                "<li>" +
                __("Top up the register with %s to restore the float").format(
                    absAmountFormatted
                ) +
                "</li>";
        } else {
            quickInstructions =
                "<li>" +
                __(
                    "Confirm you have removed %s cash from the register to bank immediately"
                ).format(absAmountFormatted) +
                "</li>";
        }
        modal.find(".quick-cashup-instructions").html(quickInstructions);

        // Update float reminder
        var floatReminder;
        if (isNegative) {
            floatReminder = __(
                "This will bring the register back to the expected float of <strong>%s</strong>"
            ).format(floatFormatted);
        } else {
            floatReminder = __(
                "Remember to leave the float amount of <strong>%s</strong> in the register."
            ).format(floatFormatted);
        }
        modal.find(".float-reminder-text").html(floatReminder);

        // Store bankable amount for quick cashup (with sign)
        modal.data("bankable-amount", bankableAmount);
    });

    // Handle Quick cashup button click
    $(modalSelector + " .quick-cashup-btn").on("click", function (e) {
        e.preventDefault();
        var form = $(this).closest("form");

        // Change operation to cud-cashup. The controller will build a
        // balanced per-payment-type reconciliations array from the register's
        // expected totals because no actual_amount_* fields are present.
        form.find('input[name="op"]').val("cud-cashup");

        form.submit();
    });
}

/**
 * Initialize confirm cashup modal behavior with reconciliation calculation
 * @param {string} modalSelector - jQuery selector for the modal (e.g., '#confirmCashupModal')
 * @param {object} options - Configuration options
 * @param {boolean} options.noteRequired - Whether reconciliation note is required when there's a discrepancy
 * @param {boolean} options.hasAuthorisedValues - Whether authorized values are configured for notes
 * @param {boolean} options.isInProgress - Whether this is completing an in-progress cashup (for register.tt)
 */
function initConfirmCashupModal(modalSelector, options) {
    options = options || {};
    var noteRequired = options.noteRequired || false;
    var hasAuthorisedValues = options.hasAuthorisedValues || false;
    var isInProgress = options.isInProgress || false;
    var paymentTypes = options.paymentTypes || [];

    // Build the note input for a single row. Each input name carries the
    // payment_type as a suffix (e.g. reconciliation_note_CASH) so that the
    // controller can look each value up by type instead of relying on
    // positional alignment. That means we can disable balanced rows for the
    // proper "not interactive" look without dropping anything from the
    // payload — disabled inputs simply produce no value for that suffix.
    function buildNoteInput(paymentType, noteAvs, label) {
        var inputName = "reconciliation_note_" + paymentType;
        var ariaLabel =
            __("Reconciliation note for") + " " + (label || paymentType);
        if (Array.isArray(noteAvs) && noteAvs.length) {
            var $select = $(
                '<select class="reconciliation-note-input form-select form-select-sm" disabled></select>'
            )
                .attr("name", inputName)
                .attr("aria-label", ariaLabel);
            $select.append(
                '<option value="">' + __("-- Select a reason --") + "</option>"
            );
            noteAvs.forEach(function (av) {
                $("<option></option>")
                    .attr("value", av.value)
                    .text(av.label || av.value)
                    .appendTo($select);
            });
            return $select;
        }
        return $(
            '<input type="text" class="reconciliation-note-input form-control form-control-sm" maxlength="1000" placeholder="" disabled>'
        )
            .attr("name", inputName)
            .attr("aria-label", ariaLabel);
    }

    // Build a single row of the per-payment-type reconciliation table
    function buildRow(pt, noteAvs) {
        var label = pt.label || pt.payment_type;
        var $tr = $('<tr class="cashup-row"></tr>')
            .attr("data-payment-type", pt.payment_type)
            .data("expected", Number(pt.expected || 0));

        $("<td></td>").text(label).appendTo($tr);

        $('<td class="text-end expected-cell"></td>')
            .text(Number(pt.expected || 0).format_price())
            .appendTo($tr);

        $("<td></td>")
            .append(
                $(
                    '<input type="text" inputmode="decimal" pattern="^-?\\d+(\\.\\d{1,2})?$" required="required" data-msg-required="' +
                        __("Required").replace(/"/g, "&quot;") +
                        '" class="cashup-amount-input form-control form-control-sm">'
                )
                    .attr("name", "actual_amount_" + pt.payment_type)
                    .attr("aria-label", __("Actual counted for") + " " + label)
            )
            .appendTo($tr);

        $('<td class="text-end discrepancy-cell"></td>').appendTo($tr);

        $('<td class="note-cell"></td>')
            .append(buildNoteInput(pt.payment_type, noteAvs, label))
            .appendTo($tr);

        return $tr;
    }

    // Render rows for all configured payment types into the modal's tbody
    function renderRows(modal, rowsData) {
        var $tbody = modal.find(".cashup-rows");
        $tbody.empty();
        var noteAvs = modal.data("note-avs") || [];
        if (typeof noteAvs === "string") {
            try {
                noteAvs = JSON.parse(noteAvs);
            } catch (err) {
                noteAvs = [];
            }
        }
        rowsData.forEach(function (pt) {
            $tbody.append(buildRow(pt, noteAvs));
        });
        // Reset totals
        modal.find(".expected-total").text(
            rowsData
                .reduce(function (s, r) {
                    return s + Number(r.expected || 0);
                }, 0)
                .format_price()
        );
        modal.find(".actual-total").text("");
        modal.find(".discrepancy-total").text("");
    }

    // Recalculate per-row discrepancies + totals, show/hide note field
    function recalculate(modal) {
        var anyEntered = false;
        var allEntered = true;
        var anyDiscrepancy = false;
        var totalExpected = 0;
        var totalActual = 0;

        modal.find(".cashup-row").each(function () {
            var $row = $(this);
            var expected = Number($row.data("expected") || 0);
            var actualVal = $row.find(".cashup-amount-input").val();
            var $cell = $row.find(".discrepancy-cell");
            var $note = $row.find(".reconciliation-note-input");

            totalExpected += expected;

            // Reset row state on every recalc — re-applied below if discrepant.
            // Note inputs use suffixed names (reconciliation_note_<TYPE>), so
            // disabling them is safe: the controller looks values up per-type
            // rather than relying on positional alignment between parallel arrays.
            $note
                .prop("disabled", true)
                .attr("disabled", "disabled")
                .removeAttr("required");
            $row.find(".note-cell").removeClass("required");

            if (actualVal === "" || actualVal === undefined) {
                allEntered = false;
                $cell.text("").removeClass("text-warning text-success");
                $note.val("");
                return;
            }

            var actual = parseFloat(actualVal);
            if (isNaN(actual)) {
                allEntered = false;
                $cell.text("").removeClass("text-warning text-success");
                $note.val("");
                return;
            }

            anyEntered = true;
            totalActual += actual;
            var diff = actual - expected;

            if (diff > 0) {
                $cell
                    .text("+" + diff.format_price())
                    .addClass("text-success")
                    .removeClass("text-warning");
                anyDiscrepancy = true;
            } else if (diff < 0) {
                $cell
                    .text(diff.format_price())
                    .addClass("text-warning")
                    .removeClass("text-success");
                anyDiscrepancy = true;
            } else {
                $cell
                    .text(__("Balanced"))
                    .removeClass("text-warning text-success");
                $note.val("");
                return;
            }

            // Discrepant row: enable the note input and apply required when
            // the preference says so.
            $note.prop("disabled", false).removeAttr("disabled");
            if (noteRequired) {
                $note.attr("required", "required");
                $row.find(".note-cell").addClass("required");
            }
        });

        modal.find(".expected-total").text(totalExpected.format_price());
        modal
            .find(".actual-total")
            .text(allEntered ? totalActual.format_price() : "");
        modal
            .find(".discrepancy-total")
            .text(
                allEntered ? (totalActual - totalExpected).format_price() : ""
            );

        if (!anyEntered) {
            modal.find(".reconciliation-display").hide();
            return;
        }

        // Surface a one-line summary
        var summary;
        var summaryClass;
        if (anyDiscrepancy) {
            summary = __("Reconciliation needed - see discrepancies above");
            summaryClass = "warning";
        } else {
            summary = __("Balanced - no surplus or deficit");
            summaryClass = "success";
        }
        modal
            .find(".reconciliation-text")
            .text(summary)
            .removeClass("success warning")
            .addClass(summaryClass);
        modal.find(".reconciliation-display").show();
    }

    // Recalculate on every input
    $(modalSelector).on("input", ".cashup-amount-input", function () {
        recalculate($(this).closest(".modal"));
    });

    // jQuery Validate (loaded via the form's class="validated") aggregates
    // inputs that share a name and only enforces the first one. Our per-row
    // inputs all share name="actual_amount" / name="reconciliation_note", so
    // we must validate every required row ourselves on submit. If any row is
    // missing a required value, block the submit and focus the offender.
    $(modalSelector + " form").on("submit", function (e) {
        var modal = $(this).closest(".modal");
        var $offender = null;
        modal.find(".cashup-row").each(function () {
            var $row = $(this);
            var $amount = $row.find(".cashup-amount-input");
            if ($amount.is(":visible") && !$amount.val()) {
                $offender = $offender || $amount;
                return;
            }
            var $note = $row.find(".reconciliation-note-input");
            if (
                $note.is("[required]") &&
                !$note.prop("disabled") &&
                !$note.val()
            ) {
                $offender = $offender || $note;
            }
        });
        if ($offender) {
            e.preventDefault();
            e.stopImmediatePropagation();
            $offender.trigger("focus");
            try {
                $offender[0].reportValidity();
            } catch (err) {
                /* older browsers may not implement reportValidity */
            }
            return false;
        }
    });

    // Reset/populate modal when opened
    $(modalSelector).on("shown.bs.modal", function (e) {
        var button = $(e.relatedTarget);
        var modal = $(this);

        // Determine the row data:
        // - registers.tt: button supplies per-type breakdown via data-payment-types
        //   (also data-register, data-registerid for the modal title and form field)
        // - register.tt: paymentTypes pre-computed and passed via options
        // - legacy fallback: single Cash row from data-expected
        var rowsData = null;
        if (button.length && button.data("register")) {
            var register = button.data("register");
            modal.find(".register-name").text(register);

            var rid = button.data("registerid");
            modal.find(".register-id-field").val(rid);

            var pt = button.data("payment-types");
            if (Array.isArray(pt) && pt.length) {
                rowsData = pt;
            } else if (pt && typeof pt === "string") {
                try {
                    var parsed = JSON.parse(pt);
                    if (Array.isArray(parsed) && parsed.length) {
                        rowsData = parsed;
                    }
                } catch (err) {
                    /* fall through to legacy */
                }
            }

            if (!rowsData) {
                var expected = button.data("expected");
                var expectedAmount = String(expected || "").replace(
                    /[^0-9.-]/g,
                    ""
                );
                rowsData = [
                    {
                        payment_type: "CASH",
                        label: __("Cash"),
                        expected: parseFloat(expectedAmount) || 0,
                    },
                ];
            }
        }
        if (!rowsData) {
            rowsData = paymentTypes;
        }

        renderRows(modal, rowsData || []);

        modal.find(".reconciliation-display").hide();

        // Focus first input
        modal.find(".cashup-amount-input").first().trigger("focus");
    });
}
