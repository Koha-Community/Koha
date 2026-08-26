<template>
    <input
        type="text"
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
        required: Boolean,
        modelValue: { type: [Number, String], default: null },
    },
    emits: ["update:modelValue"],
    setup(props, { emit }) {
        const searchInputRef = ref(null);

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
                    emit("update:modelValue", ui.item.patron_id);
                    $searchInputRef.val("");
                    return false;
                },
                "on-remove-callback": () => {
                    emit("update:modelValue", null);
                    nextTick(() => $searchInputRef.focus());
                    return false;
                },
                "additional-filters":
                    props.patronAutoCompleteOptions?.["additional-filters"],
                permissions: props.patronAutoCompleteOptions?.["permissions"],
            });

            if (props.modelValue) {
                APIClient.patron.patrons
                    .get(props.modelValue)
                    .then(p => {
                        window.patron_autocomplete_render_selection(
                            p,
                            $selectionContainer,
                            props.id,
                            () => emit("update:modelValue", null)
                        );
                    })
                    .catch(err => console.error("Koha API Error:", err));
            }
        });

        return { searchInputRef, handleValidation, handleInput };
    },
};
</script>

<style>
.patron-detail-autocomplete-selection {
    display: inline;
}
</style>
