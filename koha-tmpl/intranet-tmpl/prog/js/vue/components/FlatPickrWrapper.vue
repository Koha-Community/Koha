<template>
    <flatPickr
        :id="id"
        v-model="model"
        :required="required"
        :config="fp_config"
        :data-date_to="date_to"
        v-bind="$attrs"
    />
    <button
        v-if="clearable"
        v-show="model"
        type="button"
        class="koha-datepicker-clear"
        :title="$__('Clear date')"
        :aria-label="$__('Clear date')"
        @click="model = ''"
    >
        <i class="fa fa-times" aria-hidden="true"></i>
    </button>
</template>

<script>
import { computed } from "vue";
import flatPickr from "vue-flatpickr-component";

export default {
    components: { flatPickr },
    name: "FlatPickrWrapper",
    // The attributes belong to the input, not to the clear control
    inheritAttrs: false,
    props: {
        id: String,
        modelValue: String,
        required: Boolean,
        date_to: String,
        // Shows a clear control inside the field once it has a value
        clearable: {
            type: Boolean,
            default: true,
        },
        // Options added to (or overriding) the Koha flatpickr defaults
        config: {
            type: Object,
            default: () => ({}),
        },
    },
    emits: ["update:modelValue"],
    setup(props, { emit }) {
        const model = computed({
            get() {
                return props.modelValue;
            },
            set(value) {
                emit("update:modelValue", value);
            },
        });
        // The classes of the visible input place the picker icon and leave
        // room for the clear control
        const altInputClass = [
            flatpickr_defaults.altInputClass,
            "koha-datepicker-input",
            props.clearable ? "koha-datepicker-input--clearable" : "",
        ]
            .filter(Boolean)
            .join(" ");
        return {
            fp_config: {
                ...flatpickr_defaults,
                altInputClass,
                ...props.config,
            },
            model,
        };
    },
};
</script>

<style>
/*
 * Controls sit inside the field, on its right: the clear control, then the
 * picker icon. Same as the select inputs (clear, then dropdown toggle).
 * The icon is as close to the right edge as it was to the left one.
 * The form styles that leave room for an icon on the left are overridden.
 */
.koha-datepicker-input.flatpickr-input {
    background-position: right 0 center;
    padding: 3px 2.25rem 3px 6px !important;
}

.koha-datepicker-input--clearable.flatpickr-input {
    padding-right: 3.5rem !important;
}

/*
 * The clear control follows the input in the flow and is shifted over its
 * right edge, without changing the size of what is around the input.
 */
.koha-datepicker-clear {
    background: transparent;
    border: 0;
    color: #8a8f95;
    cursor: pointer;
    left: -3.5rem;
    line-height: 1;
    margin: 0 -1.5rem 0 0;
    padding: 0;
    position: relative;
    text-align: center;
    vertical-align: middle;
    width: 1.5rem;
}

.koha-datepicker-clear:hover,
.koha-datepicker-clear:focus-visible {
    color: #333;
}
</style>
