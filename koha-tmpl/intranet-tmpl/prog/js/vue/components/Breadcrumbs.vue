<template>
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            <template v-for="(item, idx) in breadcrumbs" v-bind:key="idx">
                <NavigationItem
                    v-if="idx < breadcrumbs.length - 1"
                    :item="item"
                    :params="params"
                ></NavigationItem>
                <NavigationItem
                    v-else
                    :item="{
                        ...item,
                        disabled: true,
                        path: undefined,
                        href: undefined,
                    }"
                    :params="params"
                ></NavigationItem>
            </template>
        </ol>
    </nav>
</template>

<script>
import { inject } from "vue"
import { storeToRefs } from "pinia"
import NavigationItem from "./NavigationItem.vue"
export default {
    name: "Breadcrumbs",
    setup: () => {
        const navigationStore = inject("navigationStore")
        const { breadcrumbs } = storeToRefs(navigationStore)
        const { params } = navigationStore
        return {
            breadcrumbs,
            params,
        }
    },
    components: {
        NavigationItem,
    },
}
</script>
