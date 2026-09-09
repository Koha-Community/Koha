<template>
    <form
        id="form-booking"
        class="booking-form"
        :action="submitUrl"
        method="post"
        @submit.prevent="handleSubmit"
    >
        <Alert
            :show="showCapacityWarning"
            variant="warning"
            :message="zeroCapacityMessage"
            role="status"
            live="polite"
        />
        <BookingPatronStep
            v-if="showPatronSelect"
            :active="active"
            :model-value="bookingPatron"
            :step-number="stepNumber.patron"
            @update:model-value="handlePatronChange"
        />
        <hr
            v-if="
                showPatronSelect ||
                showItemDetailsSelects ||
                showPickupLocationSelect
            "
        />
        <BookingDetailsStep
            v-if="showItemDetailsSelects || showPickupLocationSelect"
            :pickup-library-id="selectedPickupLibraryId"
            :itemtype-id="bookingItemtypeId"
            :item-id="bookingItemId"
            :step-number="stepNumber.details"
            :details-enabled="readiness.dataReady && !loading.pickupLocations"
            :show-item-details-selects="showItemDetailsSelects"
            :show-pickup-location-select="showPickupLocationSelect"
            :selected-patron="bookingPatron"
            :patron-required="showPatronSelect"
            @update:pickup-library-id="
                value =>
                    handleBookingContextChange({
                        pickupLibraryId: value,
                    })
            "
            @update:itemtype-id="
                value =>
                    handleBookingContextChange({
                        itemtypeId: value,
                    })
            "
            @update:item-id="
                value =>
                    handleBookingContextChange({
                        itemId: value,
                    })
            "
        />
        <hr v-if="showItemDetailsSelects || showPickupLocationSelect" />
        <BookingPeriodStep
            :step-number="stepNumber.period"
            :calendar-enabled="readiness.isCalendarReady"
            :error-message="store.error.message"
            @clear-dates="clearDateRange"
        />
    </form>
</template>

<script setup lang="ts">
import { computed, inject, onMounted, onUnmounted, watch } from "vue";
import { storeToRefs } from "pinia";
import { $__ } from "@koha-vue/i18n";
import { formatApiError } from "@fetch/api-error";
import {
    datePart,
    toEndOfDayISO,
    toISO,
    toStartOfDayISO,
} from "../../lib/booking/dates.js";
import type { useBookingStore } from "../../stores/bookings";
import Alert from "../Alert.vue";
import BookingDetailsStep from "./BookingDetailsStep.vue";
import BookingPatronStep from "./BookingPatronStep.vue";
import BookingPeriodStep from "./BookingPeriodStep.vue";
import type {
    CirculationRule,
    Id,
} from "../../lib/booking/types/bookings.d.ts";

type DateRangeConstraintType =
    | "issuelength"
    | "issuelength_with_renewals"
    | "custom"
    | null;
type SubmitType = "api" | "form-submission";

const props = withDefaults(
    defineProps<{
        active?: boolean;
        biblionumber: string | number;
        bookingId?: Id | null;
        itemId?: Id | null;
        patronId?: Id | null;
        pickupLibraryId?: string | null;
        startDate?: string | null;
        endDate?: string | null;
        itemtypeId?: Id | null;
        showPatronSelect?: boolean;
        showItemDetailsSelects?: boolean;
        showPickupLocationSelect?: boolean;
        submitType?: SubmitType;
        submitUrl?: string;
        dateRangeConstraint?: DateRangeConstraintType;
        customDateRangeFormula?:
            | ((rules: CirculationRule) => number | null)
            | null;
    }>(),
    {
        active: false,
        bookingId: null,
        itemId: null,
        patronId: null,
        pickupLibraryId: null,
        startDate: null,
        endDate: null,
        itemtypeId: null,
        showPatronSelect: false,
        showItemDetailsSelects: false,
        showPickupLocationSelect: false,
        submitType: "api",
        submitUrl: "",
        dateRangeConstraint: null,
        customDateRangeFormula: null,
    }
);

const emit = defineEmits<{
    (
        e: "submitted",
        detail: {
            booking: unknown;
            bookingPatron: unknown;
            isUpdate: boolean;
        }
    ): void;
}>();

type BookingStore = ReturnType<typeof useBookingStore>;
const store = inject<BookingStore>("bookingStore") as BookingStore;
const {
    bookingId: currentBookingId,
    bookingItemId,
    bookingPatron,
    bookingItemtypeId,
    pickupLibraryId: selectedPickupLibraryId,
    selectedDateRange,
    loading,
    zeroCapacityMessage,
    showCapacityWarning,
    readiness,
    isSubmitReady,
} = storeToRefs(store);

