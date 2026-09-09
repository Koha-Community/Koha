<template>
    <fieldset class="step-block">
        <legend class="step-header">
            {{ stepNumber }}.
            {{ $__("Select booking period") }}
        </legend>

        <Alert
            v-if="constraintParts.length > 0"
            variant="info"
            extra-class="booking-constraint-info"
        >
            <strong>{{ $__("Booking constraints active:") }}</strong>
            <ul>
                <li v-for="part in constraintParts" :key="part">
                    {{ part }}
                </li>
            </ul>
        </Alert>

        <div class="form-group">
            <label for="booking_period" class="required">{{
                $__("Booking period")
            }}</label>
            <div class="booking-date-picker">
                <BookingCalendar
                    ref="pickerRef"
                    :model-value="pickerModelValue"
                    :viewport="initialViewport"
                    :min-date="minDate"
                    :disabled="composedDisabled"
                    :markers-by-date="markersByDate"
                    :class-by-date="classByDate"
                    :input-disabled="!calendarEnabled"
                    @update:model-value="store.setSelectedDates"
                    @update:viewport="onUpdateViewport"
                    @day-hover="onDayHover"
                    @day-leave="onDayLeave"
                    @select-attempt-blocked="onSelectAttemptBlocked"
                    @ready="onPickerReady"
                />
                <div class="booking-date-picker-append">
                    <button
                        type="button"
                        class="btn btn-outline-secondary"
                        :disabled="!calendarEnabled"
                        :title="$__('Clear selected dates')"
                        @click="clearDateRange"
                    >
                        <i class="fa fa-times" aria-hidden="true"></i>
                        <span class="visually-hidden">{{
                            $__("Clear selected dates")
                        }}</span>
                    </button>
                </div>
            </div>
            <span class="required">{{ $__("Required") }}</span>
        </div>

        <div v-if="errorMessage" class="alert alert-danger mt-2">
            {{ errorMessage }}
        </div>
    </fieldset>
</template>

<script setup lang="ts">
import { computed, inject, onBeforeUnmount, ref, useId } from "vue";
import Alert from "../Alert.vue";
import BookingCalendar from "./BookingCalendar.vue";
import type { useBookingStore } from "../../stores/bookings";
import { storeToRefs } from "pinia";
import { $__ } from "@koha-vue/i18n";
import { formatApiError } from "@fetch/api-error";
import {
    getBookingMarkersForDate,
    getDateFeedbackMessage,
    getMarkerDescription,
} from "../../lib/booking/markers.js";
import {
    findAdjacentBufferDates,
    leadWindowConflicts,
    myBufferDates,
    trailWindowConflicts,
} from "../../lib/booking/availability/predicate.js";
import { formatYMD, toDay } from "../../lib/booking/dates.js";
import type { CalendarMarker } from "../../lib/booking/types/bookings.d.ts";

withDefaults(
    defineProps<{
        stepNumber: number;
        calendarEnabled?: boolean;
        errorMessage?: string;
    }>(),
    {
        calendarEnabled: true,
        errorMessage: "",
    }
);

const emit = defineEmits<{
    (e: "clear-dates"): void;
}>();

