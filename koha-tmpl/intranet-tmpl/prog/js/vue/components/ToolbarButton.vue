<template>
    <router-link :to="to" class="btn btn-default"
        ><font-awesome-icon v-if="icon" :icon="icon" /> {{ title }}</router-link
    >
</template>

<script>
export default {
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
    },
    name: "Toolbar",
}
</script>