const submitLoading = computed(() => loading.value.submit);
const submitLabel = computed(() =>
    currentBookingId.value ? $__("Update booking") : $__("Place booking")
);

defineExpose({ isSubmitReady, submitLabel, submitLoading });

const stepNumber = computed(() => {
    let next = 1;
    const patron = props.showPatronSelect ? next++ : 0;
    const details =
        props.showItemDetailsSelects || props.showPickupLocationSelect
            ? next++
            : 0;
    return { patron, details, period: next };
});

const isFormSubmission = computed(() => props.submitType === "form-submission");
let sessionActive = false;

/**
 * Normalize the initial booking dates for the store.
 *
 * @returns {string[]} Selected ISO calendar dates, or an empty range.
 */
function initialDateRange(): string[] {
    if (!props.startDate || !props.endDate) return [];
    return [toISO(datePart(props.startDate)), toISO(datePart(props.endDate))];
}

/**
 * Booking-specific messages for API error codes that a generic error
 * formatter can't distinguish (both render as a plain 400/409 otherwise).
 */
const BOOKING_ERROR_MESSAGES: Record<string, () => string> = {
    booking_would_conflict: () =>
        $__(
            "This booking would conflict with an existing booking or checkout."
        ),
    duplicate_booking_id: () =>
        $__("This booking has already been saved. Refresh and try again."),
};

/**
 * Format an API error for display, preferring a booking-specific message
 * for known conflict/duplicate error codes over the generic formatter.
 *
 * @param {unknown} error API error.
 * @returns {string} User-facing message.
 */
function formatBookingApiError(error: unknown): string {
    const code =
        typeof error === "object" &&
        error !== null &&
        "code" in error &&
        typeof (error as { code?: unknown }).code === "string"
            ? (error as { code: string }).code
            : undefined;

    if (code && code in BOOKING_ERROR_MESSAGES) {
        return BOOKING_ERROR_MESSAGES[code]();
    }
    return formatApiError(error);
}

/**
 * Run a store workflow and publish non-abort failures to the form.
 *
 * @param {() => Promise<unknown>} workflow Workflow operation to run.
 * @returns {Promise<void>}
 */
async function runWorkflow(workflow: () => Promise<unknown>): Promise<void> {
    try {
        await workflow();
    } catch (error) {
        if ((error as Error)?.name === "AbortError") return;
        console.error("Error updating booking form:", error);
        store.setError(formatBookingApiError(error), "api");
    }
}

/**
 * Initialize one create or edit session while the form is active.
 *
 * @returns {void}
 */
function openSession(): void {
    if (sessionActive || !props.active) return;
    sessionActive = true;

    const common = {
        biblionumber: props.biblionumber,
        itemId: props.itemId,
        patronId: props.patronId,
        pickupLibraryId: props.pickupLibraryId,
        itemtypeId: props.itemtypeId,
        selectedDateRange: initialDateRange(),
        dateRangeConstraint: props.dateRangeConstraint,
        customDateRangeFormula: props.customDateRangeFormula,
        showPatronSelect: props.showPatronSelect,
        showItemDetailsSelects: props.showItemDetailsSelects,
        showPickupLocationSelect: props.showPickupLocationSelect,
    };

    if (props.bookingId) {
        runWorkflow(() =>
            store.openForEdit({
                booking: {
                    ...common,
                    bookingId: props.bookingId,
                },
                ...common,
            })
        );
        return;
    }
    runWorkflow(() => store.openForCreate(common));
}

/**
 * Close the active session and invalidate its pending requests.
 *
 * @returns {void}
 */
function closeSession(): void {
    if (!sessionActive) return;
    sessionActive = false;
    store.closeSession();
}

/**
 * Apply a patron selection through the explicit booking workflow.
 *
 * @param {PatronOption|null} value Newly selected patron, or null.
 * @returns {void}
 */
function handlePatronChange(value: (typeof bookingPatron)["value"]): void {
    runWorkflow(() => store.changePatron(value));
}

/**
 * Apply item and pickup context changes through the booking workflow.
 *
 * @param {{pickupLibraryId?: string|null, itemtypeId?: Id|null, itemId?: Id|null}} changes Changed context fields.
 * @returns {void}
 */
function handleBookingContextChange(changes: {
    pickupLibraryId?: string | null;
    itemtypeId?: Id | null;
    itemId?: Id | null;
}): void {
    runWorkflow(() => store.changeBookingContext(changes));
}

