<template>
    <fieldset class="step-block">
        <legend class="step-header">
            {{ stepNumber }}.
            {{ $__("Select booking period") }}
        </legend>

        <div class="calendar-legend">
            <span
                class="booking-marker-dot booking-marker-dot--selected"
            ></span>
            {{ $__("Selected period") }}
            <span
                class="booking-marker-dot booking-marker-dot--booked ms-3"
            ></span>
            {{ $__("Unavailable") }}
            <span
                class="booking-marker-dot booking-marker-dot--lead-theoretical ms-3"
            ></span>
            {{ $__("Lead or trail period") }}
        </div>

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

        <Alert
            v-if="
                dateRangeConstraint &&
                (maxBookingPeriod === null || maxBookingPeriod > 0)
            "
            variant="info"
            extra-class="booking-constraint-info"
        >
            <small>
                <strong>{{ $__("Booking constraint active:") }}</strong>
                {{ constraintHelpText }}
            </small>
        </Alert>

        <div v-if="errorMessage" class="alert alert-danger mt-2">
            {{ errorMessage }}
        </div>
    </fieldset>
    <Teleport to="body">
        <div
            v-if="tooltip.visible"
            :id="tooltipId"
            class="booking-tooltip"
            :style="{
                position: 'absolute',
                zIndex: 2147483647,
                whiteSpace: 'nowrap',
                top: `${tooltip.y}px`,
                left: `${tooltip.x}px`,
                transform: 'translateY(-50%)',
            }"
            role="tooltip"
            aria-live="polite"
            aria-atomic="true"
        >
            <div
                v-for="marker in tooltip.markers"
                :key="marker.type + ':' + (marker.barcode || marker.item)"
            >
                <span
                    :class="[
                        'booking-marker-dot',
                        `booking-marker-dot--${marker.type}`,
                    ]"
                />
                {{ getMarkerDescription(marker) }}
            </div>
        </div>
    </Teleport>
</template>

<script setup lang="ts">
import { computed, inject, onBeforeUnmount, reactive, ref, useId } from "vue";
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
import type { CalendarMarker } from "../../lib/booking/types/bookings.d.ts";

interface TooltipState {
    markers: CalendarMarker[];
    visible: boolean;
    x: number;
    y: number;
}

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

const CLASS_BOOKING_DAY_HOVER_LEAD = "booking-day--hover-lead";
const CLASS_BOOKING_DAY_HOVER_TRAIL = "booking-day--hover-trail";

const componentId = useId();
const tooltipId = `booking-tooltip-${componentId}`;
const feedbackId = `booking-feedback-${componentId}`;

type BookingStore = ReturnType<typeof useBookingStore>;
const store = inject<BookingStore>("bookingStore") as BookingStore;
const {
    bookableItems,
    selectedDateRange,
    circulationRules,
    holidays,
    pickerModelValue,
    minDate,
    dateRangeConstraint,
    maxBookingPeriod,
    disabledFn,
    disabledByDate,
    markersByDate,
    classByDate,
} = storeToRefs(store);
interface PickerExposed {
    clear: () => void;
}
const pickerRef = ref<PickerExposed | null>(null);

