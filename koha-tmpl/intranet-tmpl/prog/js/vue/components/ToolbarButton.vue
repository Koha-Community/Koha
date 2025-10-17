<template>
    <ButtonSubmit v-if="action === 'submit'" v-bind="$props" />
    <Link v-else v-bind="$props" />
</template>

<script>
import ButtonSubmit from "./ButtonSubmit.vue";
import Link from "./Link.vue";
export default {
    inheritAttrs: false,
    components: { Link, ButtonSubmit },
    props: {
        action: {
            type: String,
            required: false,
        },
        to: {
            type: [String, Object],
            required: false,
        },
        onClick: { type: Function, required: false },
        icon: {
            type: String,
            required: false,
        },
        title: {
            type: String,
        },
        callback: {
            type: [String, Function],
            required: false,
        },
        cssClass: {
            type: String,
            default: "btn btn-default",
            required: false,
        },
    },
    name: "Toolbar",
};
</script>