/**
 * Clear the selected period and any related form error.
 *
 * @returns {void}
 */
function clearDateRange(): void {
    selectedDateRange.value = [];
    store.clearError();
}

/**
 * Return the page CSRF token used by native form submissions.
 *
 * @returns {string|null} Page token, or null when unavailable.
 */
function getCsrfToken(): string | null {
    const metaToken = document
        .querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
        ?.getAttribute("content");
    if (metaToken) return metaToken;

    return (
        document.querySelector<HTMLInputElement>('input[name="csrf_token"]')
            ?.value || null
    );
}

/**
 * Validate and submit the booking through the API or legacy form endpoint.
 *
 * @param {Event} event Booking form submit event.
 * @returns {Promise<void>}
 */
async function handleSubmit(event: Event): Promise<void> {
    const selectedDates = selectedDateRange.value;

    if (!selectedDates || selectedDates.length === 0) {
        store.setError(
            $__("Please select a valid date range"),
            "invalid_date_range"
        );
        return;
    }

    // The picker works in browser-local dates; the payload carries the
    // selected DATE as day boundaries anchored to the library timezone so
    // it survives the server's round-trip back to library time. Domain math
    // below keeps the local values.
    const localStart = selectedDates[0];
    const localEnd =
        selectedDates.length >= 2 ? selectedDates[1] : selectedDates[0];
    const bookingData: Record<string, unknown> = {
        booking_id: props.bookingId ?? undefined,
        start_date: toStartOfDayISO(localStart),
        end_date: toEndOfDayISO(localEnd),
        pickup_library_id: selectedPickupLibraryId.value,
        biblio_id: props.biblionumber,
        patron_id: bookingPatron.value?.patron_id,
    };

    const itemAssignment = store.resolveItemForPeriod({
        start: localStart,
        end: localEnd,
    });
    if (!itemAssignment.ok) return;
    if (itemAssignment.item_id != null) {
        bookingData.item_id = itemAssignment.item_id;
    } else {
        bookingData.itemtype_id = itemAssignment.itemtype_id;
    }

    if (isFormSubmission.value) {
        const csrfToken = getCsrfToken();
        if (!csrfToken) {
            store.setError(
                $__(
                    "A valid CSRF token could not be found. Please refresh the page and try again."
                ),
                "csrf"
            );
            return;
        }

        const form = event.currentTarget as HTMLFormElement;
        const entries: Array<[string, unknown]> = [
            ...Object.entries(bookingData),
            ["csrf_token", csrfToken],
            ["op", "cud-add"],
        ];
        entries.forEach(([name, value]) => {
            if (value == null) return;
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = String(name);
            input.value = String(value);
            form.appendChild(input);
        });
        form.submit();
        return;
    }

    try {
        const result = await store.saveOrUpdateBooking(bookingData);
        emit("submitted", {
            booking: result,
            bookingPatron: bookingPatron.value,
            isUpdate: !!props.bookingId,
        });
    } catch (error) {
        store.setError(formatBookingApiError(error), "api");
    }
}

watch(
    () => props.active,
    active => {
        if (active) openSession();
        else closeSession();
    }
);

onMounted(openSession);
onUnmounted(closeSession);
</script>

