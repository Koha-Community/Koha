<template>
    <Link v-bind="$props" />
</template>

<script>
import Link from "./Link.vue";
export default {
    components: { Link },
    props: {
        to: {
            type: [String, Object],
        },
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
    name: "ToolbarButton",
};
</script>
