<template>
    <Link
        v-bind="$props"
        @go-to-add-resource="$emit('go-to-add-resource')"
        @delete-resource="$emit('delete-resource')"
        @go-to-edit-resource="$emit('go-to-edit-resource')"
    />
</template>

<script>
import Link from "./Link.vue";
export default {
    components: { Link },
    props: {
        action: {
            type: String,
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
    emits: ["go-to-add-resource", "delete-resource", "go-to-edit-resource"],
    name: "Toolbar",
};
</script>