<style>
:root {
    --booking-success-hue: 134;
    --booking-success-bg: hsl(var(--booking-success-hue), 40%, 90%);
    --booking-success-border: hsl(var(--booking-success-hue), 70%, 40%);
    --booking-border-width: 1px;
    --booking-marker-size: max(4px, 0.25em);
    --booking-neutral-hue: 210;
    --booking-holiday-hue: 0;

    /* Feedback-bar / alert variants (not calendar day states) */
    --booking-warning-hue: 45;
    --booking-danger-hue: 354;
    --booking-info-hue: 195;

    /* Selected period (my chosen start..end range) */
    --booking-selected-hue: 48;
    --booking-selected-bg: hsl(var(--booking-selected-hue), 100%, 89%);
    --booking-selected-bg-hover: hsl(var(--booking-selected-hue), 100%, 80%);
    --booking-selected-text: hsl(var(--booking-selected-hue), 60%, 20%);

    /* Unavailable: an existing booking's own occupied days, whether
       booked or checked out - both mean "you can't have this day", so
       they share one colour rather than one each. */
    --booking-unavailable-hue: 300;
    --booking-unavailable-bg: hsl(var(--booking-unavailable-hue), 55%, 88%);
    --booking-unavailable-bg-hover: hsl(
        var(--booking-unavailable-hue),
        55%,
        80%
    );
    --booking-unavailable-text: hsl(var(--booking-unavailable-hue), 70%, 23%);

    /* Lead/trail period - one colour each, shared by both the adjacent
       existing booking's window (hover-scoped, see onDayHover) and my
       own prospective booking's buffer preview. They're the same
       concept (a required lead/trail gap) regardless of whose booking
       it belongs to, so one colour per concept instead of one per
       owner keeps the palette from growing with every new source of
       lead/trail shading. */
    /* Lead/trail lightness is a deliberate mid-tone, not a pale pastel:
       a first-pass pale green for lead (matching the old pastel tier)
       collapsed toward the pale-yellow Selected-period colour under
       protanopia simulation (Machado/Oliveira/Fair 2009 matrices) - see
       core/notes/2026-09-07-bug-41129-booking-calendar-ux-spec.md §1.
       This lightness step is what actually separates them, same
       principle as the clash-vs-lead/trail step below. */
    --booking-lead-hue: 120;
    --booking-lead-bg: hsl(var(--booking-lead-hue), 75%, 72%);
    --booking-lead-bg-hover: hsl(var(--booking-lead-hue), 75%, 64%);
    --booking-lead-text: hsl(var(--booking-lead-hue), 85%, 20%);

    --booking-trail-hue: 205;
    --booking-trail-bg: hsl(var(--booking-trail-hue), 80%, 70%);
    --booking-trail-bg-hover: hsl(var(--booking-trail-hue), 80%, 62%);
    --booking-trail-text: hsl(var(--booking-trail-hue), 90%, 20%);

    /* Clash: my buffer overlaps an adjacent existing booking's buffer.
       A clash is a clash regardless of direction - both directions
       (my-trail-into-existing-lead, my-lead-into-existing-trail) share
       one hue; which one applies is stated in the label text, not the
       colour (see the two marker-dot rules below and the legend). Kept
       as two identically-valued variable groups rather than merged into
       one, to avoid a wider rename across every usage site - do not let
       these two drift apart again. Deliberately darker/more saturated
       than the regular pastel band - at matching pastel lightness these
       read as near-identical by contrast ratio, so the rarer clash
       states need a real lightness step to stay visually distinct, not
       just a hue change. */
    --booking-clash-trail-lead-hue: 260;
    --booking-clash-trail-lead-bg: hsl(
        var(--booking-clash-trail-lead-hue),
        55%,
        68%
    );
    --booking-clash-trail-lead-bg-hover: hsl(
        var(--booking-clash-trail-lead-hue),
        55%,
        60%
    );
    --booking-clash-trail-lead-text: hsl(
        var(--booking-clash-trail-lead-hue),
        65%,
        20%
    );

    --booking-clash-lead-trail-hue: 260;
    --booking-clash-lead-trail-bg: hsl(
        var(--booking-clash-lead-trail-hue),
        55%,
        68%
    );
    --booking-clash-lead-trail-bg-hover: hsl(
        var(--booking-clash-lead-trail-hue),
        55%,
        60%
    );
    --booking-clash-lead-trail-text: hsl(
        var(--booking-clash-lead-trail-hue),
        65%,
        20%
    );

    /* Used only by the day-details panel's marker-dot swatches for
       lead-floor/lead-theoretical/trail-theoretical (see below) - these
       aren't shown on the calendar grid itself, only inside the
       hover-triggered detail panel, so a plain neutral grey is enough
       to tell them apart from the other marker rows there. */
    --booking-buffer-bg: hsl(var(--booking-neutral-hue), 12%, 88%);
    --booking-buffer-text: hsl(var(--booking-neutral-hue), 27%, 23%);

    --booking-holiday-bg: hsl(var(--booking-holiday-hue), 20%, 78%);
    --booking-holiday-text: hsl(var(--booking-holiday-hue), 35%, 18%);

    --booking-neutral-100: hsl(var(--booking-neutral-hue), 15%, 92%);
    --booking-neutral-300: hsl(var(--booking-neutral-hue), 15%, 75%);
    --booking-neutral-600: hsl(var(--booking-neutral-hue), 10%, 45%);
    --booking-space-xs: 0.125rem;
    --booking-space-sm: 0.25rem;
    --booking-space-md: 0.5rem;
    --booking-space-lg: 1rem;
    --booking-space-xl: 1.5rem;
    --booking-space-2xl: 2rem;
    --booking-text-xs: 0.7rem;
    --booking-text-sm: 0.8125rem;
    --booking-text-base: 1rem;
    --booking-text-lg: 1.1rem;
    --booking-text-xl: 1.3rem;
    --booking-text-2xl: 2rem;
    --booking-border-radius-sm: 0.25rem;
    --booking-border-radius-md: 0.5rem;
    --booking-border-radius-full: 50%;
    --booking-input-min-width: 15rem;
    --booking-transition-fast: 0.15s ease-in-out;
}

