<template>
    <flatPickr
        :id="id"
        v-model="model"
        :required="required"
        :config="fp_config"
        :data-date_to="date_to"
    />
</template>

<script>
import { computed } from "vue";
import flatPickr from "vue-flatpickr-component";

export default {
    props: {
        id: String,
        modelValue: String,
        required: Boolean,
        date_to: String,
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
        return {
            fp_config: flatpickr_defaults,
            model,
        };
    },
    components: { flatPickr },
    name: "FlatPickrWrapper",
};
</script>

<style></style>
