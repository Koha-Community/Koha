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
import { computed } from "vue";
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
    setup(props, { emit }) {
        const model = computed({
            get() {
                return props.modelValue;
            },
            set(value) {
                emit("update:modelValue", value);
            },
        });
        return { model };
    },
    name: "TextareaElement",
};
</script>

<style></style>
