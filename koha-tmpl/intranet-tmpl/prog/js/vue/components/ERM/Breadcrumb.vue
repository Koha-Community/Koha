<template>
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            <li v-for="(item, counter) in breadCrumbs" v-bind:key="counter">
                <router-link :to="item.path"> {{ item.text }}</router-link>
            </li>
        </ol>
    </nav>
</template>

<script>
export default {
    computed: {
        breadCrumbs() {
            return this.$route.meta.breadcrumb
        },
    },
};
</script>