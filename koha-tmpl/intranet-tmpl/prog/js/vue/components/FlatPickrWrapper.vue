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
import flatPickr from "vue-flatpickr-component";

export default {
    props: {
        id: String,
        modelValue: String,
        required: Boolean,
        date_to: String,
    },
    emits: ["update:modelValue"],
    data() {
        return {
            fp_config: flatpickr_defaults,
        };
    },
    computed: {
        model: {
            get() {
                return this.modelValue;
            },
            set(value) {
                this.$emit("update:modelValue", value);
            },
        },
    },
    components: { flatPickr },
    name: "FlatPickrWrapper",
};
</script>

<style></style>
