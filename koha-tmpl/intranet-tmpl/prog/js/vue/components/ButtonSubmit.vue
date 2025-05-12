<template>
    <button v-if="form" @click="form.requestSubmit()" class="btn btn-primary">
        <font-awesome-icon v-if="icon" :icon="icon" />
        {{ text }}
    </button>
    <button v-else type="submit" class="btn btn-primary">
        <font-awesome-icon v-if="icon" :icon="icon" />
        {{ text }}
    </button>
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
        icon: {
            type: String,
            required: false,
        },
        form: {
            type: Object,
        },
    },
};
</script>