const CLASS_EXISTING_LEAD_ADJACENT = "booking-day--existing-lead-adjacent";
const CLASS_EXISTING_TRAIL_ADJACENT = "booking-day--existing-trail-adjacent";
const CLASS_MY_LEAD_BUFFER = "booking-day--my-lead-buffer";
const CLASS_MY_TRAIL_BUFFER = "booking-day--my-trail-buffer";
const CLASS_RUN_START = "booking-day--run-start";
const CLASS_RUN_END = "booking-day--run-end";
// Gate the clash colours on a genuine conflict (leadWindowConflicts/
// trailWindowConflicts - the same "every relevant item actually
// conflicts somewhere in the window" test the disable logic uses), not
// merely on the two bands' date ranges happening to touch. In "any
// item" mode, existing-lead/trail-adjacent lights up as soon as ONE
// candidate item is tagged (see findAdjacentBufferDates), which can
// coincide with my-buffer on days that don't actually block a
// different, still-free item - a clash colour there would be
// misleading, not just decorative.
const CLASS_MY_LEAD_REAL_CONFLICT = "booking-day--my-lead-real-conflict";
const CLASS_MY_TRAIL_REAL_CONFLICT = "booking-day--my-trail-real-conflict";
// Marks the boundary date itself (the anchor, or the hovered candidate
// start/end) when a lead/trail band sits flush against it, so its own
// native flatpickr rounding can be suppressed on that side - see
// applyMyBuffer.
const CLASS_ADJOINS_LEAD = "booking-day--adjoins-lead";
const CLASS_ADJOINS_TRAIL = "booking-day--adjoins-trail";
const ADJACENCY_CLASSES = [
    CLASS_EXISTING_LEAD_ADJACENT,
    CLASS_EXISTING_TRAIL_ADJACENT,
    CLASS_MY_LEAD_BUFFER,
    CLASS_MY_TRAIL_BUFFER,
    CLASS_RUN_START,
    CLASS_RUN_END,
    CLASS_MY_LEAD_REAL_CONFLICT,
    CLASS_MY_TRAIL_REAL_CONFLICT,
    CLASS_ADJOINS_LEAD,
    CLASS_ADJOINS_TRAIL,
];

const componentId = useId();
const dayDetailsId = `booking-day-details-${componentId}`;
const feedbackId = `booking-feedback-${componentId}`;

type BookingStore = ReturnType<typeof useBookingStore>;
const store = inject<BookingStore>("bookingStore") as BookingStore;
const {
    bookableItems,
    selectedDateRange,
    holidays,
    pickerModelValue,
    minDate,
    dateRangeConstraint,
    maxBookingPeriod,
    disabledFn,
    disabledByDate,
    markersByDate,
    classByDate,
    rangeAnchor,
    relevantItemIds,
    bufferConfig,
} = storeToRefs(store);
interface PickerExposed {
    clear: () => void;
}
const pickerRef = ref<PickerExposed | null>(null);

const constraintParts = computed((): string[] => {
    const period = maxBookingPeriod.value;
    const { leadDays, trailDays } = bufferConfig.value;
    const parts: string[] = [];

    if (dateRangeConstraint.value && (period === null || period > 0)) {
        const baseMessages: Record<string, string> = {
            issuelength: period
                ? $__(
                      "Booking period limited to checkout length (%s days)"
                  ).format(period)
                : $__("Booking period limited to checkout length"),
            issuelength_with_renewals: period
                ? $__(
                      "Booking period limited to checkout length with renewals (%s days)"
                  ).format(period)
                : $__(
                      "Booking period limited to checkout length with renewals"
                  ),
            default: period
                ? $__(
                      "Booking period limited by circulation rules (%s days)"
                  ).format(period)
                : $__("Booking period limited by circulation rules"),
        };
        parts.push(
            baseMessages[dateRangeConstraint.value] || baseMessages.default
        );
    }

    if (leadDays > 0) {
        parts.push($__("Lead period: %s days before start").format(leadDays));
    }
    if (trailDays > 0) {
        parts.push($__("Trail period: %s days after return").format(trailDays));
    }

    return parts;
});

const initialViewport = computed(() => {
    const v = pickerModelValue.value;
    const anchor = Array.isArray(v) ? v[0] : v;
    if (anchor instanceof Date) {
        return { year: anchor.getFullYear(), month: anchor.getMonth() };
    }
    return undefined;
});

