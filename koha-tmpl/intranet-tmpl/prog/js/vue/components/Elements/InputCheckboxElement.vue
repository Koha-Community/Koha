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
    name: "InputCheckboxElement",
};
</script>

<style></style>
