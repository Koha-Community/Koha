<template>
    <input
        type="text"
        :id="id"
        ref="searchInputRef"
        class="patron-search-input"
        :placeholder="placeholder"
        :required="required && !modelValue"
        :style="
            modelValue
                ? 'position: absolute; opacity: 0.01; height: 1px; width: 1px; pointer-events: none;'
                : ''
        "
        @input="handleInput"
        @change="handleValidation"
        @invalid="handleValidation"
    />
    <span v-if="loading">{{ $__("Loading...") }}</span>
    <span v-if="invalidValue">
        {{ $__("Invalid patron data (%s)").format(invalidValue) }}
        (<a href="#" @click.prevent="removeInvalidValue"
            ><i class="fa fa-trash-can" aria-hidden="true"></i>
            {{ $__("Remove") }}</a
        >)
    </span>
    <span :id="`patron_selection_${id}`"></span>
</template>

<script>
import { ref, onMounted, watch, nextTick } from "vue";
import { APIClient } from "../fetch/api-client.js";

export default {
    props: {
        id: { type: String, required: true },
        placeholder: String,
        patronAutoCompleteOptions: Object,
        valueAttr: { type: String, default: "patron_id" },
        required: Boolean,
        modelValue: { type: [Number, String], default: null },
    },
    emits: ["update:modelValue"],
    setup(props, { emit }) {
        const searchInputRef = ref(null);
        const loading = ref(false);
        const invalidValue = ref(null);

        const clearValue = () => {
            emit("update:modelValue", null);
            nextTick(() => searchInputRef.value?.focus());
        };

        const removeInvalidValue = () => {
            invalidValue.value = null;
            clearValue();
        };

        const handleValidation = event => {
            const input = event.target;
            if (props.modelValue) {
                input.setCustomValidity("");
            } else if (input.value.length > 0) {
                input.setCustomValidity(
                    "You must select a patron from the results list."
                );
            } else if (props.required) {
                input.setCustomValidity(
                    "Please select a patron from the results list."
                );
            }
        };

        const handleInput = e => e.target.setCustomValidity("");

        watch(
            () => props.modelValue,
            newVal => {
                if (newVal) {
                    searchInputRef.value?.setCustomValidity("");
                }
            },
            { immediate: true }
        );

        onMounted(() => {
            const $searchInputRef = $(searchInputRef.value);
            const $selectionContainer = $(`#patron_selection_${props.id}`);

            window.patron_autocomplete($searchInputRef, {
                "on-select-add-to": {
                    container: $selectionContainer,
                    input_name: props.id,
                },
                "on-select-callback": (event, ui) => {
                    emit("update:modelValue", ui.item[props.valueAttr]);
                    $searchInputRef.val("");
                    return false;
                },
                "on-remove-callback": () => {
                    clearValue();
                    return false;
                },
                "additional-filters":
                    props.patronAutoCompleteOptions?.["additional-filters"],
                permissions: props.patronAutoCompleteOptions?.["permissions"],
            });

            if (props.modelValue) {
                loading.value = true;
                const getPatron =
                    props.valueAttr === "patron_id"
                        ? APIClient.patron.patrons.get(props.modelValue)
                        : APIClient.patron.patrons
                              .getAll({ [props.valueAttr]: props.modelValue })
                              .then(patrons => patrons[0]);
                getPatron
                    .catch(err => console.error("Koha API Error:", err))
                    .then(p => {
                        if (!p) {
                            invalidValue.value = props.modelValue;
                            return;
                        }
                        window.patron_autocomplete_render_selection(
                            p,
                            $selectionContainer,
                            props.id,
                            clearValue
                        );
                    })
                    .finally(() => (loading.value = false));
            }
        });

        return {
            searchInputRef,
            loading,
            invalidValue,
            removeInvalidValue,
            handleValidation,
            handleInput,
        };
    },
};
</script>

<style>
.patron-detail-autocomplete-selection {
    display: inline;
}
</style>