// BookingCalendar accepts a (Date) => DisabledSpec | null function for `:disabled`.
// disabledFn carries the full validation logic (past dates, lead/trail,
// range overlap) but its boolean output loses severity. disabledByDate
// is a Map<YMD, DisabledSpec> that flags holidays as soft when an anchor
// is set so ranges can cross them. Hard validation wins; otherwise we
// surface the Map's severity (typically soft for holiday-with-anchor).
const composedDisabled = computed(() => {
    const fn = disabledFn.value;
    const map = disabledByDate.value;
    return (date: Date) => {
        if (fn(date)) {
            return { reason: $__("Unavailable"), severity: "hard" as const };
        }
        const ymd = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
        return map.get(ymd) ?? null;
    };
});

let lastDescribedElement: HTMLElement | null = null;

/**
 * Map every currently-rendered flatpickr day element by its YYYY-MM-DD
 * key, so adjacency/buffer-preview classes can be patched onto cells
 * other than the one actually hovered.
 *
 * @param {HTMLElement|null} container Flatpickr calendar container.
 * @returns {Map<string, HTMLElement>} Day elements keyed by date.
 */
function buildDayElementMap(
    container: HTMLElement | null
): Map<string, HTMLElement> {
    const map = new Map<string, HTMLElement>();
    if (!container) return map;
    container
        .querySelectorAll<HTMLElement & { dateObj?: Date }>(".flatpickr-day")
        .forEach(day => {
            if (!day.dateObj) return;
            map.set(formatYMD(day.dateObj), day);
        });
    return map;
}

// Elements this module has added an adjacency/buffer-preview class to,
// so the next hover pass (or leaving the calendar) can strip them again
// without having to re-derive which dates they came from.
let adjacencyElements: Set<HTMLElement> = new Set();

/**
 * Remove every adjacency/buffer-preview class previously applied.
 *
 * @returns {void}
 */
function clearAdjacencyClasses(): void {
    adjacencyElements.forEach(el => el.classList.remove(...ADJACENCY_CLASSES));
    adjacencyElements = new Set();
}

/**
 * Apply one adjacency/buffer-preview class to a set of dates, tracking
 * the touched elements so clearAdjacencyClasses can find them again.
 *
 * dates is always a chronologically-ordered, contiguous run (both
 * findAdjacentBufferDates and myBufferDates guarantee this). Which
 * end(s) may round is governed by `edges` rather than always both:
 * lead/trail bands always sit flush against a specific anchor/hover
 * date on one side (the old UI never rounded that side - only the far
 * edge, away from the anchor, ever got a cap), whereas an Unavailable
 * run has two genuinely free ends. See the CSS in BookingForm.vue for
 * how --run-start/--run-end translate to border-radius.
 *
 * @param {Map<string, HTMLElement>} dayMap Day elements keyed by date.
 * @param {string[]} dates YYYY-MM-DD keys to mark, in run order.
 * @param {string} className Class to apply.
 * @param {"both"|"start"|"end"} [edges="both"] Which run end(s) may round.
 * @returns {void}
 */
function applyAdjacencyClass(
    dayMap: Map<string, HTMLElement>,
    dates: string[],
    className: string,
    edges: "both" | "start" | "end" = "both"
): void {
    dates.forEach((ymd, index) => {
        const el = dayMap.get(ymd);
        if (!el) return;
        el.classList.add(className);
        if (index === 0 && (edges === "both" || edges === "start")) {
            el.classList.add(CLASS_RUN_START);
        }
        if (
            index === dates.length - 1 &&
            (edges === "both" || edges === "end")
        ) {
            el.classList.add(CLASS_RUN_END);
        }
        adjacencyElements.add(el);
    });
}

/**
 * Replace booking-owned descriptions on a calendar day.
 *
 * @param {HTMLElement|null} element Calendar day to update.
 * @param {string[]} descriptionIds Booking description element IDs.
 * @returns {void}
 */
