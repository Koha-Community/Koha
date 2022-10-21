<template>
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            <li v-for="(item, counter) in breadCrumbs" v-bind:key="counter">
                <router-link
                    v-if="!item.path && counter == breadCrumbs.length - 1"
                    :to="`${currentRoute}`"
                >
                    {{ $t(item.text) }}</router-link
                >
                <router-link v-else :to="item.path">
                    {{ $t(item.text) }}</router-link
                >
            </li>
        </ol>
    </nav>
</template>

<script>
import { useRouter } from 'vue-router'
export default {
    computed: {
        breadCrumbs() {
            if (this.$route.meta.breadcrumb) {
                return this.$route.meta.breadcrumb()
            }
        },
        currentRoute() { return this.$route.path }
    },
};
</script>