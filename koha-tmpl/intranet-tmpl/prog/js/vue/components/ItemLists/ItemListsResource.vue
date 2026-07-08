<template>
    <BaseResource :routeAction="routeAction" :instancedResource="this">
        <template v-slot:list-header>
            <h1>{{ $__("Item Lists") }}</h1>
        </template>
    </BaseResource>
</template>
<script>
import { inject } from "vue";
import { useRouter } from "vue-router";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";
import { storeToRefs } from "pinia";

export default {
    props: {
        routeAction: String,
    },
    setup(props) {
        const router = useRouter();

        const ItemListsStore = inject("ItemListsStore");
        const { config } = storeToRefs(ItemListsStore);

        const visibilityLabels = {
            private: $__("Private"),
            group: $__("Group"),
            public: $__("Public"),
        };

        const baseResource = useBaseResource({
            resourceName: "item_list",
            nameAttr: "name",
            idAttr: "id",
            components: {
                show: "ItemListItemsList",
                list: "ItemListsList",
                add: "ItemListsFormAdd",
                edit: "ItemListsFormAddEdit",
            },
            apiClient: APIClient.item_lists.item_lists,
            table: {
                resourceTableUrl: APIClient.item_lists.httpClient._baseURL,
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this item list?"
                ),
                deleteSuccessMessage: $__("Item list %s deleted"),
                displayName: $__("Item list"),
                editLabel: $__("Edit item list #%s"),
                emptyListMessage: $__("There are no item lists defined"),
                newLabel: $__("New item list"),
            },
            defaultToolbarButtons: (buttons, resource) => {
                // Don't display the "create item list" button without permission
                if (config.value?.permissions?.create_item_lists ?? true)
                    return buttons;
                if (!("list" in buttons)) return buttons;
                return {
                    ...buttons,
                    list: buttons.list.filter(x => x.action != "add"),
                };
            },
            props,
            navigationOnFormSave: "ItemListsList",
            resourceAttrs: [
                {
                    name: "id",
                    required: true,
                    type: "text",
                    label: $__("ID"),
                    hideIn: ["Form"],
                },
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: $__("Name"),
                },
                {
                    name: "item_list_contents_count",
                    required: true,
                    type: "number",
                    label: $__("Items"),
                    hideIn: ["Form"],
                    tableColumnDefinition: {
                        title: $__("Items"),
                        data: "item_list_contents_count",
                        searchable: false,
                    },
                },
                {
                    name: "owner",
                    required: true,
                    type: config.value?.permissions?.list_borrowers
                        ? "patronAutoComplete"
                        : "hidden",
                    label: $__("Owner"),
                    hideIn: ["List"],
                    defaultValue: config.value?.borrowernumber,
                    patronAutoCompleteOptions: {
                        permissions: "catalogue",
                    },
                },
                {
                    name: "visibility",
                    required: true,
                    type: "select",
                    options: Object.entries(visibilityLabels).map(x => ({
                        value: x[0],
                        description: x[1],
                    })),
                    defaultValue: "private",
                    requiredKey: "value",
                    selectLabel: "description",
                    label: $__("Visibility"),
                    tableColumnDefinition: {
                        title: $__("Visibility"),
                        data: "visibility",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            let result = visibilityLabels[row.visibility];
                            if (row.item_list_shares_count == 1) {
                                result = $__("%s (%s share)").format(
                                    visibilityLabels[row.visibility],
                                    row.item_list_shares_count
                                );
                            } else if (row.item_list_shares_count > 1) {
                                result = $__("%s (%s shares)").format(
                                    visibilityLabels[row.visibility],
                                    row.item_list_shares_count
                                );
                            }

                            if (!row.can_update) {
                                return escape_str(result);
                            }

                            return (
                                '<a href="/cgi-bin/koha/lists/items/' +
                                row.id +
                                '/shares">' +
                                escape_str(result) +
                                "</a>"
                            );
                        },
                    },
                },
                {
                    name: "created_date",
                    type: "date",
                    label: $__("Created Date"),
                    required: false,
                    hideIn: ["Form"],
                },
                {
                    name: "updated_date",
                    type: "date",
                    label: $__("Updated Date"),
                    required: false,
                    hideIn: ["Form"],
                },
            ],
        });

        const tableOptions = {
            options: {
                embed: "item_list_contents+count,item_list_shares+count",
            },
            url: baseResource.getResourceTableUrl(),
            actionsDropdown: true,
            actions: {
                "-1": [
                    {
                        edit: {
                            text: $__("Edit"),
                            icon: "fa fa-pencil",
                            should_display: row => row?.can_update ?? true,
                        },
                    },
                    {
                        add_items: {
                            text: $__("Add Items"),
                            icon: "fa fa-plus",
                            should_display: row => row?.can_manage ?? true,
                        },
                    },
                    {
                        add_shares: {
                            text: $__("Add Shares"),
                            icon: "fa fa-plus",
                            should_display: row => row?.can_update ?? true,
                        },
                    },
                    {
                        delete: {
                            text: $__("Delete"),
                            icon: "fa fa-trash",
                            should_display: row => row?.can_delete ?? true,
                        },
                    },
                ],
            },
            additionalEvents: {
                add_items: resource => {
                    window.location.href =
                        "/cgi-bin/koha/lists/items/" + resource.id;
                },
                add_shares: resource => {
                    window.location.href =
                        "/cgi-bin/koha/lists/items/" + resource.id + "/shares";
                },
            },
        };

        const onFormSave = (e, itemListToSave) => {
            e.preventDefault();
            const itemList = JSON.parse(JSON.stringify(itemListToSave)); // copy
            const itemListId = itemList.id;

            delete itemList.id;
            delete itemList.item_list_contents_count;
            delete itemList.created_date;
            delete itemList.updated_date;
            delete itemList.can_read;
            delete itemList.can_update;
            delete itemList.can_delete;
            delete itemList.can_manage;
            delete itemList.item_list_shares_count;

            if (itemListId) {
                // update
                return baseResource.apiClient.update(itemList, itemListId).then(
                    resource => {
                        baseResource.setMessage($__("Item list updated!"));
                        return resource;
                    },
                    error => {}
                );
            } else {
                return baseResource.apiClient.create(itemList).then(
                    resource => {
                        baseResource.setMessage($__("Item list created!"));
                        return resource;
                    },
                    error => {}
                );
            }
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
        };
    },
    name: "ItemListsResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>
