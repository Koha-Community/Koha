/**
 * Utility functions for printing slips from the Vue checkin UI.
 * Each function opens a popup window pointing to the appropriate Koha slip endpoint.
 */

const SLIP_WINDOW_OPTIONS =
    "width=750,height=500,toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes";

export function holdSlipUrl(reserveId) {
    return `/cgi-bin/koha/circ/hold-transfer-slip.pl?reserve_id=${reserveId}`;
}

export function printHoldSlip(reserveId) {
    window.open(holdSlipUrl(reserveId), "slip_window", SLIP_WINDOW_OPTIONS);
}

export function recallSlipUrl(recallId) {
    return `/cgi-bin/koha/recalls/recall_pickup_slip.pl?recall_id=${recallId}`;
}

/**
 * Open an empty slip window. Must be called synchronously from a user gesture
 * so the browser does not block it; load the slip into it later (bug 42505).
 */
export function openSlipWindow() {
    return window.open("", "slip_window", SLIP_WINDOW_OPTIONS);
}

export function printTransferSlip(itemId, branchcode) {
    window.open(
        `/cgi-bin/koha/circ/transfer-slip.pl?transferitem=${itemId}&branchcode=${branchcode}&op=slip`,
        "slip_window",
        SLIP_WINDOW_OPTIONS
    );
}

export function printCheckinSlip(borrowernumber) {
    window.open(
        `/cgi-bin/koha/members/printslip.pl?borrowernumber=${borrowernumber}&print=checkinslip`,
        "slip_window",
        SLIP_WINDOW_OPTIONS
    );
}
