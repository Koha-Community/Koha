<template>
    <input
        :id="id"
        inputmode="numeric"
        v-model="model"
        :placeholder="placeholder"
        :required="required"
        :size="size"
    />
</template>

<script>
import { computed } from "vue";
export default {
    props: {
        id: String,
        modelValue: Number | String,
        placeholder: String,
        required: Boolean,
        size: Number | null,
    },
    emits: ["update:modelValue"],
    setup(props, { emit }) {
        const model = computed({
            get() {
                return props.modelValue !== null &&
                    props.modelValue !== undefined
                    ? parseFloat(props.modelValue)
                    : props.modelValue;
            },
            set(value) {
                emit("update:modelValue", value);
            },
        });
        return { model };
    },
    name: "InputNumber",
};
</script>

<style></style>