function setDayDescriptions(
    element: HTMLElement | null,
    descriptionIds: string[] = []
): void {
    if (lastDescribedElement && lastDescribedElement !== element) {
        setDayDescriptions(lastDescribedElement);
    }
    if (!element) return;

    const managedIds = new Set([dayDetailsId, feedbackId]);
    const existing = (element.getAttribute("aria-describedby") || "")
        .split(/\s+/)
        .filter(id => id && !managedIds.has(id));
    const ids = [...existing, ...descriptionIds];
    if (ids.length > 0) {
        element.setAttribute("aria-describedby", ids.join(" "));
    } else {
        element.removeAttribute("aria-describedby");
    }
    lastDescribedElement = descriptionIds.length > 0 ? element : null;
}

/**
 * Hide marker details and clear hover-specific day state.
 *
 * @returns {void}
 */
function hideDayDetails(): void {
    if (dayDetailsPanel) updateDayDetailsPanel(dayDetailsPanel, [], 0);
    clearAdjacencyClasses();
    setDayDescriptions(lastDescribedElement);
}

// Hover feedback bar: a contextual <div> appended inside flatpickr's
// calendarContainer that explains why a day is disabled or what the user
// can do next. Reuses the .booking-hover-feedback CSS shipped in
// BookingForm.vue. Hides are deferred one frame so rapid movement
// between adjacent days doesn't flicker.
let feedbackBar: HTMLDivElement | null = null;
let feedbackHideTimer: number | null = null;
let dayDetailsPanel: HTMLDivElement | null = null;
let calendarContainer: HTMLElement | null = null;

type FeedbackVariant = "info" | "warning" | "danger";

/**
 * Return the calendar legend, creating it when necessary.
 *
 * Inserted as the calendar's first child, above the month/year header
 * (.flatpickr-months) - a real child of flatpickr's own container
 * rather than a conditionally-rendered Vue block, so it shows and hides
 * with the calendar for free instead of needing its own open/close
 * tracking. Only means anything once you're looking at coloured days,
 * so it has no reason to occupy space while the picker is closed.
 *
 * @param {HTMLElement} container Flatpickr calendar container.
 * @returns {HTMLDivElement} Calendar-owned legend element.
 */
function ensureLegend(container: HTMLElement): HTMLDivElement {
    let legend = container.querySelector<HTMLDivElement>(".calendar-legend");
    if (!legend) {
        legend = document.createElement("div");
        legend.className = "calendar-legend";
        const entries: Array<[string, string]> = [
            ["selected", $__("Selected period")],
            ["booked", $__("Unavailable")],
            ["partial", $__("Some items unavailable")],
            ["lead", $__("Lead period")],
            ["trail", $__("Trail period")],
            // Both clash directions share one colour (a clash is a
            // clash), so one legend entry covers both - which direction
            // applies was never shown anywhere but this legend text, and
            // showing it twice for an identical swatch was confusing,
            // not informative. Either clash-* class works here since
            // both resolve to the same --booking-clash-*-bg value.
            ["clash-trail-lead", $__("Lead/trail conflict")],
            ["holiday", $__("Library closed")],
        ];
        entries.forEach(([kind, label], index) => {
            const dot = document.createElement("span");
            dot.className = `booking-marker-dot booking-marker-dot--${kind}${
                index > 0 ? " ms-3" : ""
            }`;
            legend.appendChild(dot);
            legend.appendChild(document.createTextNode(label));
        });
        container.insertBefore(
            legend,
            container.querySelector(".flatpickr-months")
        );
    }
    return legend;
}

/**
 * Return the calendar feedback bar, creating it when necessary.
 *
 * @param {HTMLElement} container Flatpickr calendar container.
 * @returns {HTMLDivElement} Calendar-owned feedback element.
 */
function ensureFeedbackBar(container: HTMLElement): HTMLDivElement {
    let bar = container.querySelector<HTMLDivElement>(
        ".booking-hover-feedback"
    );
    if (!bar) {
        bar = document.createElement("div");
        bar.className = "booking-hover-feedback";
        bar.id = feedbackId;
        bar.setAttribute("role", "status");
        bar.setAttribute("aria-live", "polite");
        container.appendChild(bar);
    }
    return bar;
}

