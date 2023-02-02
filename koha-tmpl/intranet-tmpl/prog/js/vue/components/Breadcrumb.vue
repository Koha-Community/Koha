<template>
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            <li v-for="(item, counter) in breadCrumbs" v-bind:key="counter">
                <router-link
                    v-if="!item.path && counter == breadCrumbs.length - 1"
                    :to="`${currentRoute}`"
                >
                    {{ $__(item.text) }}</router-link
                >
                <router-link v-else-if="item.path" :to="item.path">
                    {{ $__(item.text) }}</router-link
                >
                <a v-else class="disabled"> {{ $__(item.text) }}</a>
            </li>
        </ol>
    </nav>
</template>

<script>
import { useRouter } from "vue-router"
export default {
    computed: {
        breadCrumbs() {
            if (this.$route.meta.breadcrumb) {
                return this.$route.meta.breadcrumb()
            }
        },
        currentRoute() {
            return this.$route.path
        },
    },
}
</script>

<style scoped>
a.disabled {
    padding: 0.6em 0.3em;
    text-decoration: none;
    color: #000;
}
</style>
