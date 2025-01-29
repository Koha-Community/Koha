<template>
    <component :is="getComponent()" v-bind="componentProps"></component>
</template>

<script>
import { defineAsyncComponent } from "vue";

export default {
    methods: {
        getComponent() {
            const routeResource = this.$route.meta.self.parent.resource;
            return defineAsyncComponent(() => import(`./${routeResource}`));
        },
    },
    computed: {
        componentProps() {
            const routeName = this.$route.meta.self.name;
            if (routeName.includes("Show")) {
                return { routeAction: "show" };
            } else if (routeName.includes("Edit")) {
                return { routeAction: "edit" };
            } else if (routeName.includes("Add")) {
                return { routeAction: "add" };
            } else {
                return { routeAction: "list" };
            }
        },
    },
};
</script>

<style></style>
