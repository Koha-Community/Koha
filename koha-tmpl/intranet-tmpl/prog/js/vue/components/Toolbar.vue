<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            v-for="(option, index) in options"
            :key="index"
            :to="{ name: option.to }"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__(`${option.button_title}`) }}</router-link
        >
    </div>
</template>

<script>
export default {
    props: {
        options: Array,
    },
    name: "Toolbar",
}
</script>
