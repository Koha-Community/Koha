/**
 * Booking availability predicate.
 *
 * Decides, from the server availability map, whether a calendar date
 * can be picked in the current selection state (createDisableFunction),
 * where the constrained-range highlight must stop (findFirstBlockingDate)
 * and how far a booking may extend (calculateMaxEndDate).
 *
 * The map arrives with existing bookings' lead/trail windows pre-marked
 * and the edited booking excluded; the draft's own windows are the
 * predicate's half of the bidirectional lead/trail semantics.
 *
 * @module availability/predicate
 */

import { toDay, today as todayDate } from "../dates.js";

export const CONSTRAINT_MODE_END_DATE_ONLY = "end_date_only";
import {
    CONFLICT_REASONS,
    HARD_CONFLICT_REASONS,
    dateHasConflict,
    rangeHasConflict,
    setHasAny,
} from "./server-map.js";

/**
 * Calculate maximum end date based on start date and max period
 * @param {import("dayjs").Dayjs|Date|string} startDate - The start date
 * @param {number} maxPeriod - Maximum booking period in days
 * @returns {import("dayjs").Dayjs} Maximum end date
 */
export function calculateMaxEndDate(startDate, maxPeriod) {
    if (!maxPeriod || maxPeriod <= 0) {
        throw new Error("maxPeriod must be a positive number");
    }

    const start = toDay(startDate);
    // Start date is day 1, so end = start + (maxPeriod - 1)
    return start.add(maxPeriod - 1, "day");
}

/**
 * The new booking's lead window [start - leadDays, start - 1] must be
 * free of existing conflicts.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map Availability map.
 * @param {import('dayjs').Dayjs} start Proposed booking start.
 * @param {number} leadDays Required lead days.
 * @param {import('../types/bookings.d.ts').Id|null} selectedItem Selected item.
 * @param {Array<import('../types/bookings.d.ts').Id>} allItemIds Candidate items.
 * @returns {boolean} Whether the lead window conflicts.
 */
export function leadWindowConflicts(
    map,
    start,
    leadDays,
    selectedItem,
    allItemIds
) {
    if (leadDays <= 0) return false;
    return rangeHasConflict(
        map,
        start.subtract(leadDays, "day"),
        start.subtract(1, "day"),
        selectedItem,
        allItemIds
    );
}

/**
 * The new booking's trail window [end + 1, end + trailDays] must be
 * free of existing conflicts.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map Availability map.
 * @param {import('dayjs').Dayjs} end Proposed booking end.
 * @param {number} trailDays Required trail days.
 * @param {import('../types/bookings.d.ts').Id|null} selectedItem Selected item.
 * @param {Array<import('../types/bookings.d.ts').Id>} allItemIds Candidate items.
 * @returns {boolean} Whether the trail window conflicts.
 */
export function trailWindowConflicts(
    map,
    end,
    trailDays,
    selectedItem,
    allItemIds
) {
    if (trailDays <= 0) return false;
    return rangeHasConflict(
        map,
        end.add(1, "day"),
        end.add(trailDays, "day"),
        selectedItem,
        allItemIds
    );
}

/**
 * The forced end for fixed-duration modes: the backend-calculated due
 * date when it is usable, else start + maxPeriod - 1, else null.
 *
 * @param {import('dayjs').Dayjs} start Proposed booking start.
 * @param {{calculatedDueDate?: import('dayjs').Dayjs|null, maxPeriod?: number|null}} config Effective rules.
 * @returns {import('dayjs').Dayjs|null} Forced end date.
 */
function forcedEndDate(start, config) {
    const due = config.calculatedDueDate;
    if (due && !due.isBefore(start, "day")) return due;
    const maxPeriod = Number(config.maxPeriod) || 0;
    return maxPeriod > 0 ? calculateMaxEndDate(start, maxPeriod) : null;
}

/**
 * end_date_only: the end is forced to start + period, so a start date is
 * only viable when at least one item is conflict-free across the whole
 * fixed range. rangeHasConflict implements exactly that: single-item
 * mode blocks on any conflict, any-item mode blocks when every item has
 * a conflict somewhere in the range. A per-day check would under-block:
 * two items with disjoint single-day conflicts leave no day fully
 * blocked, yet neither can serve the full period.
 *
 * @param {import('dayjs').Dayjs} d Proposed booking start.
 * @param {Object} config Effective booking rules.
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map Availability map.
 * @param {import('../types/bookings.d.ts').Id|null} selectedItem Selected item.
 * @param {Array<import('../types/bookings.d.ts').Id>} allItemIds Candidate items.
 * @returns {boolean} Whether the forced range is blocked.
 */
