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
        var modal = $(this).closest(".modal");
        var bankableAmount = modal.data("bankable-amount");

        // Change operation to cud-cashup (quick cashup)
        form.find('input[name="op"]').val("cud-cashup");

        // Set the amount to the expected bankable amount
        form.find('input[name="amount"]').val(bankableAmount);

        // Submit the form
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

    // Real-time reconciliation calculation
    $(modalSelector + " .cashup-amount-input").on("input", function () {
        var modal = $(this).closest(".modal");
        var actualAmount = parseFloat($(this).val()) || 0;
        var expectedText = modal.find(".expected-amount").text();
        var expectedAmount = parseFloat(expectedText.unformat_price()) || 0;
        var difference = actualAmount - expectedAmount;

        if ($(this).val() && !isNaN(actualAmount)) {
            var reconciliationText = "";
            var reconciliationClass = "";
            var hasDiscrepancy = false;

            if (difference > 0) {
                reconciliationText = __("Surplus: %s").format(
                    difference.format_price()
                );
                reconciliationClass = "success";
                hasDiscrepancy = true;
            } else if (difference < 0) {
                reconciliationText = __("Deficit: %s").format(
                    Math.abs(difference).format_price()
                );
                reconciliationClass = "warning";
                hasDiscrepancy = true;
            } else {
                reconciliationText = __("Balanced - no surplus or deficit");
                reconciliationClass = "success";
                hasDiscrepancy = false;
            }

            modal
                .find(".reconciliation-text")
                .text(reconciliationText)
                .removeClass("success warning")
                .addClass(reconciliationClass);
            modal.find(".reconciliation-display").show();

            // Show/hide note field based on whether there's a discrepancy
            if (hasDiscrepancy) {
                modal.find(".reconciliation-note-field").show();

                // Update required attribute and label based on system preference
                if (noteRequired) {
                    modal
                        .find(".reconciliation-note-input")
                        .attr("required", "required");
                    modal
                        .find(".reconciliation-note-label")
                        .addClass("required");
                } else {
                    modal
                        .find(".reconciliation-note-input")
                        .removeAttr("required");
                    modal
                        .find(".reconciliation-note-label")
                        .removeClass("required");
                }
            } else {
                modal.find(".reconciliation-note-field").hide();
                modal.find(".reconciliation-note-input").val(""); // Clear note when balanced
                modal.find(".reconciliation-note-input").removeAttr("required");
                modal
                    .find(".reconciliation-note-label")
                    .removeClass("required");
            }
        } else {
            modal.find(".reconciliation-display").hide();
            modal.find(".reconciliation-note-field").hide();
        }
    });

    // Reset/populate modal when opened
    $(modalSelector).on("shown.bs.modal", function (e) {
        var button = $(e.relatedTarget);
        var modal = $(this);

        // For registers.tt: populate from button data
        if (button.length && button.data("register")) {
            var register = button.data("register");
            modal.find(".register-name").text(register);

            var expected = button.data("expected");
            modal.find(".expected-amount").text(expected);

            var rid = button.data("registerid");
            modal.find(".register-id-field").val(rid);

            // Parse expected amount to check if negative
            // Convert to string first in case jQuery's .data() parsed it as a number
            var expectedAmount = String(expected || "").replace(
                /[^0-9.-]/g,
                ""
            );
            var isNegative = parseFloat(expectedAmount) < 0;

            // Update labels based on sign
            if (isNegative) {
                modal
                    .find(".expected-amount-label")
                    .text(__("Expected amount to add:"));
                modal
                    .find(".actual-amount-label")
                    .text(__("Actual amount added to register:"));
            } else {
                modal
                    .find(".expected-amount-label")
                    .text(__("Expected cashup amount:"));
                modal
                    .find(".actual-amount-label")
                    .text(__("Actual cashup amount counted:"));
            }
        }

        // Reset fields
        modal.find(".cashup-amount-input").val("").focus();
        modal.find(".reconciliation-display").hide();
        modal.find(".reconciliation-note-field").hide();
        modal.find(".reconciliation-note-input").val("");
    });
}
