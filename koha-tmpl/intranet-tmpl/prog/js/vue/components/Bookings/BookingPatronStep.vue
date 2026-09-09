<template>
    <fieldset class="step-block">
        <legend class="step-header">
            {{ stepNumber }}.
            {{ $__("Select patron") }}
        </legend>
        <PatronSelect
            v-model="selectedPatron"
            :options="patronOptions"
            :loading="loading.patrons"
            :disabled="!active"
            required
            :label="$__('Patron')"
            :placeholder="$__('Search for a patron')"
            input-id="booking_patron"
            @search="handlePatronSearch"
        >
            <template #no-options="{ hasSearched }">
                {{
                    hasSearched
                        ? $__("No patrons found.")
                        : $__("Type to search for patrons.")
                }}
            </template>
            <template #spinner>
                <span class="visually-hidden">{{ $__("Searching...") }}</span>
            </template>
        </PatronSelect>
    </fieldset>
</template>

<script setup lang="ts">
import { computed, inject, onBeforeUnmount, ref, watch } from "vue";
import { storeToRefs } from "pinia";
import { $__ } from "@koha-vue/i18n";
import { formatApiError } from "@fetch/api-error";
import PatronSelect from "../PatronSelect.vue";
import type { PatronOption } from "../../lib/booking/types/bookings.d.ts";
import type { useBookingStore } from "../../stores/bookings";

const props = withDefaults(
    defineProps<{
        active?: boolean;
        stepNumber: number;
        modelValue: PatronOption | null;
    }>(),
    { active: true }
);

const emit = defineEmits<{
    (e: "update:modelValue", value: PatronOption | null): void;
}>();

type BookingStore = ReturnType<typeof useBookingStore>;
const store = inject<BookingStore>("bookingStore") as BookingStore;
const { loading } = storeToRefs(store);
const patronOptions = ref<PatronOption[]>([]);
let searchGeneration = 0;

const selectedPatron = computed({
    get: () => props.modelValue,
    set: (value: PatronOption | null) => emit("update:modelValue", value),
});

/**
 * Fetch patron options and publish only the latest search response.
 *
 * @param {string} search Patron search term.
 * @param {number} generation Queued request generation.
 * @returns {Promise<void>}
 */
async function searchPatrons(
    search: string,
    generation: number
): Promise<void> {
    try {
        const patrons = (await store.fetchPatrons(search)) as PatronOption[];
        if (generation !== searchGeneration) return;
        patronOptions.value = patrons;
    } catch (error) {
        if (generation !== searchGeneration) return;
        const message = formatApiError(error);
        console.error("Error searching patrons:", message);
        store.setError(message, "api");
        patronOptions.value = [];
    }
}

/**
 * Invalidate any patron response in flight and clear the options.
 *
 * @returns {void}
 */
function resetPatronSearch(): void {
    searchGeneration++;
    patronOptions.value = [];
}

/**
 * Run a patron search when the active form has a usable term.
 *
 * @param {string} search Debounced patron search term from PatronSelect.
 * @returns {void}
 */
function handlePatronSearch(search: string): void {
    if (!props.active || !search) {
        resetPatronSearch();
        return;
    }
    searchPatrons(search, ++searchGeneration);
}

watch(
    () => props.active,
    active => {
        if (active) return;
        resetPatronSearch();
    }
);

onBeforeUnmount(resetPatronSearch);
</script>