.flatpickr-calendar .flatpickr-day.inRange,
.flatpickr-calendar .flatpickr-day.inRange:hover,
.flatpickr-calendar .flatpickr-day.today.inRange {
    background: var(--booking-selected-bg);
    border-color: var(--booking-selected-bg);
    box-shadow:
        -5px 0 0 var(--booking-selected-bg),
        5px 0 0 var(--booking-selected-bg);
}

.flatpickr-calendar .flatpickr-day.booking-constrained-range-marker {
    background-color: var(--booking-selected-bg) !important;
    border-color: var(--booking-selected-bg) !important;
    color: var(--booking-selected-text) !important;
}

.flatpickr-calendar .flatpickr-day.booking-constrained-range-marker:hover {
    background-color: var(--booking-selected-bg-hover) !important;
    border-color: var(--booking-selected-bg-hover) !important;
}

/* Before hover, only an actual occupied/closed day (booked, checked
   out, holiday) gets any styling - lead-floor/lead-theoretical/
   trail-theoretical/plain lead/trail are all constraint-only signals
   (buffer requirements, not an actual booking on that day) and
   deliberately carry no colour here. They still block selection via
   flatpickr's native disabled look, and the day-details panel/hover
   feedback bar explain why on hover; a permanent grey layer under all
   of that was exactly the "busy calendar" this was built to avoid. */

/* Consecutive Unavailable days bridge into one contiguous strip (same
   box-shadow technique as the hover-preview bands below) instead of a
   row of separate pills - and unlike those hover-preview bands, stay
   square at every cell, both ends of the run included. Unavailable is
   the always-on, most emphatic state on the grid; a flat-edged block
   reads as a stronger "this is occupied" signal than a softened pill
   shape, and there's exactly one rounding rule to reason about (always
   square) instead of two. */
.flatpickr-calendar .flatpickr-day.booking-day--booked,
.flatpickr-calendar .flatpickr-day.booking-day--checked-out {
    background-color: var(--booking-unavailable-bg);
    border-color: var(--booking-unavailable-bg);
    color: var(--booking-unavailable-text);
    border-radius: 0;
    box-shadow:
        -5px 0 0 var(--booking-unavailable-bg),
        5px 0 0 var(--booking-unavailable-bg);
}

.flatpickr-calendar .flatpickr-day.booking-day--booked:hover,
.flatpickr-calendar .flatpickr-day.booking-day--checked-out:hover {
    background-color: var(--booking-unavailable-bg-hover);
    border-color: var(--booking-unavailable-bg-hover);
    box-shadow:
        -5px 0 0 var(--booking-unavailable-bg-hover),
        5px 0 0 var(--booking-unavailable-bg-hover);
}

.flatpickr-calendar .flatpickr-day.booking-day--holiday {
    background-color: var(--booking-holiday-bg);
    border-color: var(--booking-holiday-bg);
    color: var(--booking-holiday-text);
}

/* A quiet dot hinting there's booking detail worth checking (barcodes,
   the "x of y items booked" summary - see the day-details panel on
   hover/focus), on every day that actually has some: Partial (some, but
   not all, relevant items booked - the day stays clickable via a
   different item, so it keeps no background colour of its own) and
   Unavailable alike (every relevant item booked - the solid background
   already says "you can't have this day", but that's a different fact
   from "there's booking detail behind it", and hiding the dot there
   read as inconsistent - a day that's Unavailable for a very different
   reason than plain Partial-availability shouldn't look like it has
   *less* going on underneath it). Deliberately one neutral dot
   regardless of how many items are actually involved, not one dot per
   item (see the UX spec §7) - it's a "there's detail here" hint, not a
   raw inventory count. */
.flatpickr-calendar .flatpickr-day.booking-day--partial::after,
.flatpickr-calendar .flatpickr-day.booking-day--booked::after,
.flatpickr-calendar .flatpickr-day.booking-day--checked-out::after {
    content: "";
    position: absolute;
    bottom: 4px;
    left: 50%;
    transform: translateX(-50%);
    width: var(--booking-marker-size);
    height: var(--booking-marker-size);
    border-radius: var(--booking-border-radius-full);
    background: var(--booking-neutral-600);
}

