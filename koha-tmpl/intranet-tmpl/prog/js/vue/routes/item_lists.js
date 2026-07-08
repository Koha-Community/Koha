import { markRaw } from "vue";

import ResourceWrapper from "../components/ResourceWrapper.vue";

import { $__ } from "@koha-vue/i18n";

export default {
    title: $__("Item Lists"),
    path: "/cgi-bin/koha/lists/items",
    resource: "ItemLists/ItemListsResource.vue",
    is_base: true,
    is_default: true,
    children: [
        {
            path: "",
            name: "ItemListsList",
            component: markRaw(ResourceWrapper),
        },
        {
            component: markRaw(ResourceWrapper),
            name: "ItemListsFormAdd",
            path: "add",
            title: $__("Add item list"),
        },
        {
            component: markRaw(ResourceWrapper),
            name: "ItemListsFormAddEdit",
            path: "edit/:id",
            title: $__("Edit item list"),
        },
        {
            component: markRaw(ResourceWrapper),
            path: ":id",
            resource: "ItemLists/ItemListItemsResource.vue",
            title: "{name}",
            children: [
                {
                    path: "",
                    name: "ItemListItemsList",
                    component: markRaw(ResourceWrapper),
                },
                {
                    component: markRaw(ResourceWrapper),
                    is_end_node: true,
                    name: "ItemListItemsAdd",
                    path: "add",
                    title: $__("Add item"),
                },
                {
                    component: markRaw(ResourceWrapper),
                    path: "shares",
                    resource: "ItemLists/ItemListSharesResource.vue",
                    title: "Shares",
                    children: [
                        {
                            path: "",
                            name: "ItemListSharesList",
                            component: markRaw(ResourceWrapper),
                        },
                        {
                            component: markRaw(ResourceWrapper),
                            is_end_node: true,
                            name: "ItemListSharesAdd",
                            path: "add",
                            title: $__("Add share"),
                        },
                    ],
                },
            ],
        },
    ],
};
