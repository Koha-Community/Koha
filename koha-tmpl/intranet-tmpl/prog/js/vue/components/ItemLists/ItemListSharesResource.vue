<template>
    <BaseResource :routeAction="routeAction" :instancedResource="this">
        <template v-slot:list-header="slotProps">
            <h1>
                {{ $__("Shares for") }} <em>{{ slotProps.resource.name }}</em>
            </h1>
        </template>
    </BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { APIClient } from "../../fetch/api-client.js";
import { useRoute } from "vue-router";
import { $__ } from "@koha-vue/i18n";
import { storeToRefs } from "pinia";

export default {
    props: {
        routeAction: String,
    },
    setup(props, { emit }) {
        const route = useRoute();
        const item_list_id = route.params.id;

        const ItemListsStore = inject("ItemListsStore");
        const { config } = storeToRefs(ItemListsStore);

        const baseResource = useBaseResource({
            emit: emit,
            resourceName: "item_list_shares",
            nameAttr: "borrowernumber",
            idAttr: "borrowernumber",
            describeResource: resource => {
                if ($patron_to_html) {
                    return $patron_to_html(resource.patron);
                }
                return resource.borrowernumber;
            },
            components: {
                show: null,
                list: "ItemListSharesList",
                add: "ItemListSharesAdd",
                edit: null,
            },
            parentResource: {
                apiClient: APIClient.item_lists.item_lists,
                idAttr: "id",
            },
            apiClient: APIClient.item_lists.shares(item_list_id),
            table: {
                resourceTableUrl:
                    APIClient.item_lists.httpClient._baseURL +
                    "/" +
                    item_list_id +
                    "/shares",
            },
            i18n: {
                removeConfirmationMessage: $__(
                    "Are you sure you want to remove this share from the list?"
                ),
                removeSuccessMessage: $__("Share %s removed"),
                displayName: $__("Item list shares"),
                editLabel: $__("Edit share #%s"),
                emptyListMessage: $__("There are no shares defined"),
                newLabel: $__("Add share"),
            },
            defaultToolbarButtons: (buttons, resource) => {
                // Don't display the "add share" button without permission
                if (config.value?.permissions?.list_borrowers ?? true)
                    return buttons;
                if (!("list" in buttons)) return buttons;
                return {
                    ...buttons,
                    list: buttons.list.filter(x => x.action != "add"),
                };
            },
            props,
            navigationOnFormSave: "ItemListSharesList",
            resourceAttrs: [
                {
                    name: "patron_id",
                    required: true,
                    type: config.value?.permissions?.list_borrowers
                        ? "patronAutoComplete"
                        : "hidden",
                    label: $__("Patron"),
                    hideIn: ["List"],
                    patronAutoCompleteOptions: {
                        permissions: "catalogue",
                    },
                },
                {
                    name: "patron.cardnumber",
                    type: config.value?.permissions?.list_borrowers
                        ? "patronAutoComplete"
                        : "number",
                    patronEmbedName: "patron",
                    label: $__("Patron"),
                    hideIn: ["Form"],
                },
                {
                    name: "permission",
                    required: true,
                    type: "select",
                    options: [
                        {
                            value: "view",
                            description: $__("View"),
                        },
                        {
                            value: "edit",
                            description: $__("Edit"),
                        },
                    ],
                    requiredKey: "value",
                    selectLabel: "description",
                    label: $__("Permission"),
                },
            ],
        });

        const tableOptions = {
            options: {
                embed: "patron",
            },
            url: baseResource.getResourceTableUrl(),
            actions: {
                "-1": ["remove"],
            },
        };

        const onFormSave = (e, shareToSave) => {
            e.preventDefault();
            const item = JSON.parse(JSON.stringify(shareToSave)); // copy

            return baseResource.apiClient
                .add(item.patron_id, item.permission)
                .then(
                    resource => {
                        baseResource.setMessage($__("Shared!"));
                        return resource;
                    },
                    error => {}
                );
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
        };
    },
    name: "ItemListSharesResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>
