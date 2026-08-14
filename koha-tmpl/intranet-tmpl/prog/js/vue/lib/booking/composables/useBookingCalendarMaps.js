/**
 * Translate booking domain state into the Maps and functions that
 * BookingCalendar consumes: disabledFn, disabledByDate, markersByDate,
 * classByDate, rangePreviewFn, loanBoundaryTimes.
 *
 * The conflict data arrives pre-computed from
 * GET /biblios/{biblio_id}/booking_availability (fetched by the store,
 * windowed to the picker viewport, edited booking already excluded);
 * this composable reshapes it and layers the draft-dependent UX logic
 * (disable predicate, range preview, constrained-range highlighting)
 * that must react per click without a server round-trip.
 *
 * @module composables/useBookingCalendarMaps
 */

import { computed } from "vue";
import { isoArrayToDates, toDay } from "../dates.js";
import { serverMapToUnavailableByDate } from "../availability/server-map.js";
import {
    calculateMaxEndDate,
    createDisableFunction,
    extractBookingConfiguration,
    findFirstBlockingDate,
    toEffectiveRules,
} from "../availability/predicate.js";
import { getBookingMarkersForDate } from "../markers.js";
import { $__ } from "@koha-vue/i18n";

const CLASS_BOOKING_CONSTRAINED_RANGE_MARKER =
    "booking-constrained-range-marker";
const CLASS_BOOKING_INTERMEDIATE_BLOCKED = "booking-intermediate-blocked";
const CLASS_BOOKING_LOAN_BOUNDARY = "booking-loan-boundary";
const CONSTRAINT_MODE_END_DATE_ONLY = "end_date_only";

/** Marker kinds surfaced through hover feedback and CSS only, not the dot badge */
const BADGELESS_MARKER_KINDS = new Set(["lead-floor", "lead-theoretical"]);

/**
 * @param {Object} inputs
 * @param {import("vue").Ref<Array>} inputs.bookableItems
 * @param {import("vue").Ref<Object|null>} inputs.availability - Raw booking_availability endpoint payload
 * @param {import("vue").Ref<Array<string>>} inputs.holidays
 * @param {import("vue").Ref<string[]>} [inputs.selectedDateRange] - ISO[] of currently selected start/end
 * @param {import("vue").Ref<Object>} [inputs.constraintOptions] - dateRangeConstraint, maxBookingPeriod, etc.
 * @param {import("vue").Ref<Date|null>} [inputs.rangeAnchor]
 * @param {import("vue").Ref<number|null>} [inputs.maxBookingPeriod]
 * @param {import("vue").Ref<string|number|null>} [inputs.bookingItemId]
 * @param {import("vue").Ref<string|number|null>} [inputs.bookingItemtypeId]
 * @param {import("vue").Ref<Array>} [inputs.circulationRules]
 * @returns {{
 *   disabledFn: import("vue").ComputedRef<(date: Date) => boolean>,
 *   disabledByDate: import("vue").ComputedRef<Map<string, {reason:string,severity:"hard"|"soft"}>>,
 *   markersByDate: import("vue").ComputedRef<Map<string, Array<{kind:string,className:string,tooltip?:string}>>>,
 *   classByDate: import("vue").ComputedRef<Map<string, string>>,
 *   rangePreviewFn: (anchor: Date, hover: Date) => {status:"valid"|"invalid",message?:string},
 *   loanBoundaryTimes: import("vue").ComputedRef<Set<number>>,
 * }}
 */
