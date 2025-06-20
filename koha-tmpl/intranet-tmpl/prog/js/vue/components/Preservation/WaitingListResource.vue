<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    props: {
        routeAction: String,
    },
    setup(props) {
        const PreservationStore = inject("PreservationStore");
        const { config, itemsRecentlyAddedToWaitingList } =
            storeToRefs(PreservationStore);

        const additionalToolbarButtons = (resource, componentData) => {
            const { instancedResource } = componentData;
            const addItemsToWaitingList = (result, itemList) => {
                let items = [];
                itemList.barcode_list
                    .split("\n")
                    .forEach(barcode => items.push({ barcode }));
                const client = APIClient.preservation;
                client.waiting_list_items.createAll(items).then(
                    result => {
                        if (result.length) {
                            if (result.length != items.length) {
                                instancedResource.setWarning(
                                    instancedResource
                                        .$__(
                                            "%s new items added. %s items not found."
                                        )
                                        .format(
                                            result.length,
                                            items.length - result.length
                                        ),
                                    true
                                );
                            } else {
                                instancedResource.setMessage(
                                    instancedResource
                                        .$__("%s new items added.")
                                        .format(result.length),
                                    true
                                );
                            }
                            instancedResource.itemsRecentlyAddedToWaitingList =
                                result;
                            if (instancedResource.$refs.table) {
                                instancedResource.$refs.table.redraw(
                                    "/api/v1/preservation/waiting-list/items"
                                );
                            } else {
                                instancedResource.refreshTemplateState();
                            }
                        } else {
                            instancedResource.setWarning(
                                instancedResource.$__("No items added")
                            );
                        }
                    },
                    error => {}
                );
                itemList = "";
            };
            const addItemsToTrain = (result, { train_id_selected_for_add }) => {
                let item_ids =
                    instancedResource.itemsRecentlyAddedToWaitingList.map(
                        i => i.item_id
                    );
                instancedResource.router.push({
                    name: "TrainsFormAddItems",
                    params: {
                        train_id: train_id_selected_for_add,
                        item_ids: item_ids.join(","),
                    },
                });
                instancedResource.itemsRecentlyAddedToWaitingList = [];
            };
            return {
                list: [
                    {
                        onClick: () =>
                            instancedResource.setConfirmationDialog(
                                {
                                    title: instancedResource.$__(
                                        "Add items to waiting list"
                                    ),
                                    accept_label: instancedResource.$__("Save"),
                                    cancel_label:
                                        instancedResource.$__("Cancel"),
                                    inputs: [
                                        {
                                            name: "barcode_list",
                                            type: "textarea",
                                            label: instancedResource.$__(
                                                "Barcode list"
                                            ),
                                            required: true,
                                        },
                                    ],
                                    size: "modal-lg",
                                },
                                addItemsToWaitingList
                            ),
                        icon: "plus",
                        title: instancedResource.$__("Add to waiting list"),
                    },
                    instancedResource.itemsRecentlyAddedToWaitingList.length > 0
                        ? {
                              onClick: () =>
                                  instancedResource.setConfirmationDialog(
                                      {
                                          title: instancedResource.$__(
                                              "Add items to a train"
                                          ),
                                          accept_label:
                                              instancedResource.$__("Save"),
                                          cancel_label:
                                              instancedResource.$__("Cancel"),
                                          inputs: [
                                              {
                                                  name: "train_id_selected_for_add",
                                                  type: "relationshipSelect",
                                                  label: instancedResource.$__(
                                                      "Select a train"
                                                  ),
                                                  required: true,
                                                  relationshipAPIClient:
                                                      APIClient.preservation
                                                          .trains,
                                                  relationshipOptionLabelAttr:
                                                      "name",
                                                  relationshipRequiredKey:
                                                      "train_id",
                                              },
                                          ],
                                      },
                                      addItemsToTrain
                                  ),
                              icon: "plus",
                              title: instancedResource.$__(
                                  "Add last %s items to a train".format(
                                      instancedResource
                                          .itemsRecentlyAddedToWaitingList
                                          .length
                                  )
                              ),
                          }
                        : {},
                ],
            };
        };
        const defaultToolbarButtons = () => {
            return {
                list: [],
            };
        };

        const baseResource = useBaseResource({
            resourceName: "item",
            nameAttr: "biblio.title",
            idAttr: "itemnumber",
            listComponent: "WaitingList",
            apiClient: APIClient.preservation.waiting_list_items,
            resourceTableUrl:
                APIClient.preservation.httpClient._baseURL +
                "/waiting-list/items",
            i18n: {
                deleteConfirmationMessage: __(
                    "Are you sure you want to remove this item from the waiting list?"
                ),
                deleteSuccessMessage: __("Item removed from the waiting list"),
                displayName: __("Item"),
                displayNameLowerCase: __("item"),
                displayNamePlural: __("Items"),
                editLabel: null,
                emptyListMessage: __("There are no items in the waiting list"),
                newLabel: __("Add to waiting list"),
            },
            config,
            itemsRecentlyAddedToWaitingList,
            props,
            additionalToolbarButtons,
            defaultToolbarButtons,
            resourceAttrs: [
                {
                    name: "itemnumber",
                    label: __("ID"),
                    type: "text",
                    hideIn: ["List"],
                },
                {
                    name: "biblio.title",
                    label: __("Title"),
                    type: "text",
                    tableColumnDefinition: {
                        data: "biblio.title",
                        title: __("Title"),
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return `<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=${row.biblio.biblio_id}">${row.biblio.title}</a>`;
                        },
                    },
                },
                {
                    name: "biblio.author",
                    label: __("Author"),
                    type: "text",
                },
                {
                    name: "callnumber",
                    label: __("Call number"),
                    type: "text",
                },
                {
                    name: "external_id",
                    label: __("Barcode"),
                    type: "text",
                },
            ],
        });

        const doRemoveItem = (item, dt, event) => {
            baseResource.setConfirmationDialog(
                {
                    title: baseResource.$__(
                        "Are you sure you want to remove this item from the waiting list?"
                    ),
                    message: item.barcode,
                    accept_label: baseResource.$__("Yes, remove"),
                    cancel_label: baseResource.$__("No, do not remove"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.waiting_list_items.delete(item.item_id).then(
                        success => {
                            baseResource.setMessage(
                                baseResource.$__(
                                    "Item removed from the waiting list"
                                ),
                                true
                            );
                            dt.draw();
                        },
                        error => {}
                    );
                }
            );
        };

        const tableOptions = {
            url: "/api/v1/preservation/waiting-list/items",
            options: { embed: "biblio" },
            add_filters: true,
            actions: {
                0: ["show"],
                1: ["show"],
                "-1": [
                    {
                        removeItem: {
                            text: baseResource.$__("Remove"),
                            icon: "fa fa-close",
                            callback: doRemoveItem,
                        },
                    },
                ],
            },
        };

        baseResource.created();

        return {
            ...baseResource,
            tableOptions,
        };
    },
    emits: ["select-resource"],
    name: "WaitingListResource",
    components: {
        BaseResource,
    },
};
</script>
