<template>
    <input
        :id="id"
        type="number"
        v-model="model"
        :placeholder="placeholder"
        :required="required"
    />
</template>

<script>
import { computed } from "vue";
export default {
    props: {
        id: String,
        modelValue: Number,
        placeholder: String,
        required: Boolean,
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
    name: "InputNumberElement",
};
</script>

<style></style>
