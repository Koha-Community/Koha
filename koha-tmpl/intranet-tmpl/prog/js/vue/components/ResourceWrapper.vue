<template>
    <component :is="getComponent()" v-bind="componentProps"> </component>
</template>

<script>
import { defineAsyncComponent } from "vue";
import BaseResource from "./BaseResource.vue";
import ResourceShow from "./ResourceShow.vue";

export default {
    components: { ResourceShow, BaseResource },
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
