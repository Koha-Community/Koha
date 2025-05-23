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
export default {
    props: {
        id: String,
        modelValue: Number,
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
    name: "InputNumberElement",
};
</script>

<style></style>