export function useBookingCalendarMaps({
    bookableItems,
    availability,
    holidays,
    selectedDateRange,
    constraintOptions,
    rangeAnchor,
    maxBookingPeriod,
    bookingItemId,
    bookingItemtypeId,
    circulationRules,
}) {
    const relevantItemIds = computed(() => {
        const items = bookableItems.value || [];
        const selectedItem = bookingItemId?.value;
        if (selectedItem != null && selectedItem !== "") {
            return [String(selectedItem)];
        }
        const selectedItemtype = bookingItemtypeId?.value;
        if (selectedItemtype != null && selectedItemtype !== "") {
            return items
                .filter(i => {
                    const t = i.effective_item_type_id || i.item_type_id;
                    return String(t) === String(selectedItemtype);
                })
                .map(i => String(i.item_id));
        }
        return items.map(i => String(i.item_id));
    });

    const effectiveRules = computed(() => {
        const rules = circulationRules?.value;
        if (Array.isArray(rules) && rules.length > 0) return rules[0] || {};
        if (rules && typeof rules === "object" && !Array.isArray(rules))
            return rules;
        return {};
    });

    /** True once the availability payload for the current context arrived */
    const availabilityReady = computed(() => availability?.value != null);

    const unavailableByDate = computed(() =>
        serverMapToUnavailableByDate(availability?.value)
    );

    const disabledFn = computed(() => {
        // Until availability arrives nothing is safely selectable
        if (!availabilityReady.value) return () => true;

        const opts = constraintOptions?.value || {};
        const config = extractBookingConfiguration(
            toEffectiveRules(circulationRules?.value, opts),
            undefined
        );
        const selDates = isoArrayToDates(selectedDateRange?.value || []);
        return createDisableFunction(
            unavailableByDate.value,
            config,
            bookableItems.value || [],
            bookingItemId?.value != null ? String(bookingItemId.value) : null,
            selDates,
            holidays?.value || []
        );
    });

    // Severity-tagged Map for visualization. disabledFn carries the full
    // validation logic (past dates, lead/trail, range overlap), but its
    // boolean output loses severity. Consumers that need to render
    // soft-disabled affordances (e.g., a holiday during picking-end mode
    // that the range can still cross) read this Map.
    const disabledByDate = computed(() => {
        /** @type {Map<string, {reason:string,severity:"hard"|"soft"}>} */
        const result = new Map();
        const itemIds = relevantItemIds.value;
        const anchor = rangeAnchor?.value ?? null;
        const holidaySet = new Set(holidays.value || []);

        if (itemIds.length > 0) {
            Object.entries(unavailableByDate.value).forEach(
                ([dateKey, byItem]) => {
                    const allBlocked = itemIds.every(id => {
                        const reasons = byItem[id];
                        if (!reasons) return false;
                        return (
                            reasons.has("booking") || reasons.has("checkout")
                        );
                    });
                    if (allBlocked) {
                        result.set(dateKey, {
                            reason: $__("All items unavailable"),
                            severity: "hard",
                        });
                    }
                }
            );
        }

        // Holidays: hard when no anchor, soft when an anchor is set so the
        // range can cross them. A booking-blocked entry already in the map
        // wins (booking unavailability is always hard).
        holidaySet.forEach(dateKey => {
            if (result.has(dateKey)) return;
            result.set(dateKey, {
                reason: $__("Library closed"),
                severity: anchor ? "soft" : "hard",
            });
        });

        // end_date_only mode: every date strictly between the anchor and
        // the calculated target end is soft-disabled. The user can only
        // commit the calculated end (or shrink the range from the anchor
        // side); intermediate clicks shouldn't reset the range. The
        // disable function in createDisableFunction deliberately leaves
        // these enabled so flatpickr's range validator still accepts the
        // [anchor, end] span; the UX is enforced here via soft severity.
        const rules = effectiveRules.value;
        const isEndDateOnly =
            rules?.booking_constraint_mode === CONSTRAINT_MODE_END_DATE_ONLY;
        const maxPeriod = maxBookingPeriod?.value;
        if (isEndDateOnly && anchor && maxPeriod && maxPeriod > 0) {
            const start = toDay(anchor);
            // The forced end is start + maxPeriod - 1 (start counts as
            // day 1, mirroring calculateMaxEndDate). It must stay
            // clickable — only the dates strictly between anchor and
            // target are soft-disabled.
            const targetEnd = start.add(maxPeriod - 1, "day");
            for (
                let d = start.clone().add(1, "day");
                d.isBefore(targetEnd, "day");
                d = d.add(1, "day")
            ) {
                const key = d.format("YYYY-MM-DD");
                const existing = result.get(key);
                if (existing && existing.severity === "hard") continue;
                result.set(key, {
                    reason: $__("Intermediate date in fixed range"),
                    severity: "soft",
                });
            }
        }

        return result;
    });

    const markersByDate = computed(() => {
        /** @type {Map<string, Array<{kind:string,className:string,tooltip?:string}>>} */
        const result = new Map();
        const items = bookableItems.value || [];

        Object.keys(unavailableByDate.value).forEach(dateKey => {
            const markers = getBookingMarkersForDate(
                unavailableByDate.value,
                dateKey,
                items
            ).filter(m => !BADGELESS_MARKER_KINDS.has(m.type));
            if (markers.length === 0) return;
            result.set(
                dateKey,
                markers.map(m => ({
                    kind: m.type,
                    className: `booking-marker-dot--${m.type}`,
                    tooltip: m.itemName,
                }))
            );
        });

        return result;
    });

    /**
     * Loan-period boundary timestamps: anchor, anchor+issuelength, and each
     * renewal-period boundary. Used to apply CLASS_BOOKING_LOAN_BOUNDARY to
     * those days and exposed as a Set so the parent can write it onto the
     * flatpickr instance for tests/legacy consumers that read it directly.
     */
    const loanBoundaryTimes = computed(() => {
        const result = new Set();
        const anchor = rangeAnchor?.value;
        if (!anchor) return result;
        const startDate = toDay(anchor);
        result.add(startDate.toDate().getTime());
        const rules =
            (Array.isArray(circulationRules?.value)
                ? circulationRules.value[0]
                : circulationRules?.value) ?? {};
        const issuelength = parseInt(rules.issuelength) || 0;
        const renewalperiod = parseInt(rules.renewalperiod) || 0;
        const renewalsallowed = parseInt(rules.renewalsallowed) || 0;
        if (issuelength > 0) {
            result.add(startDate.add(issuelength, "day").toDate().getTime());
            if (renewalperiod > 0 && renewalsallowed > 0) {
                for (let k = 1; k <= renewalsallowed; k++) {
                    result.add(
                        startDate
                            .add(issuelength + k * renewalperiod, "day")
                            .toDate()
                            .getTime()
                    );
                }
            }
        }
        return result;
    });

    const classByDate = computed(() => {
        /** @type {Map<string, string>} */
        const result = new Map();
        const anchor = rangeAnchor?.value;
        const maxPeriod = maxBookingPeriod?.value;

        if (anchor && maxPeriod && maxPeriod > 0) {
            const start = toDay(anchor);
            let end = calculateMaxEndDate(anchor, maxPeriod);

            // Clamp to actual availability: when all items become unavailable
            // before the theoretical end, stop highlighting at the last day a
            // booking range from the anchor could still be placed. Mirrors the
            // backend's BETWEEN-based overlap detection so the highlight only
            // covers ranges the server would accept.
            const items = bookableItems.value || [];
            if (items.length > 0) {
                const { firstBlockingDate } = findFirstBlockingDate(
                    start,
                    end,
                    unavailableByDate.value,
                    items,
                    bookingItemId?.value != null
                        ? String(bookingItemId.value)
                        : null
                );
                if (firstBlockingDate) {
                    const clampedEnd = toDay(firstBlockingDate).subtract(
                        1,
                        "day"
                    );
                    if (clampedEnd.isBefore(end, "day")) {
                        end = clampedEnd;
                    }
                }
            }

            for (
                let d = start.clone();
                !d.isAfter(end, "day");
                d = d.add(1, "day")
            ) {
                result.set(
                    d.format("YYYY-MM-DD"),
                    CLASS_BOOKING_CONSTRAINED_RANGE_MARKER
                );
            }
        }

        // Merge loan-boundary class for anchor + issuelength + each renewal end.
        loanBoundaryTimes.value.forEach(ts => {
            const key = toDay(new Date(ts)).format("YYYY-MM-DD");
            const existing = result.get(key);
            result.set(
                key,
                existing
                    ? `${existing} ${CLASS_BOOKING_LOAN_BOUNDARY}`
                    : CLASS_BOOKING_LOAN_BOUNDARY
            );
        });

        // end_date_only mode: tag intermediate dates within the constrained
        // range so they render distinctly from the regular constrained-range
        // highlight, signalling that those days are inside the fixed span
        // but cannot be clicked.
        const rules = effectiveRules.value;
        const isEndDateOnly =
            rules?.booking_constraint_mode === CONSTRAINT_MODE_END_DATE_ONLY;
        if (isEndDateOnly && anchor && maxPeriod && maxPeriod > 0) {
            const start = toDay(anchor);
            // Forced end = start + maxPeriod - 1 (start counts as day 1);
            // it is the one clickable date, so it must not carry the
            // intermediate-blocked affordance.
            const targetEnd = start.add(maxPeriod - 1, "day");
            for (
                let d = start.clone().add(1, "day");
                d.isBefore(targetEnd, "day");
                d = d.add(1, "day")
            ) {
                const key = d.format("YYYY-MM-DD");
                const existing = result.get(key);
                result.set(
                    key,
                    existing
                        ? `${existing} ${CLASS_BOOKING_INTERMEDIATE_BLOCKED}`
                        : CLASS_BOOKING_INTERMEDIATE_BLOCKED
                );
            }
        }

        return result;
    });

    /**
     * Validate a tentative range without mutating the booking draft.
     *
     * @param {Date|string} anchor Selected range start.
     * @param {Date|string} hover Tentative range end.
     * @returns {{status: string, message?: string}} Range preview result.
     */
    function rangePreviewFn(anchor, hover) {
        const a = toDay(anchor);
        const h = toDay(hover);

        if (h.isBefore(a, "day")) {
            return {
                status: "invalid",
                message: $__("End date must be on or after the start date"),
            };
        }

        const maxPeriod = maxBookingPeriod?.value;
        const days = h.diff(a, "day") + 1;
        if (maxPeriod && days > maxPeriod) {
            return {
                status: "invalid",
                message: $__(
                    "Range exceeds max booking period (%s days)"
                ).format(maxPeriod),
            };
        }

        const fn = disabledFn.value;
        for (let d = a.clone(); !d.isAfter(h, "day"); d = d.add(1, "day")) {
            if (fn(d.toDate())) {
                return {
                    status: "invalid",
                    message: $__("Range includes blocked day"),
                };
            }
        }

        return { status: "valid" };
    }

    return {
        disabledFn,
        disabledByDate,
        markersByDate,
        classByDate,
        rangePreviewFn,
        loanBoundaryTimes,
        unavailableByDate,
        availabilityReady,
    };
}