function endDateOnlyStartBlocked(d, config, map, selectedItem, allItemIds) {
    const targetEnd = forcedEndDate(d, config) ?? d;
    return (
        rangeHasConflict(map, d, targetEnd, selectedItem, allItemIds) ||
        trailWindowConflicts(
            map,
            targetEnd,
            config.trailDays,
            selectedItem,
            allItemIds
        )
    );
}

/**
 * Creates the main disable function that determines if a date should be disabled
 * @param {import('../types/bookings.d.ts').UnavailableByDate} unavailableByDate - Server availability map (edited booking already excluded)
 * @param {Object} config - Configuration object from extractBookingConfiguration
 * @param {Array<import('../types/bookings.d.ts').BookableItem>} bookableItems - Array of bookable items
 * @param {string|null} selectedItem - Selected item ID or null
 * @param {Array<Date>} selectedDates - Currently selected dates
 * @param {Array<string>} holidays - Array of holiday dates in YYYY-MM-DD format
 * @returns {(date: Date) => boolean} Disable function for Flatpickr
 */
export function createDisableFunction(
    unavailableByDate,
    config,
    bookableItems,
    selectedItem,
    selectedDates,
    holidays = []
) {
    const { today, leadDays, trailDays, isEndDateOnly } = config;
    const allItemIds = bookableItems.map(i => String(i.item_id));
    const holidaySet = new Set(holidays);
    const noSelection = !selectedDates || selectedDates.length === 0;
    const selStart = selectedDates?.[0] ? toDay(selectedDates[0]) : null;

    return date => {
        const d = toDay(date);

        if (d.isBefore(today, "day")) return true;

        // Only disable holidays when selecting START date - for END date
        // selection, we use click prevention instead so Flatpickr's range
        // validation passes
        if (noSelection && holidaySet.has(d.format("YYYY-MM-DD"))) {
            return true;
        }

        if (!bookableItems || bookableItems.length === 0) {
            return true;
        }

        if (isEndDateOnly) {
            if (
                noSelection &&
                endDateOnlyStartBlocked(
                    d,
                    config,
                    unavailableByDate,
                    selectedItem,
                    allItemIds
                )
            ) {
                return true;
            }

            // With a start selected the end is forced: reject clicks past
            // the computed end; intermediates are left to click prevention
            if (selectedDates?.length === 1 && selStart) {
                const expectedEnd = forcedEndDate(selStart, config);
                if (expectedEnd && d.isAfter(expectedEnd, "day")) return true;
            }
        }

        if (
            dateHasConflict(
                unavailableByDate,
                d.format("YYYY-MM-DD"),
                selectedItem,
                allItemIds
            )
        ) {
            return true;
        }

        if (!selStart || !d.isAfter(selStart, "day")) {
            // Potential START date - either nothing is selected yet, or the
            // click lands on/before the current start (which in Flatpickr
            // range mode would reset and start a new range)
            if (leadDays > 0) {
                // Enforce minimum advance booking: start date must be
                // >= today + leadDays. This applies even for the first
                // booking (no existing bookings to conflict with)
                if (d.isBefore(today.add(leadDays, "day"), "day")) return true;
            }

            if (
                leadWindowConflicts(
                    unavailableByDate,
                    d,
                    leadDays,
                    selectedItem,
                    allItemIds
                )
            ) {
                return true;
            }

            return trailWindowConflicts(
                unavailableByDate,
                d,
                trailDays,
                selectedItem,
                allItemIds
            );
        }

        // Potential END date - any date after the start could become the
        // new end, whether or not an end is already selected
        const calculatedEnd = forcedEndDate(selStart, config);

        // In end_date_only mode, the forced end date is ALWAYS selectable -
        // skip all other validation for it (trail period, range overlap)
        if (isEndDateOnly && calculatedEnd && d.isSame(calculatedEnd, "day")) {
            return false;
        }

        // The backend-calculated due date respects useDaysMode/calendar
        // (Nth opening day from start); simple maxPeriod arithmetic is the
        // fallback when no calculated date is available
        if (calculatedEnd && d.isAfter(calculatedEnd, "day")) return true;

        if (
            trailWindowConflicts(
                unavailableByDate,
                d,
                trailDays,
                selectedItem,
                allItemIds
            )
        ) {
            return true;
        }

        // In end_date_only mode, intermediate dates are not disabled here
        // (they use click prevention instead for better UX)
        if (isEndDateOnly) return false;

        // The booking range [start, end] must leave at least one item free.
        // This mirrors the backend's BETWEEN-based overlap detection
        return rangeHasConflict(
            unavailableByDate,
            selStart,
            d,
            selectedItem,
            allItemIds
        );
    };
}

