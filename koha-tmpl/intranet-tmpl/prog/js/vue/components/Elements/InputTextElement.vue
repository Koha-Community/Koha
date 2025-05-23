<template>
    <input
        :id="id"
        type="text"
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
    name: "InputTextElement",
};
</script>

<style></style>
