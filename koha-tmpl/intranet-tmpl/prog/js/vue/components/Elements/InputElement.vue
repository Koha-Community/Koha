<template>
    <input
        :id="id"
        :type="type"
        v-model="model"
        :placeholder="placeholder"
        :required="required"
    />
</template>

<script>
export default {
    props: {
        id: String,
        modelValue: String,
        placeholder: String,
        required: Boolean,
        type: {
            type: String,
            default: "text",
        },
    },
    emits: ["update:modelValue"],
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
    name: "InputElement",
};
</script>

<style></style>
