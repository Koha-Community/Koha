<template>
    <component :is="getComponent()" v-bind="componentProps"> </component>
</template>

<script>
import { defineAsyncComponent } from "vue";
import BaseResource from "./BaseResource.vue";
import ResourceShow from "./ResourceShow.vue";

export default {
    components: { ResourceShow, BaseResource },
    data() {
        return {
            component: null,
        };
    },
    methods: {
        getComponent() {
            const routeResource = this.$route.meta.self.parent.resource;
            const resourceModule = this.$route.meta.self.parent.module;
            const componentName =
                routeResource.charAt(0).toUpperCase() + routeResource.slice(1);
            const importPath = `./${
                resourceModule ? `${resourceModule}/` : ""
            }${componentName}Resource.vue`;
            const component = defineAsyncComponent(
                () => import(`${importPath}`)
            );
            this.component = component;

            return component;
        },
    },
    computed: {
        componentProps() {
            const routeName = this.$route.meta.self.name;
            if (routeName.includes("Show")) {
                return { action: "show" };
            } else if (routeName.includes("Edit")) {
                return { action: "edit" };
            } else if (routeName.includes("Add")) {
                return { action: "add" };
            } else {
                return { action: "list" };
            }
        },
    },
};
</script>

<style></style>