/**
 * Return the calendar day-details panel, creating it when necessary.
 *
 * Sits directly below the hover-feedback bar and lists the booked/
 * checked-out items (with barcode) for the hovered or focused day - the
 * one thing colour and the feedback bar can't say on their own. Anchored
 * in the calendar's own layout so it never overlaps the day cells it
 * describes.
 *
 * @param {HTMLElement} container Flatpickr calendar container.
 * @returns {HTMLDivElement} Calendar-owned day-details element.
 */
function ensureDayDetailsPanel(container: HTMLElement): HTMLDivElement {
    let panel = container.querySelector<HTMLDivElement>(".booking-day-details");
    if (!panel) {
        panel = document.createElement("div");
        panel.className = "booking-day-details";
        panel.id = dayDetailsId;
        panel.setAttribute("role", "status");
        panel.setAttribute("aria-live", "polite");
        container.appendChild(panel);
    }
    return panel;
}

/**
 * Render a "x of y items booked" summary plus the marker list for a day
 * into the day-details panel, or collapse the panel when there is
 * nothing to show.
 *
 * @param {HTMLDivElement} panel Calendar day-details element.
 * @param {CalendarMarker[]} markers Booked/checked-out markers to describe, already scoped to relevantItemIds.
 * @param {number} totalRelevant Count of relevant items (the same scope the markers are filtered to).
 * @returns {void}
 */
function updateDayDetailsPanel(
    panel: HTMLDivElement,
    markers: CalendarMarker[],
    totalRelevant: number
): void {
    panel.replaceChildren();
    if (markers.length === 0) {
        panel.classList.remove("booking-day-details--visible");
        return;
    }
    const summary = document.createElement("div");
    summary.className = "booking-day-details-summary";
    summary.appendChild(
        document.createTextNode(
            $__("%s of %s items booked").format(markers.length, totalRelevant)
        )
    );
    panel.appendChild(summary);
    for (const marker of markers) {
        const row = document.createElement("div");
        row.className = "booking-day-details-row";
        const dot = document.createElement("span");
        dot.className = `booking-marker-dot booking-marker-dot--${marker.type}`;
        row.appendChild(dot);
        row.appendChild(document.createTextNode(getMarkerDescription(marker)));
        panel.appendChild(row);
    }
    panel.classList.add("booking-day-details--visible");
}

/**
 * Show contextual day feedback or schedule it to be hidden.
 *
 * @param {HTMLDivElement} bar Calendar feedback element.
 * @param {{message: string, variant: FeedbackVariant}|null} feedback Feedback to show.
 * @returns {void}
 */
function updateFeedbackBar(
    bar: HTMLDivElement,
    feedback: { message: string; variant: FeedbackVariant } | null
): void {
    if (!feedback) {
        if (feedbackHideTimer == null) {
            feedbackHideTimer = window.setTimeout(() => {
                feedbackHideTimer = null;
                bar.classList.remove(
                    "booking-hover-feedback--visible",
                    "booking-hover-feedback--info",
                    "booking-hover-feedback--warning",
                    "booking-hover-feedback--danger"
                );
            }, 16);
        }
        return;
    }
    if (feedbackHideTimer != null) {
        clearTimeout(feedbackHideTimer);
        feedbackHideTimer = null;
    }
    bar.textContent = feedback.message;
    bar.classList.remove(
        "booking-hover-feedback--info",
        "booking-hover-feedback--warning",
        "booking-hover-feedback--danger"
    );
    bar.classList.add(
        "booking-hover-feedback--visible",
        `booking-hover-feedback--${feedback.variant}`
    );
}

/**
 * Hide contextual feedback when the pointer leaves the calendar.
 *
 * @returns {void}
 */
function onCalendarLeave(): void {
    if (feedbackBar) updateFeedbackBar(feedbackBar, null);
    if (dayDetailsPanel) updateDayDetailsPanel(dayDetailsPanel, [], 0);
    clearAdjacencyClasses();
}

