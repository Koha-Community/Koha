<template>
    <input
        type="radio"
        :name="name"
        :id="id"
        :value="value"
        :checked="checked"
        v-model="model"
        @change="changeMethod()"
    />
</template>

<script>
import { computed } from "vue";
export default {
    props: {
        id: String,
        modelValue: Boolean,
        name: String,
        value: Boolean | String,
        checked: Boolean,
        changeMethod: {
            type: Function,
            default: () => {},
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
    name: "InputRadioElement",
};
</script>

<style></style>
