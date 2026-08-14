/**
 * Marker generation and aggregation for the booking system.
 *
 * This module handles generation of calendar markers from availability data
 * and aggregation of markers by type for display purposes.
 *
 * @module markers
 */

import { formatYMD, toDay, today } from "./dates.js";
import { idsEqual } from "../../utils/functions.js";
import { $__ } from "@koha-vue/i18n";

const MARKER_TYPE_MAP = Object.freeze({
    booking: "booked",
    checkout: "checked-out",
});
const CLASS_BOOKING_MARKER_COUNT = "booking-marker-count";
const CLASS_BOOKING_MARKER_DOT = "booking-marker-dot";
const CLASS_BOOKING_MARKER_GRID = "booking-marker-grid";
const CLASS_BOOKING_MARKER_ITEM = "booking-marker-item";

/**
 * Get the translated display label for a marker type.
 *
 * @param {string} type
 * @returns {string}
 */
export function getMarkerTypeLabel(type) {
    const labels = {
        booked: $__("Booked"),
        "checked-out": $__("Checked out"),
        lead: $__("Lead period"),
        "lead-floor": $__("Minimum lead time from today"),
        "lead-theoretical": $__("Lead period for a follow-up booking"),
        trail: $__("Trail period"),
        holiday: $__("Library closed"),
    };
    return labels[type] || type;
}

/**
 * Aggregate all booking/checkouts for a given date (for calendar indicators)
 * @param {import('./types/bookings.d.ts').UnavailableByDate} unavailableByDate - Map produced by serverMapToUnavailableByDate
 * @param {string|Date|import("dayjs").Dayjs} dateStr - date to check (YYYY-MM-DD or Date or dayjs)
 * @param {Array<import('./types/bookings.d.ts').BookableItem>} bookableItems - Array of all bookable items
 * @returns {import('./types/bookings.d.ts').CalendarMarker[]} indicators for that date
 */
export function getBookingMarkersForDate(
    unavailableByDate,
    dateStr,
    bookableItems = []
) {
    if (!unavailableByDate) {
        return [];
    }

    let d;
    try {
        d = dateStr ? toDay(dateStr) : today();
    } catch {
        d = today();
    }
    const key = d.format("YYYY-MM-DD");
    const markers = [];

    /**
     * Resolve a marker item across string and numeric identifier forms.
     *
     * @param {import('./types/bookings.d.ts').Id|null|undefined} item_id Item identifier.
     * @returns {import('./types/bookings.d.ts').BookableItem|undefined} Matching item.
     */
    const findItem = item_id => {
        if (item_id == null) return undefined;
        return bookableItems.find(i => idsEqual(i?.item_id, item_id));
    };

    const entry = unavailableByDate[key];

    if (!entry) {
        return [];
    }

    for (const [item_id, reasons] of Object.entries(entry)) {
        const item = findItem(item_id);
        for (const reason of reasons) {
            // Map IntervalTree/Sweep reasons to CSS class names
            // lead and trail periods keep their original names for CSS
            const type = MARKER_TYPE_MAP[reason] ?? reason;
            markers.push({
                /** @type {import('./types/bookings.d.ts').MarkerType} */
                type: /** @type {any} */ (type),
                item: String(item_id),
                itemName:
                    item?.external_id || item?.barcode || item?.title || "",
                barcode: item?.external_id || item?.barcode || null,
            });
        }
    }
    return markers;
}

/**
 * Aggregate markers by type for display
 * @param {Array} markers - Array of booking markers
 * @returns {import('./types/bookings.d.ts').MarkerAggregation} Aggregated counts by type
 */
export function aggregateMarkersByType(markers) {
    return markers.reduce((acc, marker) => {
        // Lead/trail markers (including the lead-floor / lead-theoretical
        // variants carried by the server availability map) are reflected
        // through CSS class names and hover feedback, not the dot grid.
        if (
            marker.type !== "lead" &&
            marker.type !== "lead-floor" &&
            marker.type !== "lead-theoretical" &&
            marker.type !== "trail"
        ) {
            acc[marker.type] = (acc[marker.type] || 0) + 1;
        }
        return acc;
    }, {});
}

/**
 * Build the DOM grid for aggregated booking markers.
 *
 * @param {import('./types/bookings.d.ts').MarkerAggregation} aggregatedMarkers - counts by marker type
 * @returns {HTMLDivElement} container element with marker items
 */