/**
 * Whether any of the given items carry a reason on a map entry.
 *
 * @param {Object|undefined} entry Per-item reason sets for one date.
 * @param {string[]} itemIds Candidate items (union, not "every item").
 * @param {string} reason Reason token to look for.
 * @returns {boolean}
 */
function anyItemHasReason(entry, itemIds, reason) {
    if (!entry) return false;
    return itemIds.some(id => entry[id]?.has(reason));
}

/**
 * Whether every one of the given items is booked or checked out on a map
 * entry - the same "Unavailable" invariant markersByDate/disabledByDate
 * use (§6 of the UX spec): a slot only counts as genuinely occupied once
 * every relevant item is blocked there, not as soon as one is. A day
 * where only some items are booked is "partial", not "Unavailable", and
 * shouldn't anchor the existing-booking lead/trail highlight - dots
 * still show for that day (via markersByDate's own partial handling),
 * just not the surrounding coloured band.
 *
 * @param {Object|undefined} entry Per-item reason sets for one date.
 * @param {string[]} itemIds Relevant items (every one, not just one).
 * @returns {boolean}
 */
function allItemsBlocked(entry, itemIds) {
    if (!entry || itemIds.length === 0) return false;
    return itemIds.every(id => setHasAny(entry[id], HARD_CONFLICT_REASONS));
}

/**
 * Nearest date where every relevant item is booked or checked out (a
 * genuine "Unavailable" slot, §6), walking day-by-day from (and
 * including) `from` in `direction`.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map Availability map.
 * @param {import('dayjs').Dayjs} from Date to start the walk from, inclusive.
 * @param {1|-1} direction +1 walks forward, -1 walks backward.
 * @param {string[]} itemIds Relevant item ids.
 * @param {number} maxWalkDays Safety bound on the walk.
 * @returns {import('dayjs').Dayjs|null} The nearest occupied date, or null.
 */
function nearestOccupiedDate(map, from, direction, itemIds, maxWalkDays) {
    let d = from.clone();
    for (let i = 0; i < maxWalkDays; i++) {
        const key = d.format("YYYY-MM-DD");
        if (allItemsBlocked(map[key], itemIds)) {
            return d;
        }
        d = d.add(direction, "day");
    }
    return null;
}

/**
 * Existing bookings' lead/trail dates immediately adjacent to a hovered
 * gap: the trail window after the closest booking ending at or before the
 * hovered date, and the lead window before the closest booking starting
 * at or after it. Returns nothing when the hovered date is itself part
 * of an existing booking (not "bookable space" to preview from).
 *
 * The band width comes from leadDays/trailDays (the same effective
 * circulation-rule values driving my own buffer preview, see
 * bufferConfig/myBufferDates) applied relative to the anchor, not from
 * walking each item's own server-tagged lead/trail run: when several
 * items' bookings combine to form one Unavailable span but start on
 * different days (e.g. item A from the 13th, item B from the 14th, both
 * booked through the 15th - Unavailable only once both are booked, from
 * the 14th), each item's own tagged window is relative to *its own*
 * booking start, so a plain per-item tag walk would union them into a
 * wider band than the 14th's own leadDays actually calls for. Anchoring
 * on the combined Unavailable start/end and applying the day-count
 * directly keeps the band consistent with what the constraint-info box
 * states, regardless of how many items' bookings happen to overlap here.
 *
 * @param {import('../types/bookings.d.ts').UnavailableByDate} map Availability map.
 * @param {string} hoveredYmd Hovered date, YYYY-MM-DD.
 * @param {string[]} itemIds Relevant item ids (already narrowed by selection).
 * @param {number} [leadDays] Effective lead-period day count.
 * @param {number} [trailDays] Effective trail-period day count.
 * @param {number} [maxWalkDays] Safety bound on the anchor search.
 * @returns {{trailDates: string[], leadDates: string[]}} YYYY-MM-DD keys, chronological order.
 */
