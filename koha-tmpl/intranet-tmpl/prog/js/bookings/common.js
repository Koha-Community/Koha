/* global __ escape_str $date Koha */

/**
 * Shared rendering helpers for the patron and biblio bookings tables,
 * keeping the actions and display consistent across the two displays.
 */
window.BookingsTable = (function () {
    "use strict";

    /**
     * Render the booking status as a coloured badge
     *
     * @param {Object} row - The booking row as returned by the bookings API
     * @returns {string} - Badge markup
     */
    function statusBadge(row) {
        const statusMap = {
            new: () => __("New"),
            cancelled: () =>
                [__("Cancelled"), row.cancellation_reason]
                    .filter(Boolean)
                    .join(": "),
            issued: () => __("Issued"),
            completed: () => __("Completed"),
        };

        const statusText = statusMap[row.status]
            ? statusMap[row.status]()
            : __("Unknown");

        const classMap = [
            { status: __("Cancelled"), class: "bg-secondary" },
            { status: __("Completed"), class: "bg-secondary" },
            { status: __("Issued"), class: "bg-info" },
            { status: __("New"), class: "bg-success" },
        ];

        const badgeClass =
            classMap.find(mapping => statusText.startsWith(mapping.status))
                ?.class || "bg-secondary";

        return `<span class="badge rounded-pill ${badgeClass}">${statusText}</span>`;
    }

    /**
     * Render the Item column; for issued bookings additionally show the
     * checkout due date and a link to the checkout record
     *
     * Requires the 'item.checkout' embed on the API request.
     *
     * @param {Object} row - The booking row as returned by the bookings API
     * @returns {string|null} - Item cell markup, null when no item is assigned
     */
    function itemContent(row) {
        if (!row.item) {
            return null;
        }

        let content = "%s (%s)".format(
            escape_str(row.item.external_id),
            escape_str(row.booking_id)
        );

        if (row.status === "issued" && row.item.checkout) {
            content +=
                '<br/><span class="booking_due_date">%s <a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=%s">%s</a></span>'.format(
                    __("Due:"),
                    encodeURIComponent(row.patron_id),
                    escape_str($date(row.item.checkout.due_date))
                );
        }

        return content;
    }

    /**
     * Render the Actions column: Edit, Cancel, Checkout and Extend gated on
     * booking status and the logged in user's permissions
     *
     * @param {Object} row - The booking row as returned by the bookings API
     * @returns {string} - Action buttons markup
     */
    function actionsContent(row) {
        const permissions = (window.Koha && window.Koha.permissions) || {};
        let actions = "";

        if (row.status === "new") {
            if (permissions.CAN_user_circulate_manage_bookings) {
                actions += `
                    <button type="button" class="btn btn-default btn-xs edit-action"
                        data-bs-toggle="modal"
                        data-bs-target="#placeBookingModal"
                        data-booking="%s"
                        data-biblionumber="%s"
                        data-itemnumber="%s"
                        data-patron="%s"
                        data-pickup_library="%s"
                        data-start_date="%s"
                        data-end_date="%s"
                        data-item_type_id="%s"
                    >
                        <i class="fa fa-pencil" aria-hidden="true"></i> %s
                    </button>
                `.format(
                    escape_str(row.booking_id),
                    escape_str(row.biblio_id),
                    escape_str(row.item_id),
                    escape_str(row.patron_id),
                    escape_str(row.pickup_library_id),
                    escape_str(row.start_date),
                    escape_str(row.end_date),
                    escape_str(row.item?.item_type_id),
                    __("Edit")
                );
                actions += `
                    <button type="button" class="btn btn-default btn-xs cancel-action"
                        data-bs-toggle="modal"
                        data-bs-target="#cancelBookingModal"
                        data-booking="%s"
                    >
                        <i class="fa fa-trash" aria-hidden="true"></i> %s
                    </button>
                `.format(escape_str(row.booking_id), __("Cancel"));
            }

            if (
                permissions.CAN_user_circulate_circulate_remaining_permissions &&
                row.item
            ) {
                const csrf_token = document
                    .querySelector('meta[name="csrf-token"]')
                    ?.getAttribute("content");
                actions += `
                    <form name="booking-checkout" method="post" action="/cgi-bin/koha/circ/circulation.pl?borrowernumber=%s">
                        <input type="hidden" name="csrf_token" value="${csrf_token}" />
                        <input type="hidden" name="op" value="cud-checkout"/>
                        <input type="hidden" name="borrowernumber" value="%s"/>
                        <input type="hidden" name="barcode" value="%s"/>
                        <input type="hidden" name="duedatespec" value="%s"/>
                        <button class="btn btn-default btn-xs checkout-action" type="submit">
                           <i class="fa fa-check-circle" aria-hidden="true"></i> %s
                        </button>
                    </form>
                `.format(
                    escape_str(row.patron_id),
                    escape_str(row.patron_id),
                    escape_str(row.item.external_id),
                    escape_str(row.end_date),
                    __("Checkout")
                );
            }
        }

        return actions;
    }

    /**
     * Highlight new bookings whose collection window has opened (table-info)
     * or passed entirely without collection (table-warning)
     *
     * @param {Object} row - The booking row as returned by the bookings API
     * @param {HTMLElement} node - The tr node for the row
     */
    function highlightRow(row, node) {
        if (row.status !== "new") {
            return;
        }

        const now = new Date();
        if (new Date(row.end_date) < now) {
            node.classList.add("table-warning");
        } else if (new Date(row.start_date) < now) {
            node.classList.add("table-info");
        }
    }

    return {
        statusBadge,
        itemContent,
        actionsContent,
        highlightRow,
    };
})();