export function buildMarkerGrid(aggregatedMarkers) {
    const gridContainer = document.createElement("div");
    gridContainer.className = CLASS_BOOKING_MARKER_GRID;
    Object.entries(aggregatedMarkers).forEach(([type, count]) => {
        const markerSpan = document.createElement("span");
        markerSpan.className = CLASS_BOOKING_MARKER_ITEM;

        const dot = document.createElement("span");
        dot.className = `${CLASS_BOOKING_MARKER_DOT} ${CLASS_BOOKING_MARKER_DOT}--${type}`;
        dot.title = getMarkerTypeLabel(type);
        markerSpan.appendChild(dot);

        if (count > 0) {
            const countSpan = document.createElement("span");
            countSpan.className = CLASS_BOOKING_MARKER_COUNT;
            countSpan.textContent = ` ${count}`;
            markerSpan.appendChild(countSpan);
        }
        gridContainer.appendChild(markerSpan);
    });
    return gridContainer;
}

/**
 * Contextual hover feedback messages for booking calendar dates.
 *
 * Generates user-facing messages explaining why a date is disabled
 * or providing context about the current selection mode.
 * Mirrors upstream's ~20 contextual messages adapted for the Vue architecture.
 *
 * @module hover-feedback
 */

/**
 * Generate a contextual feedback message for a hovered calendar date.
 *
 * @param {Date} date - The date being hovered
 * @param {Object} context
 * @param {boolean} context.isDisabled - Whether the date is disabled in the calendar
 * @param {string[]} context.selectedDateRange - Currently selected dates (ISO strings)
 * @param {Object} context.circulationRules - First circulation rule object
 * @param {Object} context.unavailableByDate - Unavailability map from store
 * @param {string[]} [context.holidays] - Holiday date strings (YYYY-MM-DD)
 * @returns {{ message: string, variant: "info"|"warning"|"danger" } | null}
 */
export function getDateFeedbackMessage(date, context) {
    const {
        isDisabled,
        selectedDateRange,
        circulationRules,
        unavailableByDate,
        holidays,
    } = context;

    const currentDay = today();
    const d = toDay(date);
    const dateKey = formatYMD(date);

    const leadDays = Number(circulationRules?.bookings_lead_period) || 0;
    const trailDays = Number(circulationRules?.bookings_trail_period) || 0;
    const maxPeriod =
        Number(circulationRules?.maxPeriod) ||
        Number(circulationRules?.issuelength) ||
        0;

    const hasStart = selectedDateRange && selectedDateRange.length >= 1;
    const isSelectingEnd = hasStart;
    const isSelectingStart = !hasStart;

    if (isDisabled) {
        const reason = getDisabledReason(d, dateKey, {
            today: currentDay,
            leadDays,
            trailDays,
            maxPeriod,
            isSelectingStart,
            isSelectingEnd,
            selectedDateRange,
            unavailableByDate,
            holidays,
        });
        return { message: reason, variant: "danger" };
    }

    const info = getEnabledInfo({
        leadDays,
        trailDays,
        isSelectingStart,
        isSelectingEnd,
        unavailableByDate,
        dateKey,
    });
    return info ? { message: info, variant: "info" } : null;
}

/**
 * Determine the reason a date is disabled.
 * Checks conditions in priority order matching upstream logic.
 *
 * @param {import('dayjs').Dayjs} d Date being described.
 * @param {string} dateKey Date key in YYYY-MM-DD format.
 * @param {Object} ctx Calendar feedback context.
 * @returns {string} Translated reason the date is disabled.
 */