export function findAdjacentBufferDates(
    map,
    hoveredYmd,
    itemIds,
    leadDays = 0,
    trailDays = 0,
    maxWalkDays = 60
) {
    const hovered = toDay(hoveredYmd);
    const hoveredEntry = map[hovered.format("YYYY-MM-DD")];
    if (
        anyItemHasReason(hoveredEntry, itemIds, "booking") ||
        anyItemHasReason(hoveredEntry, itemIds, "checkout")
    ) {
        return { trailDates: [], leadDates: [] };
    }

    let trailDates = [];
    const closestBefore = nearestOccupiedDate(
        map,
        hovered,
        -1,
        itemIds,
        maxWalkDays
    );
    if (closestBefore) {
        trailDates = myBufferDates(closestBefore, trailDays, "trail");
    }

    let leadDates = [];
    const closestAfter = nearestOccupiedDate(
        map,
        hovered,
        1,
        itemIds,
        maxWalkDays
    );
    if (closestAfter) {
        leadDates = myBufferDates(closestAfter, leadDays, "lead");
    }
    return { trailDates, leadDates };
}

/**
 * Date keys for my own booking's lead or trail buffer relative to a
 * boundary date - pure day arithmetic, no availability lookup, since this
 * previews where the buffer *would* land rather than whether it conflicts
 * (createDisableFunction already decides that).
 *
 * @param {import('dayjs').Dayjs|Date|string} boundary Start (for lead) or end (for trail).
 * @param {number} days Lead or trail day count.
 * @param {"lead"|"trail"} kind Which buffer this is.
 * @returns {string[]} YYYY-MM-DD keys, chronological order.
 */
export function myBufferDates(boundary, days, kind) {
    if (!days || days <= 0) return [];
    const b = toDay(boundary);
    const dates = [];
    for (let i = 1; i <= days; i++) {
        const d = kind === "lead" ? b.subtract(i, "day") : b.add(i, "day");
        dates.push(d.format("YYYY-MM-DD"));
    }
    if (kind === "lead") dates.reverse();
    return dates;
}

/**
 * Find the first date where a booking range [startDate, candidateEnd] would
 * conflict with all items, walking the availability map day by day and
 * accumulating per-item conflicts: once every candidate item has a conflict
 * somewhere in [start, day], no single item can serve the whole period.
 *
 * @param {Date|import('dayjs').Dayjs} startDate - Start of the booking range
 * @param {Date|import('dayjs').Dayjs} endDate - Maximum end date to check
 * @param {import('../types/bookings.d.ts').UnavailableByDate} unavailableByDate
 * @param {Array<import('../types/bookings.d.ts').BookableItem>} bookableItems - Array of bookable items
 * @param {string|number|null} selectedItem - Selected item ID or null for "any item"
 * @returns {{ firstBlockingDate: Date|null, reason: string|null }} The first date that would cause all items to conflict
 */
export function findFirstBlockingDate(
    startDate,
    endDate,
    unavailableByDate,
    bookableItems,
    selectedItem
) {
    if (!bookableItems || bookableItems.length === 0) {
        return {
            firstBlockingDate: toDay(startDate).toDate(),
            reason: "no_items",
        };
    }

    const start = toDay(startDate);
    const end = toDay(endDate);
    if (!end.isAfter(start, "day")) {
        return { firstBlockingDate: null, reason: null };
    }

    const allItemIds = bookableItems.map(i => String(i.item_id));
    const selected =
        selectedItem != null && selectedItem !== ""
            ? String(selectedItem)
            : null;
    /**
     * Return the first blocking reason in domain priority order.
     *
     * @param {Set<string>} reasons Conflict reasons for one item and date.
     * @returns {string|undefined} Highest-priority blocking reason.
     */
    const conflictReason = reasons =>
        CONFLICT_REASONS.find(r => reasons.has(r));
    const itemsWithConflicts = new Set();

    for (
        let day = start.clone();
        !day.isAfter(end, "day");
        day = day.add(1, "day")
    ) {
        const entry = unavailableByDate[day.format("YYYY-MM-DD")];
        if (!entry) continue;

        // A conflict on the start day itself blocks the earliest possible
        // end (start + 1), the same range the first candidate end covers
        const blockedEnd = day.isAfter(start, "day")
            ? day
            : start.add(1, "day");

        if (selected) {
            const reasons = entry[selected];
            const reason = reasons && conflictReason(reasons);
            if (reason) {
                return { firstBlockingDate: blockedEnd.toDate(), reason };
            }
            continue;
        }

        for (const id of allItemIds) {
            const reasons = entry[id];
            if (reasons && conflictReason(reasons)) {
                itemsWithConflicts.add(id);
            }
        }
        if (itemsWithConflicts.size === allItemIds.length) {
            return {
                firstBlockingDate: blockedEnd.toDate(),
                reason: "all_items_have_conflicts",
            };
        }
    }

    return { firstBlockingDate: null, reason: null };
}

