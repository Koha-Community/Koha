<template>
    <div class="form-group">
        <label :for="inputId" :class="{ required }">{{ label }}</label>
        <v-select
            v-model="selectedPatron"
            :options="options"
            :filterable="false"
            :loading="loading"
            :disabled="disabled"
            :placeholder="placeholder"
            label="label"
            :clearable="true"
            :reset-on-blur="false"
            :reset-on-select="false"
            :input-id="inputId"
            @search="debouncedSearch"
        >
            <template v-if="required" #search="{ attributes, events }">
                <input
                    class="vs__search"
                    :required="!selectedPatron"
                    aria-required="true"
                    v-bind="attributes"
                    v-on="events"
                />
            </template>
            <template #option="option">
                <slot name="option" v-bind="option">
                    <span>{{ option.label }}</span>
                    <small
                        v-if="hasOptionMeta(option)"
                        class="patron-option-meta"
                    >
                        <span v-if="option._age != null" class="age_years">
                            {{ formatAge(option._age) }}
                        </span>
                        <span v-if="option._libraryName" class="ac-library">
                            {{ option._libraryName }}
                        </span>
                        <span
                            v-if="option._city || option._country"
                            class="patron-address"
                        >
                            {{ formatAddress(option) }}
                        </span>
                        <span
                            v-if="option._isCurrentLibrary"
                            class="patron-current-library badge"
                        >
                            {{ $__("Current library") }}
                        </span>
                        <span
                            v-if="option._expired"
                            class="patron-expired badge text-bg-warning"
                        >
                            {{ $__("Expired") }}
                        </span>
                        <span
                            v-if="option._restricted"
                            class="patron-restricted badge text-bg-danger"
                        >
                            {{ $__("Restricted") }}
                        </span>
                    </small>
                </slot>
            </template>
            <template #no-options>
                <slot name="no-options" :has-searched="hasSearched">{{
                    $__("Sorry, no matching options.")
                }}</slot>
            </template>
            <template #spinner>
                <slot name="spinner">{{ $__("Loading...") }}</slot>
            </template>
        </v-select>
        <span v-if="required" class="required">{{ $__("Required") }}</span>
    </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import vSelect from "vue-select";
import "vue-select/dist/vue-select.css";
import { debounce } from "../utils/functions.js";
import { $__, $__nx } from "@koha-vue/i18n";

type PatronSelectOption = {
    label: string;
    _age?: number | null;
    _libraryName?: string | null;
    _city?: string | null;
    _country?: string | null;
    _expired?: boolean;
    _restricted?: boolean;
    _isCurrentLibrary?: boolean;
    [key: string]: unknown;
};

const props = withDefaults(
    defineProps<{
        modelValue: PatronSelectOption | null;
        options: PatronSelectOption[];
        loading?: boolean;
        disabled?: boolean;
        required?: boolean;
        label: string;
        placeholder?: string;
        inputId?: string;
        minSearchLength?: number;
        debounceMs?: number;
    }>(),
    {
        modelValue: null,
        options: () => [],
        loading: false,
        disabled: false,
        required: false,
        placeholder: "",
        inputId: "patron_select",
        minSearchLength: 3,
        debounceMs: 250,
    }
);

const emit = defineEmits<{
    (e: "update:modelValue", value: PatronSelectOption | null): void;
    (e: "search", term: string): void;
}>();

const hasSearched = ref(false);

const selectedPatron = computed({
    get: () => props.modelValue,
    set: (value: PatronSelectOption | null) => emit("update:modelValue", value),
});

function formatAge(age: number): string {
    return $__nx("{count} year", "{count} years", age, { count: age });
}

function formatAddress(option: PatronSelectOption): string {
    return [option._city, option._country].filter(Boolean).join(", ");
}

function hasOptionMeta(option: PatronSelectOption): boolean {
    return !!(
        option._age != null ||
        option._libraryName ||
        option._city ||
        option._country ||
        option._isCurrentLibrary ||
        option._expired ||
        option._restricted
    );
}

const onSearch = (search: string): void => {
    if (!search || search.length < props.minSearchLength) {
        hasSearched.value = false;
        emit("search", "");
        return;
    }
    hasSearched.value = true;
    emit("search", search);
};

const debouncedSearch = debounce(onSearch, props.debounceMs);
</script>

<style scoped>
/*
 * This is a shared component, not booking-specific, so its styling
 * must not depend on the --booking-* tokens BookingForm.vue defines -
 * used anywhere without BookingForm mounted, those would resolve to
 * nothing and the badges below would lose their spacing and rounding.
 */
.patron-option-meta {
    margin-left: 0.5rem;
    opacity: 0.75;
}

.patron-option-meta .ac-library {
    margin-left: 0.25rem;
    padding: 0.125rem 0.5rem;
    border-radius: 0.25rem;
    background-color: hsl(210deg 15% 92%);
}

.patron-option-meta .patron-address {
    margin-left: 0.25rem;
}

.patron-option-meta .patron-current-library {
    margin-left: 0.25rem;
    background-color: hsl(210deg 15% 92%);
    color: inherit;
}
</style>
