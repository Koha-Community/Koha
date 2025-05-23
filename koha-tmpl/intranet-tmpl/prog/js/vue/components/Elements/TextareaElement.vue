<template>
    <textarea
        :id="id"
        v-model="model"
        :rows="rows"
        :cols="cols"
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
        rows: {
            type: Number,
            default: 10,
        },
        cols: {
            type: Number,
            default: 50,
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
    name: "TextareaElement",
};
</script>

<style></style>
