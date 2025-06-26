<template>
    <button
        v-if="form"
        @click="form.value.requestSubmit()"
        class="btn btn-primary"
    >
        <font-awesome-icon v-if="icon" :icon="icon" />
        {{ title }}
    </button>
    <button v-else type="submit" class="btn btn-primary">
        <font-awesome-icon v-if="icon" :icon="icon" />
        {{ title }}
    </button>
</template>

<script>
import { $__ } from "@koha-vue/i18n";
export default {
    name: "ButtonSubmit",
    props: {
        title: {
            type: String,
            default: $__("Submit"),
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
