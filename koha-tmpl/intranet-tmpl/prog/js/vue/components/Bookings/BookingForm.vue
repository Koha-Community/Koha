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
    --booking-warning-hue: 45;
    --booking-danger-hue: 354;
    --booking-info-hue: 195;
    --booking-selected-hue: 48;
    --booking-selected-bg: hsl(var(--booking-selected-hue), 100%, 89%);
    --booking-selected-bg-hover: hsl(var(--booking-selected-hue), 100%, 80%);
    --booking-selected-text: hsl(var(--booking-selected-hue), 60%, 20%);
    --booking-unavailable-bg: hsl(var(--booking-danger-hue), 70%, 94%);
    --booking-unavailable-bg-hover: hsl(var(--booking-danger-hue), 70%, 88%);
    --booking-unavailable-text: hsl(var(--booking-danger-hue), 55%, 45%);
    --booking-buffer-bg: hsl(var(--booking-neutral-hue), 12%, 88%);
    --booking-buffer-bg-hover: hsl(var(--booking-neutral-hue), 12%, 82%);
    --booking-buffer-text: hsl(var(--booking-neutral-hue), 10%, 40%);
    --booking-neutral-hue: 210;
    --booking-holiday-hue: 0;
    --booking-warning-bg: hsl(var(--booking-warning-hue), 100%, 85%);
    --booking-neutral-100: hsl(var(--booking-neutral-hue), 15%, 92%);
    --booking-neutral-300: hsl(var(--booking-neutral-hue), 15%, 75%);
    --booking-neutral-600: hsl(var(--booking-neutral-hue), 10%, 45%);
    --booking-holiday-bg: hsl(var(--booking-holiday-hue), 0%, 85%);
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

.flatpickr-calendar .flatpickr-day.booking-day--lead-floor,
.flatpickr-calendar .flatpickr-day.booking-day--lead-theoretical,
.flatpickr-calendar .flatpickr-day.booking-day--trail-theoretical {
    background-color: var(--booking-buffer-bg);
    border-color: var(--booking-buffer-bg);
    color: var(--booking-buffer-text);
}

.flatpickr-calendar .flatpickr-day.booking-day--lead-floor:hover,
.flatpickr-calendar .flatpickr-day.booking-day--lead-theoretical:hover,
.flatpickr-calendar .flatpickr-day.booking-day--trail-theoretical:hover {
    background-color: var(--booking-buffer-bg-hover);
    border-color: var(--booking-buffer-bg-hover);
}

.flatpickr-calendar .flatpickr-day.booking-day--booked,
.flatpickr-calendar .flatpickr-day.booking-day--checked-out,
.flatpickr-calendar .flatpickr-day.booking-day--lead,
.flatpickr-calendar .flatpickr-day.booking-day--trail {
    background-color: var(--booking-unavailable-bg);
    border-color: var(--booking-unavailable-bg);
    color: var(--booking-unavailable-text);
}

.flatpickr-calendar .flatpickr-day.booking-day--booked:hover,
.flatpickr-calendar .flatpickr-day.booking-day--checked-out:hover,
.flatpickr-calendar .flatpickr-day.booking-day--lead:hover,
.flatpickr-calendar .flatpickr-day.booking-day--trail:hover {
    background-color: var(--booking-unavailable-bg-hover);
    border-color: var(--booking-unavailable-bg-hover);
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

.booking-form .calendar-legend {
    margin-bottom: var(--booking-space-md);
    font-size: var(--booking-text-sm);
    display: flex;
    align-items: center;
}

.booking-form .calendar-legend .booking-marker-dot {
    width: calc(var(--booking-marker-size) * 2) !important;
    height: calc(var(--booking-marker-size) * 2) !important;
    margin-right: calc(var(--booking-space-sm) * 1.5);
    border: var(--booking-border-width) solid hsla(0, 0%, 0%, 0.15);
}

.booking-date-picker {
    display: flex;
    align-items: stretch;
    width: 100%;
}

.booking-date-picker > .form-control {
    flex: 1 1 auto;
    min-width: 0;
    margin-bottom: 0;
}

.booking-date-picker-append {
    display: flex;
    margin-left: -1px;
}

.booking-date-picker-append .btn {
    border-top-left-radius: 0;
    border-bottom-left-radius: 0;
}

.booking-date-picker > .form-control:not(:last-child) {
    border-top-right-radius: 0;
    border-bottom-right-radius: 0;
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
.booking-marker-dot--checked-out,
.booking-marker-dot--lead,
.booking-marker-dot--trail {
    background: var(--booking-unavailable-bg);
}

.booking-marker-dot--lead-floor,
.booking-marker-dot--lead-theoretical,
.booking-marker-dot--trail-theoretical {
    background: var(--booking-buffer-bg);
}

.booking-marker-dot--holiday {
    background: var(--booking-holiday-bg);
}

.booking-hover-feedback {
    padding: 0.5rem 0.75rem;
    min-height: 3rem;
    opacity: 0;
    margin-top: 0.5rem;
    margin-bottom: 0;
    border-radius: 0 0 var(--booking-border-radius-sm)
        var(--booking-border-radius-sm);
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

.booking-hover-feedback--info {
    color: hsl(var(--booking-info-hue), 80%, 20%);
    background-color: hsl(var(--booking-info-hue), 40%, 93%);
}

.booking-hover-feedback--danger {
    color: hsl(var(--booking-danger-hue), 80%, 20%);
    background-color: hsl(var(--booking-danger-hue), 40%, 93%);
}

.booking-hover-feedback--warning {
    color: hsl(var(--booking-warning-hue), 80%, 20%);
    background-color: hsl(var(--booking-warning-hue), 100%, 93%);
}
</style>
