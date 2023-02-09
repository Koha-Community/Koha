<template>
    <input type="submit" variant="primary" :value="text" @click="submitting = true" />
    <div v-if="submitting" class="modal">
        <div class="spinner dialog alert">Submitting...</div>
    </div>
</template>

<script>
export default {
    name: "ButtonSubmit",
    props: {
        text: {
            type: String,
            default: __("Submit"),
            required: false,
        },
        submitting: {
            type: Boolean,
            default: false,
            required: false,
        },
    },
};
</script>

<style scoped>
.modal {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    left: 0px;
    top: 0px;
    width: 100%;
    height: 100%;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
}
.spinner {
    position: absolute;
    top: 50%;
    left: 40%;
    width: 10%
}
</style>