function getDisabledReason(d, dateKey, ctx) {
    // Past date
    if (d.isBefore(ctx.today, "day")) {
        return $__("Cannot select: date is in the past");
    }

    // Holiday
    if (ctx.holidays && ctx.holidays.includes(dateKey)) {
        return $__("Cannot select: library is closed on this date");
    }

    // Insufficient lead time from today
    if (ctx.isSelectingStart && ctx.leadDays > 0) {
        const minStart = ctx.today.add(ctx.leadDays, "day");
        if (d.isBefore(minStart, "day")) {
            return $__(
                "Cannot select: insufficient lead time (%s days required before start)"
            ).format(ctx.leadDays);
        }
    }

    // Exceeds maximum booking period
    if (ctx.isSelectingEnd && ctx.maxPeriod > 0 && ctx.selectedDateRange?.[0]) {
        const start = toDay(ctx.selectedDateRange[0]);
        if (d.isAfter(start.add(ctx.maxPeriod, "day"), "day")) {
            return $__(
                "Cannot select: exceeds maximum booking period (%s days)"
            ).format(ctx.maxPeriod);
        }
    }

    // Check markers in unavailableByDate for specific reasons
    const markerReasons = collectMarkerReasons(ctx.unavailableByDate, dateKey);

    if (markerReasons.has("holiday")) {
        return $__("Cannot select: library is closed on this date");
    }
    if (markerReasons.has("booking")) {
        return $__("Cannot select: this date is part of an existing booking");
    }
    if (markerReasons.has("checkout")) {
        return $__("Cannot select: this date is part of an existing checkout");
    }
    if (markerReasons.has("lead-floor")) {
        return $__(
            "Cannot select: minimum %s-day lead time from today is required before any booking can start"
        ).format(ctx.leadDays);
    }
    if (markerReasons.has("lead-theoretical")) {
        return $__(
            "Cannot select: a %s-day lead time is required after an existing booking's trail period before a new booking can start"
        ).format(ctx.leadDays);
    }
    if (markerReasons.has("lead")) {
        return $__(
            "Cannot select: this date is part of an existing booking's lead period"
        );
    }
    if (markerReasons.has("trail")) {
        return $__(
            "Cannot select: this date is part of an existing booking's trail period"
        );
    }

    // Lead period of selected start would conflict
    if (ctx.isSelectingStart && ctx.leadDays > 0) {
        return $__(
            "Cannot select: lead period (%s days before start) conflicts with an existing booking"
        ).format(ctx.leadDays);
    }

    // Trail period of selected end would conflict
    if (ctx.isSelectingEnd && ctx.trailDays > 0) {
        return $__(
            "Cannot select: trail period (%s days after return) conflicts with an existing booking"
        ).format(ctx.trailDays);
    }

    return $__("Cannot select: conflicts with an existing booking");
}

/**
 * Generate info message for an enabled (selectable) date.
 *
 * @param {Object} ctx Calendar feedback context.
 * @returns {string|null} Translated selection guidance when applicable.
 */
function getEnabledInfo(ctx) {
    // Collect context appendages from markers
    const appendages = [];
    const markerReasons = collectMarkerReasons(
        ctx.unavailableByDate,
        ctx.dateKey
    );
    if (markerReasons.has("lead-floor")) {
        appendages.push($__("within minimum lead time from today"));
    }
    if (markerReasons.has("lead-theoretical")) {
        appendages.push(
            $__("within lead time required after an existing booking's trail")
        );
    }
    if (markerReasons.has("lead")) {
        appendages.push($__("hovering an existing booking's lead period"));
    }
    if (markerReasons.has("trail")) {
        appendages.push($__("hovering an existing booking's trail period"));
    }

    const suffix =
        appendages.length > 0 ? " \u2022 " + appendages.join(", ") : "";

    if (ctx.isSelectingStart) {
        const extras = [];
        if (ctx.leadDays > 0) {
            extras.push(
                $__("Lead period: %s days before start").format(ctx.leadDays)
            );
        }
        if (ctx.trailDays > 0) {
            extras.push(
                $__("Trail period: %s days after return").format(ctx.trailDays)
            );
        }
        const detail = extras.length > 0 ? ". " + extras.join(". ") : "";
        return $__("Select a start date") + detail + suffix;
    }

    if (ctx.isSelectingEnd) {
        const detail =
            ctx.trailDays > 0
                ? ". " +
                  $__("Trail period: %s days after return").format(
                      ctx.trailDays
                  )
                : "";
        return $__("Select an end date") + detail + suffix;
    }

    return null;
}

/**
 * Collect all marker reason strings for a date from the unavailableByDate map.
 * @param {Object} unavailableByDate
 * @param {string} dateKey - YYYY-MM-DD
 * @returns {Set<string>}
 */
function collectMarkerReasons(unavailableByDate, dateKey) {
    const reasons = new Set();
    const entry = unavailableByDate?.[dateKey];
    if (!entry) return reasons;

    Object.values(entry).forEach(itemReasons => {
        if (itemReasons instanceof Set) {
            itemReasons.forEach(r => reasons.add(r));
        } else if (Array.isArray(itemReasons)) {
            itemReasons.forEach(r => reasons.add(r));
        }
    });
    return reasons;
}