/**
 * Attach feedback behavior after Flatpickr creates its calendar.
 *
 * @param {{calendarContainer?: HTMLElement}} instance Flatpickr instance.
 * @returns {void}
 */
function onPickerReady(instance: { calendarContainer?: HTMLElement }): void {
    if (!instance.calendarContainer) return;
    calendarContainer = instance.calendarContainer;
    ensureLegend(calendarContainer);
    feedbackBar = ensureFeedbackBar(calendarContainer);
    dayDetailsPanel = ensureDayDetailsPanel(calendarContainer);
    calendarContainer.addEventListener("mouseleave", onCalendarLeave);
}

onBeforeUnmount(() => {
    if (feedbackHideTimer != null) {
        clearTimeout(feedbackHideTimer);
        feedbackHideTimer = null;
    }
    if (calendarContainer) {
        calendarContainer.removeEventListener("mouseleave", onCalendarLeave);
        calendarContainer = null;
    }
    feedbackBar = null;
    dayDetailsPanel = null;
});

/**
 * Present marker and availability feedback for an interacted calendar day.
 *
 * @param {{date: Date, ymd: string, disabled?: {severity?: "hard"|"soft"}, element?: HTMLElement|null, trigger?: "pointer"|"focus"}} payload Day interaction metadata.
 * @returns {void}
 */
