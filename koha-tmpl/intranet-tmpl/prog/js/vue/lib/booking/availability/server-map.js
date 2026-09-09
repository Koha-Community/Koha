/**
 * Server availability map utilities.
 *
 * GET /biblios/{biblio_id}/booking_availability returns
 * `{ item_ids, availability: { 'YYYY-MM-DD': { itemId: cell } } }` where
 * each cell is `{ blockers, confirms, warnings }` (snake_case reason codes
 * to 1) with the edited booking already excluded. `blockers` prevent a new
 * booking; `warnings` are display-only context. These helpers flatten each
 * cell's blocker and warning codes into the client's UnavailableByDate shape
 * (Sets, hyphenated reason tokens) and answer point and range conflict queries.
 *
 * @module availability/server-map
 */

import { toDay } from "../dates.js";

/** Server reason tokens whose client spelling differs */
const SERVER_REASON_MAP = Object.freeze({
    lead_floor: "lead-floor",
    lead_theoretical: "lead-theoretical",
});

/**
 * Reasons that block a specific item on a date. holiday / lead-floor /
 * lead-theoretical are display layers only and must never block an item.
 */
export const CONFLICT_REASONS = Object.freeze([
    "booking",
    "checkout",
    "lead",
    "trail",
]);

/** Reasons that block an item outright for a whole booking period */
export const HARD_CONFLICT_REASONS = Object.freeze(["booking", "checkout"]);

/**
 * Translate the raw endpoint payload into the client map shape.
 * @param {import('../types/bookings.d.ts').BookingAvailabilityResponse|null} availability
 * @returns {import('../types/bookings.d.ts').UnavailableByDate}
 */
export function serverMapToUnavailableByDate(availability) {
    /** @type {import('../types/bookings.d.ts').UnavailableByDate} */
    const map = {};
    if (!availability) return map;

    const byDate = availability.availability;
    if (!byDate) return map;

    // Flatten each cell's blocker and warning codes into one date/item/reason
    // set: blockers drive the disable logic, warnings drive the calendar
    // badges, and downstream queries filter by CONFLICT_REASONS when they only
    // care about blocks. confirms is unused for bookings.
    for (const [date, byItem] of Object.entries(byDate)) {
        const entry = (map[date] ??= {});
        for (const [itemId, cell] of Object.entries(byItem)) {
            const set = (entry[itemId] ??= new Set());
            for (const reason of Object.keys(cell.blockers ?? {})) {
                set.add(SERVER_REASON_MAP[reason] ?? reason);
            }
            for (const reason of Object.keys(cell.warnings ?? {})) {
                set.add(SERVER_REASON_MAP[reason] ?? reason);
            }
        }
    }
    return map;
}

/**
 * @param {Set<string>|undefined} reasonSet
 * @param {readonly string[]} reasons
 * @returns {boolean}
 */
export function setHasAny(reasonSet, reasons) {
    if (!reasonSet) return false;
    return reasons.some(r => reasonSet.has(r));
}

/**
 * Point query: is the date blocked?
 * Single-item mode blocks when the item carries a conflict reason;
 * any-item mode blocks only when every candidate item does.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map
 * @param {string} ymd - YYYY-MM-DD
 * @param {string|null} selectedItem
 * @param {string[]} allItemIds
 * @param {readonly string[]} [reasons]
 * @returns {boolean}
 */
export function dateHasConflict(
    map,
    ymd,
    selectedItem,
    allItemIds,
    reasons = CONFLICT_REASONS
) {
    const entry = map[ymd];
    if (!entry) return false;

    if (selectedItem) {
        return setHasAny(entry[selectedItem], reasons);
    }

    return (
        allItemIds.length > 0 &&
        allItemIds.every(id => setHasAny(entry[id], reasons))
    );
}

/**
 * Range query over [start, end] (inclusive): single-item mode blocks on a
 * conflict on any day; any-item mode blocks when every candidate item has a
 * conflict somewhere in the range (their conflicts need not overlap —
 * no single item can then serve the whole period).
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map
 * @param {Date|import('dayjs').Dayjs|string} startDate
 * @param {Date|import('dayjs').Dayjs|string} endDate
 * @param {string|null} selectedItem
 * @param {string[]} allItemIds
 * @param {readonly string[]} [reasons]
 * @returns {boolean}
 */
export function rangeHasConflict(
    map,
    startDate,
    endDate,
    selectedItem,
    allItemIds,
    reasons = CONFLICT_REASONS
) {
    const start = toDay(startDate);
    const end = toDay(endDate);
    if (!start || !end) {
        // toDay() only returns null for a null/undefined input; anything
        // unparsable already throws there. Treating a missing boundary as
        // "no conflict" would fail open on a booking-conflict check - see
        // addDays/addMonths in dates.js for the same loud-failure contract.
        throw new Error(
            `rangeHasConflict: invalid date range: ${startDate} - ${endDate}`
        );
    }
    if (end.isBefore(start, "day")) return false;

    if (selectedItem) {
        for (
            let d = start.clone();
            !d.isAfter(end, "day");
            d = d.add(1, "day")
        ) {
            const entry = map[d.format("YYYY-MM-DD")];
            if (entry && setHasAny(entry[selectedItem], reasons)) return true;
        }
        return false;
    }

    if (allItemIds.length === 0) return false;
    const itemsWithConflicts = new Set();
    for (let d = start.clone(); !d.isAfter(end, "day"); d = d.add(1, "day")) {
        const entry = map[d.format("YYYY-MM-DD")];
        if (!entry) continue;
        for (const id of allItemIds) {
            if (setHasAny(entry[id], reasons)) itemsWithConflicts.add(id);
        }
        if (itemsWithConflicts.size === allItemIds.length) return true;
    }
    return false;
}

/**
 * Items free of hard conflicts (booking/checkout) across the whole
 * period. Used for "any item" payload construction at submission time:
 * 0 available → error, 1 → auto-assign, 2+ → send itemtype_id.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map
 * @param {Array<import('../types/bookings.d.ts').BookableItem>} bookableItems
 * @param {Date|import('dayjs').Dayjs|string} startDate
 * @param {Date|import('dayjs').Dayjs|string} endDate
 * @returns {Array<import('../types/bookings.d.ts').BookableItem>}
 */
export function itemsAvailableForPeriod(
    map,
    bookableItems,
    startDate,
    endDate
) {
    return bookableItems.filter(
        item =>
            !rangeHasConflict(
                map,
                startDate,
                endDate,
                String(item.item_id),
                [],
                HARD_CONFLICT_REASONS
            )
    );
}
