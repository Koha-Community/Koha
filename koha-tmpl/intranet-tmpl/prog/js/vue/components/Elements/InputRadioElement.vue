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
export default {
    props: {
        id: String,
        modelValue: Boolean,
        name: String,
        value: Boolean,
        checked: Boolean,
        changeMethod: {
            type: Function,
            default: () => {},
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
    name: "InputRadioElement",
};
</script>

<style></style>