function onDayHover(payload: {
    date: Date;
    ymd: string;
    disabled?: { severity?: "hard" | "soft" };
    element?: HTMLElement | null;
    trigger?: "pointer" | "focus";
}): void {
    const markers = getBookingMarkersForDate(
        store.unavailableByDate,
        payload.ymd,
        bookableItems.value || []
    );

    clearAdjacencyClasses();
    if (calendarContainer) {
        const dayMap = buildDayElementMap(calendarContainer);

        const { leadDays, trailDays } = bufferConfig.value;

        // Existing bookings' lead/trail: only the booking immediately
        // adjacent to the hovered gap gets coloured (see
        // findAdjacentBufferDates) - every other existing booking stays a
        // completely ordinary-looking date until hovered near instead.
        const { leadDates, trailDates } = findAdjacentBufferDates(
            store.unavailableByDate,
            payload.ymd,
            relevantItemIds.value,
            leadDays,
            trailDays
        );
        applyAdjacencyClass(
            dayMap,
            leadDates,
            CLASS_EXISTING_LEAD_ADJACENT,
            "start"
        );
        applyAdjacencyClass(
            dayMap,
            trailDates,
            CLASS_EXISTING_TRAIL_ADJACENT,
            "end"
        );

        // My own prospective booking's lead/trail buffer. Before a start is
        // chosen, both bands preview relative to the hovered candidate
        // (matching the old UI, whose trail calculation was always
        // hover-relative and never branched on whether a start was
        // chosen - only lead did). Once a start is chosen, the lead
        // buffer is fixed to it, and the trail buffer previews live
        // relative to whatever candidate end is currently hovered.
        // Boundaries are derived from payload.ymd (already a plain
        // calendar-day string, like findAdjacentBufferDates uses) rather
        // than payload.date - comparing/arithmetic on the raw Date risks
        // a timezone-dependent off-by-one that the string form
        // sidesteps entirely.
        const anchor = rangeAnchor.value;
        const hoveredDay = toDay(payload.ymd);
        const itemIds = relevantItemIds.value;

        /**
         * Apply a my-buffer band, plus its "real conflict" gate class
         * when the window actually conflicts (see the constants above).
         *
         * A lead band always sits flush against its boundary date (the
         * anchor, or the hovered candidate start) on its near side, and
         * a trail band always sits flush against its boundary on its
         * near side too - old UI never rounded that side, only the far
         * edge (see applyAdjacencyClass's edges param). The boundary
         * cell itself is marked with an "adjoins" class so its own
         * native flatpickr rounding can be suppressed on that side too,
         * keeping the whole strip - band, then boundary cell, then
         * whatever follows - reading as continuous rather than one more
         * independently-rounded pill.
         *
         * @param {import('dayjs').Dayjs|Date} rawBoundary Lead/trail boundary date.
         * @param {number} days Lead/trail day count.
         * @param {"lead"|"trail"} kind Which buffer this is.
         * @param {string} bufferClass CLASS_MY_LEAD_BUFFER or CLASS_MY_TRAIL_BUFFER.
         * @param {string} conflictClass Gate class to add when genuinely conflicting.
         * @returns {void}
         */
        function applyMyBuffer(
            rawBoundary,
            days,
            kind,
            bufferClass,
            conflictClass
        ) {
            const boundary = toDay(rawBoundary);
            const dates = myBufferDates(boundary, days, kind);
            if (dates.length === 0) return;
            const edges = kind === "lead" ? "start" : "end";
            applyAdjacencyClass(dayMap, dates, bufferClass, edges);
            const conflicts =
                kind === "lead"
                    ? leadWindowConflicts(
                          store.unavailableByDate,
                          boundary,
                          days,
                          null,
                          itemIds
                      )
                    : trailWindowConflicts(
                          store.unavailableByDate,
                          boundary,
                          days,
                          null,
                          itemIds
                      );
            if (conflicts) {
                applyAdjacencyClass(dayMap, dates, conflictClass, edges);
            }
            const boundaryEl = dayMap.get(boundary.format("YYYY-MM-DD"));
            if (boundaryEl) {
                const adjoinsClass =
                    kind === "lead" ? CLASS_ADJOINS_LEAD : CLASS_ADJOINS_TRAIL;
                boundaryEl.classList.add(adjoinsClass);
                adjacencyElements.add(boundaryEl);
            }
        }

        if (!anchor) {
            applyMyBuffer(
                hoveredDay,
                leadDays,
                "lead",
                CLASS_MY_LEAD_BUFFER,
                CLASS_MY_LEAD_REAL_CONFLICT
            );
            applyMyBuffer(
                hoveredDay,
                trailDays,
                "trail",
                CLASS_MY_TRAIL_BUFFER,
                CLASS_MY_TRAIL_REAL_CONFLICT
            );
        } else {
            applyMyBuffer(
                anchor,
                leadDays,
                "lead",
                CLASS_MY_LEAD_BUFFER,
                CLASS_MY_LEAD_REAL_CONFLICT
            );
            if (!hoveredDay.isBefore(toDay(anchor), "day")) {
                applyMyBuffer(
                    hoveredDay,
                    trailDays,
                    "trail",
                    CLASS_MY_TRAIL_BUFFER,
                    CLASS_MY_TRAIL_REAL_CONFLICT
                );
            }
        }
    }

    let hasFeedback = false;
    if (feedbackBar) {
        try {
            const isHardDisabled =
                !!payload.disabled && payload.disabled.severity !== "soft";
            const feedback = getDateFeedbackMessage(payload.date, {
                isDisabled: isHardDisabled,
                selectedDateRange: selectedDateRange.value,
                leadDays: bufferConfig.value.leadDays,
                trailDays: bufferConfig.value.trailDays,
                maxPeriod: bufferConfig.value.maxPeriod,
                unavailableByDate: store.unavailableByDate,
                holidays: holidays.value || [],
            });
            updateFeedbackBar(feedbackBar, feedback);
            hasFeedback = !!feedback;
        } catch {
            updateFeedbackBar(feedbackBar, null);
        }
    }

    // The day-details panel's one job is a "x of y items booked" summary
    // plus barcodes for those booked/checked-out items on this exact date
    // - lead/trail/holiday/limited-availability are already conveyed by
    // the day's own colour, the constraint-info box, and the top feedback
    // bar, so restating them here would be a third copy of the same
    // information. Scoped to relevantItemIds so the count and the list
    // agree with the same "every relevant item" invariant the disable
    // logic and day colour already use (see the UX spec §6) - an item
    // outside the current selection scope (a different item type, or a
    // specific item nobody picked) shouldn't inflate either number.
    const relevantIds = relevantItemIds.value;
    const relevantIdSet = new Set(relevantIds);
    const dayDetailMarkers = markers.filter(
        m =>
            (m.type === "booked" || m.type === "checked-out") &&
            relevantIdSet.has(m.item)
    );
    if (dayDetailsPanel)
        updateDayDetailsPanel(
            dayDetailsPanel,
            dayDetailMarkers,
            relevantIds.length
        );

    if (!payload.element || dayDetailMarkers.length === 0) {
        if (payload.trigger === "focus" && payload.element) {
            setDayDescriptions(
                payload.element,
                hasFeedback ? [feedbackId] : []
            );
        }
        return;
    }
    if (payload.trigger === "focus") {
        setDayDescriptions(payload.element, [
            ...(hasFeedback ? [feedbackId] : []),
            dayDetailsId,
        ]);
    }
}