/* Lead period, one colour regardless of whose booking it belongs to:
   the adjacent existing booking's window (adjacency-scoped - only the
   booking immediately before/after the hovered gap, added/removed
   directly in onDayHover) or my own prospective booking's buffer
   preview (live while picking, or pinned once both dates are
   committed - see classByDate).

   Every band cell bridges into the flatpickr layout gap on both sides
   via box-shadow (matching the old UI's technique, so a run of days
   reads as one continuous strip instead of separate pills) and is
   square by default - only the true start/end of a run (marked by
   applyAdjacencyClass with --run-start/--run-end, see onDayHover) gets
   rounded back to flatpickr's own pill radius. */
.flatpickr-calendar .flatpickr-day.booking-day--existing-lead-adjacent,
.flatpickr-calendar .flatpickr-day.booking-day--existing-trail-adjacent,
.flatpickr-calendar .flatpickr-day.booking-day--my-lead-buffer,
.flatpickr-calendar .flatpickr-day.booking-day--my-trail-buffer {
    border-radius: 0 !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--existing-lead-adjacent,
.flatpickr-calendar .flatpickr-day.booking-day--my-lead-buffer {
    background-color: var(--booking-lead-bg) !important;
    border-color: var(--booking-lead-bg) !important;
    color: var(--booking-lead-text) !important;
    box-shadow:
        -5px 0 0 var(--booking-lead-bg),
        5px 0 0 var(--booking-lead-bg) !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--existing-lead-adjacent:hover,
.flatpickr-calendar .flatpickr-day.booking-day--my-lead-buffer:hover {
    background-color: var(--booking-lead-bg-hover) !important;
    border-color: var(--booking-lead-bg-hover) !important;
    box-shadow:
        -5px 0 0 var(--booking-lead-bg-hover),
        5px 0 0 var(--booking-lead-bg-hover) !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--existing-trail-adjacent,
.flatpickr-calendar .flatpickr-day.booking-day--my-trail-buffer {
    background-color: var(--booking-trail-bg) !important;
    border-color: var(--booking-trail-bg) !important;
    color: var(--booking-trail-text) !important;
    box-shadow:
        -5px 0 0 var(--booking-trail-bg),
        5px 0 0 var(--booking-trail-bg) !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--existing-trail-adjacent:hover,
.flatpickr-calendar .flatpickr-day.booking-day--my-trail-buffer:hover {
    background-color: var(--booking-trail-bg-hover) !important;
    border-color: var(--booking-trail-bg-hover) !important;
    box-shadow:
        -5px 0 0 var(--booking-trail-bg-hover),
        5px 0 0 var(--booking-trail-bg-hover) !important;
}

/* Clash: my buffer overlaps an adjacent existing booking's buffer -
   only once that overlap is a genuine conflict (booking-day--my-lead-
   real-conflict / --my-trail-real-conflict, added in onDayHover from
   leadWindowConflicts/trailWindowConflicts), not merely two bands whose
   date ranges happen to touch. In "any item" mode the adjacent band can
   light up from one candidate item while a different one stays free, in
   which case the two colours are left to overlap plainly rather than
   claim a clash that wouldn't actually block the booking. Three-class
   compound selectors outrank the single-class rules above regardless of
   source order. */
.flatpickr-calendar
    .flatpickr-day.booking-day--existing-lead-adjacent.booking-day--my-trail-buffer.booking-day--my-trail-real-conflict {
    background-color: var(--booking-clash-trail-lead-bg) !important;
    border-color: var(--booking-clash-trail-lead-bg) !important;
    color: var(--booking-clash-trail-lead-text) !important;
    box-shadow:
        -5px 0 0 var(--booking-clash-trail-lead-bg),
        5px 0 0 var(--booking-clash-trail-lead-bg) !important;
}

.flatpickr-calendar
    .flatpickr-day.booking-day--existing-lead-adjacent.booking-day--my-trail-buffer.booking-day--my-trail-real-conflict:hover {
    background-color: var(--booking-clash-trail-lead-bg-hover) !important;
    border-color: var(--booking-clash-trail-lead-bg-hover) !important;
    box-shadow:
        -5px 0 0 var(--booking-clash-trail-lead-bg-hover),
        5px 0 0 var(--booking-clash-trail-lead-bg-hover) !important;
}

.flatpickr-calendar
    .flatpickr-day.booking-day--existing-trail-adjacent.booking-day--my-lead-buffer.booking-day--my-lead-real-conflict {
    background-color: var(--booking-clash-lead-trail-bg) !important;
    border-color: var(--booking-clash-lead-trail-bg) !important;
    color: var(--booking-clash-lead-trail-text) !important;
    box-shadow:
        -5px 0 0 var(--booking-clash-lead-trail-bg),
        5px 0 0 var(--booking-clash-lead-trail-bg) !important;
}

.flatpickr-calendar
    .flatpickr-day.booking-day--existing-trail-adjacent.booking-day--my-lead-buffer.booking-day--my-lead-real-conflict:hover {
    background-color: var(--booking-clash-lead-trail-bg-hover) !important;
    border-color: var(--booking-clash-lead-trail-bg-hover) !important;
    box-shadow:
        -5px 0 0 var(--booking-clash-lead-trail-bg-hover),
        5px 0 0 var(--booking-clash-lead-trail-bg-hover) !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--run-start {
    border-radius: 150px 0 0 150px !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--run-end {
    border-radius: 0 150px 150px 0 !important;
}

.flatpickr-calendar .flatpickr-day.booking-day--run-start.booking-day--run-end {
    border-radius: 150px !important;
}

/* The anchor/hover/selected date itself, when a lead or trail band
   sits flush against it (see applyMyBuffer in BookingPeriodStep.vue) -
   forced square so it butts against the band's own square near edge
   instead of poking a rounded corner into the middle of the strip via
   flatpickr's native startRange/endRange/selected rounding. */
.flatpickr-calendar .flatpickr-day.booking-day--adjoins-lead,
.flatpickr-calendar .flatpickr-day.booking-day--adjoins-trail {
    border-radius: 0 !important;
}

.flatpickr-calendar .flatpickr-day.booking-intermediate-blocked {
    background-color: var(--booking-selected-bg) !important;
    border-color: var(--booking-selected-bg) !important;
    color: var(--booking-selected-text) !important;
    cursor: not-allowed !important;
    opacity: 0.7 !important;
}

.flatpickr-calendar .flatpickr-day.booking-loan-boundary {
    font-weight: 700 !important;
}

.flatpickr-calendar .flatpickr-day.booking-intermediate-blocked:hover {
    background-color: var(--booking-selected-bg-hover) !important;
    border-color: var(--booking-selected-bg-hover) !important;
}

.booking-extended-attributes {
    list-style: none;
    padding: 0;
    margin: 0;
}

.booking-form .step-block {
    margin-bottom: var(--booking-space-md);
}

.booking-form .step-header {
    font-weight: 600;
    font-size: var(--booking-text-lg);
    margin-bottom: calc(var(--booking-space-lg) * 0.75);
    color: var(--booking-neutral-600);
}

.booking-form hr {
    border: none;
    border-top: var(--booking-border-width) solid var(--booking-neutral-100);
    margin: var(--booking-space-lg) 0;
}

.booking-flatpickr-input,
.flatpickr-input.booking-flatpickr-input {
    min-width: var(--booking-input-min-width);
    padding: calc(var(--booking-space-md) - var(--booking-space-xs))
        calc(var(--booking-space-md) + var(--booking-space-sm));
    border: var(--booking-border-width) solid var(--booking-neutral-300);
    border-radius: var(--booking-border-radius-sm);
    font-size: var(--booking-text-base);
    transition:
        border-color var(--booking-transition-fast),
        box-shadow var(--booking-transition-fast);
}

/* Passed into BookingCalendar's legend slot (see the template in
   BookingPeriodStep.vue) and rendered as a flex child of its own
   .booking-flatpickr-wrapper, not a descendant of .booking-form - these
   rules aren't (and don't need to be) scoped under .booking-form, the
   same as .booking-hover-feedback/.booking-day-details below. */
.calendar-legend {
    padding: 0.5rem 0.75rem 0;
    margin-bottom: var(--booking-space-md);
    font-size: var(--booking-text-sm);
    display: flex;
    flex-wrap: wrap;
    align-items: center;
}

/* .flatpickr-prev-month/.flatpickr-next-month are position:absolute;
   top:0 with no positioned ancestor of their own between them and
   .flatpickr-calendar (also position:absolute) - so top:0 resolves
   against the *calendar's* top edge, not the months row's. That only
   ever looked right because .flatpickr-months used to be the
   calendar's first child, putting the two edges at the same place by
   coincidence. Now that the legend sits above it, the month/year text
   (normal flow, inside .flatpickr-months) moves down but the arrows
   stay pinned to the calendar's top - overlapping the legend instead
   of sitting inline with the month/year row. Anchoring the arrows to
   .flatpickr-months itself fixes this regardless of what precedes it. */
.flatpickr-months {
    position: relative;
}

/* Legend swatches: square by default, matching the solid day-cell fill
   every state but Partial actually renders as (Selected/Unavailable/
   Lead/Trail/Clash/Holiday). Partial is the one legend entry that's
   genuinely a dot with no background fill on the grid, so it's the only
   one restored to round below - everything else here would otherwise
   mislead by drawing a rounded swatch for a state that's actually a
   flat-edged day-cell background. */
.calendar-legend .booking-marker-dot {
    width: calc(var(--booking-marker-size) * 2) !important;
    height: calc(var(--booking-marker-size) * 2) !important;
    margin-right: calc(var(--booking-space-sm) * 1.5);
    border: var(--booking-border-width) solid hsla(0, 0%, 0%, 0.15);
    border-radius: 0;
}

.calendar-legend .booking-marker-dot--partial {
    border-radius: var(--booking-border-radius-full);
    border: none;
}

.booking-flatpickr-input {
    margin-bottom: 0;
}

.booking-form .vs__selected {
    font-size: var(--vs-font-size);
    line-height: var(--vs-line-height);
}

.booking-constraint-info {
    margin-top: var(--booking-space-lg);
    margin-bottom: var(--booking-space-lg);
}

.booking-marker-dot {
    display: inline-block;
    width: var(--booking-marker-size);
    height: var(--booking-marker-size);
    border-radius: var(--booking-border-radius-full);
    vertical-align: middle;
}

.booking-marker-dot--selected {
    background: var(--booking-selected-bg);
}

.booking-marker-dot--booked,
.booking-marker-dot--checked-out {
    background: var(--booking-unavailable-bg);
}

.booking-marker-dot--lead-floor,
.booking-marker-dot--lead-theoretical,
.booking-marker-dot--trail-theoretical {
    background: var(--booking-buffer-bg);
}

/* The day-details panel only ever describes the currently-hovered day,
   so a "lead"/"trail" marker there is always the hover-adjacent one by
   construction - these match the calendar day's own adjacency colour
   rather than the always-on grey above. */
.booking-marker-dot--lead {
    background: var(--booking-lead-bg);
}

.booking-marker-dot--trail {
    background: var(--booking-trail-bg);
}

.booking-marker-dot--clash-trail-lead {
    background: var(--booking-clash-trail-lead-bg);
}

.booking-marker-dot--clash-lead-trail {
    background: var(--booking-clash-lead-trail-bg);
}

.booking-marker-dot--holiday {
    background: var(--booking-holiday-bg);
}

.booking-marker-dot--partial {
    background: var(--booking-neutral-600);
}

/* Standard Bootstrap .alert styling (colour, border, padding, radius)
   comes from Alert's own variant prop now - info/warning/danger map
   directly onto alert-info/alert-warning/alert-danger. Only the fade-
   in-place behaviour is custom: the box stays in the document flow at
   a fixed footprint and opacity-fades rather than mounting/unmounting,
   so rapid movement between adjacent hovered days doesn't flicker. */
.booking-hover-feedback {
    min-height: 3rem;
    opacity: 0;
    margin-top: 0.5rem;
    margin-bottom: 0;
    font-size: var(--booking-text-sm);
    text-align: center;
    transition:
        opacity 100ms ease,
        background-color 100ms ease,
        color 100ms ease;
}

.booking-hover-feedback--visible {
    opacity: 1;
}

.booking-day-details {
    min-height: 4.5rem;
    max-height: 6rem;
    overflow-y: auto;
    opacity: 0;
    margin-top: 0.25rem;
    margin-bottom: 0;
    font-size: var(--booking-text-sm);
    transition: opacity 100ms ease;
}

.booking-day-details--visible {
    opacity: 1;
}

.booking-day-details-summary {
    font-weight: 700;
    margin-bottom: var(--booking-space-xs);
}

.booking-day-details-row {
    display: flex;
    align-items: center;
    gap: var(--booking-space-xs);
    line-height: 1.6;
}

.booking-day-details-row:not(:last-child) {
    margin-bottom: calc(var(--booking-space-xs) / 2);
}

.booking-day-details .booking-marker-dot {
    flex-shrink: 0;
    width: calc(var(--booking-marker-size) * 1.25);
    height: calc(var(--booking-marker-size) * 1.25);
    border: var(--booking-border-width) solid hsla(0, 0%, 0%, 0.15);
}
</style>
