<template>
    <div
        ref="modalElement"
        class="modal fade"
        tabindex="-1"
        role="dialog"
        :aria-labelledby="titleId"
    >
        <div class="modal-dialog" :class="`modal-${size}`" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 :id="titleId" class="modal-title fs-5">
                        {{ modalTitle }}
                    </h1>
                    <button
                        type="button"
                        class="btn-close"
                        :aria-label="$__('Close')"
                        @click="handleClose"
                    ></button>
                </div>
                <div class="modal-body booking-modal-body">
                    <BookingForm
                        ref="bookingForm"
                        :active="formActive"
                        :biblionumber="biblionumber"
                        :booking-id="bookingId"
                        :item-id="itemId"
                        :patron-id="patronId"
                        :pickup-library-id="pickupLibraryId"
                        :start-date="startDate"
                        :end-date="endDate"
                        :itemtype-id="itemtypeId"
                        :show-patron-select="showPatronSelect"
                        :show-item-details-selects="showItemDetailsSelects"
                        :show-pickup-location-select="showPickupLocationSelect"
                        :submit-type="submitType"
                        :submit-url="submitUrl"
                        :date-range-constraint="dateRangeConstraint"
                        :custom-date-range-formula="customDateRangeFormula"
                        @submitted="handleSubmitted"
                    />
                </div>
                <div class="modal-footer">
                    <div class="d-flex gap-2">
                        <button
                            class="btn btn-primary"
                            :disabled="
                                !bookingForm ||
                                bookingForm.submitLoading ||
                                !bookingForm.isSubmitReady
                            "
                            type="submit"
                            form="form-booking"
                        >
                            {{ bookingForm?.submitLabel }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-secondary ms-2"
                            @click="handleClose"
                        >
                            {{ $__("Cancel") }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, useId, watch } from "vue";
import { $__ } from "@koha-vue/i18n";
import BookingForm from "./BookingForm.vue";
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
type SubmittedDetail = {
    booking: unknown;
    bookingPatron: unknown;
    isUpdate: boolean;
};
type BookingFormStatus = {
    isSubmitReady: boolean;
    submitLabel: string;
    submitLoading: boolean;
};

const props = withDefaults(
    defineProps<{
        open?: boolean;
        size?: string;
        title?: string;
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
        open: false,
        size: "lg",
        title: "",
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
    (e: "close"): void;
    (e: "booking-saved", detail: SubmittedDetail): void;
}>();

const modalElement = ref<HTMLElement | null>(null);
const bookingForm = ref<BookingFormStatus | null>(null);
const formActive = ref(false);
const titleId = `booking-modal-title-${useId()}`;
let bsModal: InstanceType<typeof window.bootstrap.Modal> | null = null;
let returnFocusTo: HTMLElement | null = null;

const modalTitle = computed(
    () =>
        props.title ||
        (props.bookingId ? $__("Edit booking") : $__("Place booking"))
);

/**
 * Activate the booking form and show its Bootstrap modal shell.
 *
 * @returns {void}
 */
function showModal(): void {
    if (!formActive.value) {
        const activeElement = document.activeElement;
        returnFocusTo =
            activeElement instanceof HTMLElement &&
            activeElement !== document.body &&
            !modalElement.value?.contains(activeElement)
                ? activeElement
                : null;
    }
    formActive.value = true;
    bsModal?.show();
}

/**
 * Deactivate the booking form and hide its Bootstrap modal shell.
 *
 * @returns {void}
 */
function hideModal(): void {
    formActive.value = false;
    bsModal?.hide();
}

/**
 * Release the focused control before requesting modal closure.
 *
 * @returns {void}
 */
function handleClose(): void {
    if (document.activeElement instanceof HTMLElement) {
        document.activeElement.blur();
    }
    hideModal();
}

/**
 * Forward a successful booking write and close the modal.
 *
 * @param {SubmittedDetail} detail Saved booking details emitted by the form.
 * @returns {void}
 */
function handleSubmitted(detail: SubmittedDetail): void {
    emit("booking-saved", detail);
    handleClose();
}

/**
 * Emit closure and restore focus after Bootstrap finishes hiding.
 *
 * @returns {void}
 */
function handleHidden(): void {
    formActive.value = false;
    const focusTarget = returnFocusTo;
    returnFocusTo = null;
    emit("close");
    if (focusTarget?.isConnected) focusTarget.focus();
}

watch(
    () => props.open,
    open => {
        if (open) showModal();
        else hideModal();
    }
);

onMounted(() => {
    if (!modalElement.value) return;
    bsModal = new window.bootstrap.Modal(modalElement.value, {
        backdrop: "static",
        keyboard: false,
    });
    modalElement.value.addEventListener("hidden.bs.modal", handleHidden);
    if (props.open) showModal();
});

onUnmounted(() => {
    formActive.value = false;
    returnFocusTo = null;
    modalElement.value?.removeEventListener("hidden.bs.modal", handleHidden);
    bsModal?.dispose();
});
</script>

<style>
.booking-modal-body {
    padding: var(--booking-space-xl);
    overflow-y: auto;
    flex: 1 1 auto;
}
</style>
