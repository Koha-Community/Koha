<template>
    <input
        :id="id"
        type="checkbox"
        v-model="model"
        :placeholder="placeholder"
        :required="required"
        @change="changeMethod()"
    />
</template>

<script>
import { computed } from "vue";
export default {
    props: {
        id: String,
        modelValue: String | Boolean,
        placeholder: String,
        required: Boolean,
        changeMethod: {
            type: Function,
            default: () => {},
        },
    },
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
    emits: ["update:modelValue"],
    name: "InputCheckboxElement",
};
</script>

<style></style>