const constraintHelpText = computed((): string => {
    if (!dateRangeConstraint.value) return "";
    const period = maxBookingPeriod.value;

    const baseMessages: Record<string, string> = {
        issuelength: period
            ? $__("Booking period limited to checkout length (%s days)").format(
                  period
              )
            : $__("Booking period limited to checkout length"),
        issuelength_with_renewals: period
            ? $__(
                  "Booking period limited to checkout length with renewals (%s days)"
              ).format(period)
            : $__("Booking period limited to checkout length with renewals"),
        default: period
            ? $__(
                  "Booking period limited by circulation rules (%s days)"
              ).format(period)
            : $__("Booking period limited by circulation rules"),
    };

    return baseMessages[dateRangeConstraint.value] || baseMessages.default;
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

const tooltip = reactive<TooltipState>({
    markers: [],
    visible: false,
    x: 0,
    y: 0,
});

// Track the last hovered cell so we can strip lead/trail hover classes
// when the hover moves to a new cell. Mirrors the per-cell mouseout
// behavior the legacy `events.mjs` adapter implemented.
let lastHoverElement: HTMLElement | null = null;
let lastDescribedElement: HTMLElement | null = null;

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

    const managedIds = new Set([tooltipId, feedbackId]);
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
 * Remove booking lead and trail hover classes from a day.
 *
 * @param {HTMLElement|null} el Calendar day to clear.
 * @returns {void}
 */
function clearHoverClasses(el: HTMLElement | null): void {
    if (!el) return;
    el.classList.remove(
        CLASS_BOOKING_DAY_HOVER_LEAD,
        CLASS_BOOKING_DAY_HOVER_TRAIL
    );
}

/**
 * Hide marker details and clear hover-specific day state.
 *
 * @returns {void}
 */
function hideTooltip(): void {
    tooltip.visible = false;
    clearHoverClasses(lastHoverElement);
    setDayDescriptions(lastDescribedElement);
    lastHoverElement = null;
}

// Hover feedback bar: a contextual <div> appended inside flatpickr's
// calendarContainer that explains why a day is disabled or what the user
// can do next. Reuses the .booking-hover-feedback CSS shipped in
// BookingForm.vue. Hides are deferred one frame so rapid movement
// between adjacent days doesn't flicker.
let feedbackBar: HTMLDivElement | null = null;
let feedbackHideTimer: number | null = null;
let calendarContainer: HTMLElement | null = null;

type FeedbackVariant = "info" | "warning" | "danger";

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
    feedbackBar = ensureFeedbackBar(calendarContainer);
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
    if (lastHoverElement && lastHoverElement !== payload.element) {
        clearHoverClasses(lastHoverElement);
    }
    lastHoverElement = payload.element ?? null;

    const markers = getBookingMarkersForDate(
        store.unavailableByDate,
        payload.ymd,
        bookableItems.value || []
    );

    if (payload.element) {
        const hasLead = markers.some((m: CalendarMarker) => m.type === "lead");
        const hasTrail = markers.some(
            (m: CalendarMarker) => m.type === "trail"
        );
        if (hasLead) {
            payload.element.classList.add(CLASS_BOOKING_DAY_HOVER_LEAD);
        }
        if (hasTrail) {
            payload.element.classList.add(CLASS_BOOKING_DAY_HOVER_TRAIL);
        }
    }

    let hasFeedback = false;
    if (feedbackBar) {
        try {
            const isHardDisabled =
                !!payload.disabled && payload.disabled.severity !== "soft";
            const rules = Array.isArray(circulationRules.value)
                ? circulationRules.value[0] || {}
                : circulationRules.value || {};
            const feedback = getDateFeedbackMessage(payload.date, {
                isDisabled: isHardDisabled,
                selectedDateRange: selectedDateRange.value,
                circulationRules: rules,
                unavailableByDate: store.unavailableByDate,
                holidays: holidays.value || [],
            });
            updateFeedbackBar(feedbackBar, feedback);
            hasFeedback = !!feedback;
        } catch {
            updateFeedbackBar(feedbackBar, null);
        }
    }

    if (!payload.element || markers.length === 0) {
        tooltip.visible = false;
        if (payload.trigger === "focus" && payload.element) {
            setDayDescriptions(
                payload.element,
                hasFeedback ? [feedbackId] : []
            );
        }
        return;
    }
    const rect = payload.element.getBoundingClientRect();
    tooltip.markers = markers;
    tooltip.x = rect.right + 8 + window.scrollX;
    tooltip.y = rect.top + rect.height / 2 + window.scrollY;
    tooltip.visible = true;
    if (payload.trigger === "focus") {
        setDayDescriptions(payload.element, [
            ...(hasFeedback ? [feedbackId] : []),
            tooltipId,
        ]);
    }
}

/**
 * Clear tooltip and feedback state after leaving a calendar day.
 *
 * @returns {void}
 */
function onDayLeave(): void {
    hideTooltip();
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
    hideTooltip();
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

.booking-tooltip {
    background: hsl(var(--booking-warning-hue), 100%, 95%);
    color: hsl(var(--booking-neutral-hue), 20%, 20%);
    border: var(--booking-border-width) solid
        hsl(var(--booking-neutral-hue), 15%, 75%);
    border-radius: var(--booking-border-radius-md);
    box-shadow: 0 0.125rem 0.5rem
        hsla(var(--booking-neutral-hue), 10%, 0%, 0.08);
    padding: calc(var(--booking-space-xs) * 3) calc(var(--booking-space-xs) * 5);
    font-size: var(--booking-text-lg);
    pointer-events: none;
}

.booking-tooltip .booking-marker-dot {
    display: inline-block;
    width: calc(var(--booking-marker-size) * 1.25);
    height: calc(var(--booking-marker-size) * 1.25);
    border-radius: var(--booking-border-radius-full);
    margin: 0 var(--booking-space-xs) 0 0;
    vertical-align: middle;
}
</style>
