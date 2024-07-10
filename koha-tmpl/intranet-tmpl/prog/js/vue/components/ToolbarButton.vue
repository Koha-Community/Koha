<template>
    <Link
        v-bind="$props"
        @addResource="$emit('addResource')"
        @deleteResource="$emit('deleteResource')"
        @editResource="$emit('editResource')"
    />
</template>

<script>
import Link from "./Link.vue";
export default {
    components: { Link },
    props: {
        action: {
            type: String,
            required: true,
        },
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
    emits: ["addResource", "deleteResource", "editResource"],
    name: "ToolbarButton",
};
</script>
