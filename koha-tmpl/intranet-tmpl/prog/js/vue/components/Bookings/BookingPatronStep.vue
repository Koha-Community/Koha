<template>
    <fieldset class="step-block">
        <legend class="step-header">
            {{ stepNumber }}.
            {{ $__("Select patron") }}
        </legend>
        <div class="form-group">
            <label for="booking_patron" class="required">
                {{ $__("Patron") }}
            </label>
            <v-select
                v-model="selectedPatron"
                :options="patronOptions"
                :filterable="false"
                :loading="loading.patrons"
                :disabled="!active"
                :placeholder="$__('Search for a patron')"
                label="label"
                :clearable="true"
                :reset-on-blur="false"
                :reset-on-select="false"
                input-id="booking_patron"
                @search="handlePatronSearch"
            >
                <template #search="{ attributes, events }">
                    <input
                        class="vs__search"
                        :required="!selectedPatron"
                        aria-required="true"
                        v-bind="attributes"
                        v-on="events"
                    />
                </template>
                <template #option="option">
                    <span>{{ option.label }}</span>
                    <small
                        v-if="option._age != null || option._libraryName"
                        class="patron-option-meta"
                    >
                        <span v-if="option._age != null" class="age_years">
                            {{ formatAge(option._age) }}
                        </span>
                        <span v-if="option._libraryName" class="ac-library">
                            {{ option._libraryName }}
                        </span>
                    </small>
                </template>
                <template #no-options>
                    {{
                        hasSearched
                            ? $__("No patrons found.")
                            : $__("Type to search for patrons.")
                    }}
                </template>
                <template #spinner>
                    <span class="visually-hidden">{{
                        $__("Searching...")
                    }}</span>
                </template>
            </v-select>
            <span class="required">{{ $__("Required") }}</span>
        </div>
    </fieldset>
</template>

<script setup lang="ts">
import { computed, inject, onBeforeUnmount, ref, watch } from "vue";
import { storeToRefs } from "pinia";
import vSelect from "vue-select";
import "vue-select/dist/vue-select.css";
import { $__, $__nx } from "@koha-vue/i18n";
import { formatApiError } from "@fetch/api-error";
import { debounce } from "../../utils/functions.js";
import type { PatronOption } from "../../lib/booking/types/bookings.d.ts";
import type { useBookingStore } from "../../stores/bookings";

const PATRON_SEARCH_DEBOUNCE_MS = 250;

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
const hasSearched = ref(false);
let searchGeneration = 0;

const selectedPatron = computed({
    get: () => props.modelValue,
    set: (value: PatronOption | null) => emit("update:modelValue", value),
});

/**
 * Format a patron age with plural-aware translation.
 *
 * @param {number} age Patron age in years.
 * @returns {string} Localized age.
 */
function formatAge(age: number): string {
    return $__nx("{count} year", "{count} years", age, { count: age });
}

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
    hasSearched.value = true;
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

const debouncedPatronSearch = debounce(
    searchPatrons,
    PATRON_SEARCH_DEBOUNCE_MS
);

/**
 * Cancel queued work and invalidate any patron response in flight.
 *
 * @returns {void}
 */
function cancelPatronSearch(): void {
    searchGeneration++;
    debouncedPatronSearch.cancel();
}

/**
 * Queue a patron search when the active form has a usable term.
 *
 * @param {string} search Patron search term supplied by vue-select.
 * @returns {void}
 */
function handlePatronSearch(search: string): void {
    const generation = ++searchGeneration;
    if (!props.active || !search || search.length < 3) {
        debouncedPatronSearch.cancel();
        hasSearched.value = false;
        patronOptions.value = [];
        return;
    }
    debouncedPatronSearch(search, generation);
}

watch(
    () => props.active,
    active => {
        if (active) return;
        cancelPatronSearch();
        hasSearched.value = false;
        patronOptions.value = [];
    }
);

onBeforeUnmount(cancelPatronSearch);
</script>

<style scoped>
.patron-option-meta {
    margin-left: var(--booking-space-md);
    opacity: 0.75;
}

.patron-option-meta .ac-library {
    margin-left: var(--booking-space-sm);
    padding: var(--booking-space-xs) var(--booking-space-md);
    border-radius: var(--booking-border-radius-sm);
    background-color: var(--booking-neutral-100);
}
</style>