/**
 * Extracts and validates configuration from circulation rules
 * @param {Object} circulationRules - Raw circulation rules object
 * @param {Date|import('dayjs').Dayjs} todayArg - Optional today value for deterministic tests
 * @returns {Object} Normalized configuration object
 */
export function extractBookingConfiguration(circulationRules, todayArg) {
    const today = todayArg ? toDay(todayArg) : todayDate();
    const leadDays = Number(circulationRules?.bookings_lead_period) || 0;
    const trailDays = Number(circulationRules?.bookings_trail_period) || 0;
    // In unconstrained mode, do not enforce a default max period
    const maxPeriod =
        Number(circulationRules?.maxPeriod) ||
        Number(circulationRules?.issuelength) ||
        0;
    const isEndDateOnly =
        circulationRules?.booking_constraint_mode ===
        CONSTRAINT_MODE_END_DATE_ONLY;
    const calculatedDueDate = circulationRules?.calculated_due_date
        ? toDay(circulationRules.calculated_due_date)
        : null;
    const calculatedPeriodDays = Number(
        circulationRules?.calculated_period_days
    )
        ? Number(circulationRules.calculated_period_days)
        : null;

    return {
        today,
        leadDays,
        trailDays,
        maxPeriod,
        isEndDateOnly,
        calculatedDueDate,
        calculatedPeriodDays,
    };
}

/**
 * Derive effective circulation rules with constraint options applied.
 * - Applies maxPeriod only for constraining modes
 * - Strips caps for unconstrained mode
 * @param {import('../types/bookings.d.ts').CirculationRule} [baseRules={}]
 * @param {import('../types/bookings.d.ts').ConstraintOptions} [constraintOptions={}]
 * @returns {import('../types/bookings.d.ts').CirculationRule}
 */
function deriveEffectiveRules(baseRules = {}, constraintOptions = {}) {
    const effectiveRules = { ...baseRules };
    const mode = constraintOptions.dateRangeConstraint;
    if (mode === "issuelength" || mode === "issuelength_with_renewals") {
        if (constraintOptions.maxBookingPeriod) {
            effectiveRules.maxPeriod = constraintOptions.maxBookingPeriod;
        }
    } else {
        if ("maxPeriod" in effectiveRules) delete effectiveRules.maxPeriod;
        if ("issuelength" in effectiveRules) delete effectiveRules.issuelength;
    }
    return effectiveRules;
}

/**
 * Convenience: take full circulationRules array and constraint options,
 * return effective rules applying maxPeriod logic.
 * @param {import('../types/bookings.d.ts').CirculationRule[]} circulationRules
 * @param {import('../types/bookings.d.ts').ConstraintOptions} [constraintOptions={}]
 * @returns {import('../types/bookings.d.ts').CirculationRule}
 */
export function toEffectiveRules(circulationRules, constraintOptions = {}) {
    const baseRules = circulationRules?.[0] || {};
    return deriveEffectiveRules(baseRules, constraintOptions);
}

/**
 * Calculate maximum booking period from circulation rules and constraint mode.
 *
 * @param {import('../types/bookings.d.ts').CirculationRule[]} circulationRules Rules to inspect.
 * @param {string|null} dateRangeConstraint Active constraint mode.
 * @param {((rules: import('../types/bookings.d.ts').CirculationRule) => number|null)|null} customDateRangeFormula Custom period formula.
 * @returns {number|null} Maximum booking period, or null when unconstrained.
 */
export function calculateMaxBookingPeriod(
    circulationRules,
    dateRangeConstraint,
    customDateRangeFormula = null
) {
    if (!dateRangeConstraint) return null;
    const rules = circulationRules?.[0];
    if (!rules) return null;
    const issuelength = parseInt(rules.issuelength) || 0;
    switch (dateRangeConstraint) {
        case "issuelength":
            return issuelength;
        case "issuelength_with_renewals": {
            const renewalperiod = parseInt(rules.renewalperiod) || 0;
            const renewalsallowed = parseInt(rules.renewalsallowed) || 0;
            return issuelength + renewalperiod * renewalsallowed;
        }
        case "custom":
            return typeof customDateRangeFormula === "function"
                ? customDateRangeFormula(rules)
                : null;
        default:
            return null;
    }
}
