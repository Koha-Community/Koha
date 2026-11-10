<template>
    <form @submit.prevent="onSubmit" class="checkin-form">
        <fieldset id="circ_returns_checkin">
            <div class="form-control-group">
                <label for="barcode-input" class="visually-hidden">{{
                    $__("Item barcode")
                }}</label>
                <input
                    id="barcode-input"
                    ref="barcodeInput"
                    v-model="barcode"
                    type="text"
                    size="14"
                    class="barcode focus"
                    :class="{ 'input-warning': highlightInput }"
                    :placeholder="$__('Enter item barcode')"
                    :disabled="disabled"
                    autocomplete="off"
                    @focus="$emit('focus')"
                />

                <div id="show-circ-settings">
                    <a
                        href="#"
                        :title="$__('Checkin settings')"
                        :aria-label="$__('Checkin settings')"
                        role="button"
                        @click.prevent="$emit('toggle-options')"
                        ><i class="fa-solid fa-sliders" aria-hidden="true"></i
                    ></a>
                </div>

                <button
                    type="submit"
                    class="btn btn-primary"
                    :disabled="disabled || !barcode.trim()"
                >
                    {{ $__("Check in") }}
                </button>
            </div>
        </fieldset>
    </form>
</template>

<script>
import { ref, computed, nextTick, onMounted } from "vue";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        disabled: {
            type: Boolean,
            default: false,
        },
        dropboxMode: {
            type: Boolean,
            default: false,
        },
        exemptFine: {
            type: Boolean,
            default: false,
        },
    },
    emits: ["submit", "focus", "toggle-options"],
    setup(props, { emit }) {
        const barcode = ref("");
        const barcodeInput = ref(null);

        const highlightInput = computed(
            () => props.dropboxMode || props.exemptFine
        );

        function onSubmit() {
            const value = barcode.value.trim();
            if (!value) return;
            emit("submit", value);
            barcode.value = "";
        }

        // Prefill the input without submitting it
        function setBarcode(value) {
            barcode.value = value ?? "";
        }

        function focus() {
            nextTick(() => {
                if (barcodeInput.value) {
                    barcodeInput.value.focus();
                }
            });
        }

        onMounted(() => {
            // Delay initial focus to run after staff-global.js which
            // focuses #ret_barcode in the header on $(document).ready()
            setTimeout(() => focus(), 500);
        });

        return {
            barcode,
            barcodeInput,
            highlightInput,
            onSubmit,
            focus,
            setBarcode,
        };
    },
};
</script>

<style scoped>
.input-warning {
    border-color: #f0ad4e !important;
    box-shadow: 0 0 0 0.2rem rgba(240, 173, 78, 0.25);
}
</style>
