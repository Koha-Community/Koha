<template>
    <component :is="getComponent()" v-bind="componentProps"></component>
</template>

<script>
import { defineAsyncComponent } from "vue";

export default {
    methods: {
        getComponent() {
            const routeResource = this.locateRouteParentWithResource(
                this.$route
            );
            return defineAsyncComponent(() => import(`./${routeResource}`));
        },
        locateRouteParentWithResource(route) {
            const parent = route.meta.self.parent;
            if (parent.hasOwnProperty("resource") && parent.resource) {
                return parent.resource;
            }
            return this.locateRouteParentWithResource(parent);
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
