<template>
    <router-link :to="to" :class="class"
        ><font-awesome-icon v-if="icon" :icon="icon" /> {{ title }}</router-link
    >
</template>

<script>
export default {
    props: {
        to: {
            type: [String, Object],
        },
        class: {
            type: String,
            default: "btn btn-default",
        },
        icon: {
            type: String,
            required: false,
        },
        title: {
            type: String,
        },
    },
    name: "Toolbar",
}
</script>
