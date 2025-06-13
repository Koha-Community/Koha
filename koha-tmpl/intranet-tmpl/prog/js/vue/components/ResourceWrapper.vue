<template>
    <component :is="getComponent()" v-bind="componentProps"></component>
</template>

<script>
import { computed, defineAsyncComponent } from "vue";
import { useRoute } from "vue-router";

export default {
    setup() {
        const route = useRoute();
        const locateRouteParentWithResource = route => {
            const parent = route.meta.self.parent;
            if (parent.hasOwnProperty("resource") && parent.resource) {
                return parent.resource;
            }
            return locateRouteParentWithResource(parent);
        };
        const getComponent = () => {
            const routeResource = locateRouteParentWithResource(route);
            return defineAsyncComponent(() => import(`./${routeResource}`));
        };

        const componentProps = computed(() => {
            const routeName = route.meta.self.name;
            if (routeName.includes("Show")) {
                return { routeAction: "show" };
            } else if (routeName.includes("Edit")) {
                return { routeAction: "edit" };
            } else if (routeName.includes("Add")) {
                return { routeAction: "add" };
            } else {
                return { routeAction: "list" };
            }
        });
        return {
            getComponent,
            componentProps,
        };
    },
};
</script>

<style></style>