/**
 * Clear day-details and feedback state after leaving a calendar day.
 *
 * @returns {void}
 */
function onDayLeave(): void {
    hideDayDetails();
    if (feedbackBar) updateFeedbackBar(feedbackBar, null);
}

/**
 * Refresh booking context for a newly visible calendar month.
 *
 * @param {{year: number, month: number}} vp Visible calendar month.
 * @returns {void}
 */
function onUpdateViewport(vp: { year: number; month: number }): void {
    const start = new Date(vp.year, vp.month, 1);
    const end = new Date(vp.year, vp.month + 1, 0);
    store.changeViewport({ start, end }).catch((error: Error) => {
        if (error?.name !== "AbortError") {
            store.setError(formatApiError(error), "api");
        }
    });
}

/**
 * Publish the reason a calendar day could not be selected.
 *
 * @param {{date: Date, reason: string}} p Blocked date and reason.
 * @returns {void}
 */
function onSelectAttemptBlocked(p: { date: Date; reason: string }): void {
    if (p.reason) store.setError(p.reason, "blocked_date");
}

/**
 * Clear the picker, store period, feedback, and parent form state.
 *
 * @returns {void}
 */
const clearDateRange = (): void => {
    pickerRef.value?.clear();
    store.setSelectedDates(null);
    hideDayDetails();
    emit("clear-dates");
};
</script>

<style scoped>
.form-group {
    margin-bottom: var(--booking-space-lg);
}

.booking-date-picker {
    display: flex;
    align-items: center;
}

:deep(.booking-flatpickr-wrapper) {
    flex: 1;
    margin-right: var(--booking-space-md);
}

:deep(.booking-flatpickr-input) {
    width: 100%;
}

.booking-date-picker-append {
    flex-shrink: 0;
}

.booking-constraint-info {
    margin-top: var(--booking-space-md);
    margin-bottom: var(--booking-space-lg);
}

.calendar-legend {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: var(--booking-space-md);
    font-size: var(--booking-text-sm);
    margin-top: var(--booking-space-lg);
}

.alert {
    padding: calc(var(--booking-space-lg) * 0.75) var(--booking-space-lg);
    border: var(--booking-border-width) solid transparent;
    border-radius: var(--booking-border-radius-sm);
}

.alert-info {
    color: hsl(var(--booking-info-hue), 80%, 20%);
    background-color: hsl(var(--booking-info-hue), 40%, 90%);
    border-color: hsl(var(--booking-info-hue), 40%, 70%);
}

.alert-danger {
    color: hsl(var(--booking-danger-hue), 80%, 20%);
    background-color: hsl(var(--booking-danger-hue), 40%, 90%);
    border-color: hsl(var(--booking-danger-hue), 40%, 70%);
}
</style>
