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
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
    },
    setup(props) {
        const format_date = $date;

        const PreservationStore = inject("PreservationStore");
        const { config } = storeToRefs(PreservationStore);

        const additionalFilters = [
            {
                id: "status_filter",
                name: "status_filter",
                type: "radio",
                options: [
                    { value: "", description: $__("All") },
                    { value: "closed", description: $__("Closed") },
                    { value: "sent", description: $__("Sent") },
                    {
                        value: "received",
                        description: $__("Received"),
                    },
                ],
                value: "",
            },
        ];
        const additionalToolbarButtons = (resource, componentData) => {
            const { instancedResource } = componentData;

            const updateTrainDate = async (resource, attribute) => {
                let train = JSON.parse(JSON.stringify(resource));
                let train_id = train.train_id;
                delete train.train_id;
                delete train.items;
                delete train.default_processing;
                train[attribute] = new Date();
                const client = APIClient.preservation;
                return client.trains
                    .update(train, train_id)
                    .then(() => instancedResource.refreshTemplateState());
            };
            const closeTrain = resource => {
                updateTrainDate(resource, "closed_on");
            };
            const sendTrain = resource => {
                updateTrainDate(resource, "sent_on");
            };
            const receiveTrain = resource => {
                updateTrainDate(resource, "received_on");
            };
            return {
                show: [
                    resource?.closed_on == null
                        ? {
                              to: {
                                  name: "TrainsFormAddItem",
                                  params: { train_id: resource?.train_id },
                              },
                              icon: "plus",
                              title: $__("Add items"),
                              index: -1,
                          }
                        : {},
                    !resource?.closed_on &&
                    !resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => closeTrain(resource),
                              icon: "remove",
                              title: $__("Close"),
                          }
                        : {},
                    resource?.closed_on &&
                    !resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => sendTrain(resource),
                              icon: "paper-plane",
                              title: $__("Send"),
                          }
                        : {},
                    resource?.closed_on &&
                    resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => receiveTrain(resource),
                              icon: "inbox",
                              title: $__("Receive"),
                          }
                        : {},
                ],
            };
        };

        const baseResource = useBaseResource({
            resourceName: "train",
            nameAttr: "name",
            idAttr: "train_id",
            components: {
                show: "TrainsShow",
                list: "TrainsList",
                add: "TrainsFormAdd",
                edit: "TrainsFormAddEdit",
            },
            apiClient: APIClient.preservation.trains,
            table: {
                resourceTableUrl:
                    APIClient.preservation.httpClient._baseURL + "trains",
                addAdditionalFilters: true,
                additionalFilters,
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this train?"
                ),
                deleteSuccessMessage: $__("Train %s deleted"),
                displayName: $__("Train"),
                displayNameLowerCase: $__("train"),
                displayNamePlural: $__("Train"),
                editLabel: $__("Edit train #%s"),
                emptyListMessage: $__("There are no trains defined"),
                newLabel: $__("New train"),
            },
            config,
            props,
            additionalToolbarButtons,
            moduleStore: "PreservationStore",
            resourceAttrs: [
                {
                    name: "train_id",
                    label: $__("ID"),
                    type: "text",
                    hideIn: ["Form", "Show"],
                },
                {
                    name: "name",
                    label: $__("Name"),
                    required: true,
                    type: "text",
                },
                {
                    name: "description",
                    required: true,
                    type: "textarea",
                    label: $__("Description"),
                    hideIn: ["List"],
                },
                {
                    name: "not_for_loan",
                    type: "select",
                    label: $__("Status for item added to this train"),
                    avCat: "av_notforloan",
                    disabled: train => (train.train_id ? true : false),
                    defaultValue:
                        config.value.settings.not_for_loan_default_train_in,
                    hideIn: ["List"],
                },
                {
                    name: "default_processing_id",
                    type: "relationshipSelect",
                    label: $__("Default processing"),
                    required: true,
                    relationshipAPIClient: APIClient.preservation.processings,
                    relationshipOptionLabelAttr: "name",
                    relationshipRequiredKey: "processing_id",
                    showElement: {
                        type: "text",
                        value: "default_processing.name",
                    },
                    hideIn: ["List"],
                },
                {
                    name: "created_on",
                    type: "date",
                    label: $__("Created on"),
                    required: false,
                    hideIn: ["Form", "Show"],
                },
                {
                    name: "closed_on",
                    type: "date",
                    label: $__("Closed on"),
                    required: false,
                    format: format_date,
                    hidden: resource => resource.closed_on,
                    hideIn: ["Form"],
                },
                {
                    name: "sent_on",
                    type: "date",
                    label: $__("Sent on"),
                    required: false,
                    format: format_date,
                    hidden: resource => resource.sent_on,
                    hideIn: ["Form"],
                },
                {
                    name: "received_on",
                    type: "date",
                    label: $__("Received on"),
                    required: false,
                    format: format_date,
                    hidden: resource => resource.received_on,
                    hideIn: ["Form"],
                },
            ],
        });

        const doAddItems = (train, dt, event) => {
            if (train.closed_on != null) {
                baseResource.setWarning(
                    $__("Cannot add items to a closed train")
                );
            } else {
                baseResource.router.push({
                    name: "TrainsFormAddItem",
                    params: { train_id: train.train_id },
                });
            }
        };

        const defaults = baseResource.getFilterValues(
            baseResource.route.query,
            additionalFilters
        );
        const tableOptions = {
            options: {
                order: [
                    [2, "desc"],
                    [3, "asc"],
                    [4, "asc"],
                    [5, "asc"],
                ],
            },
            url: () => tableUrl(defaults),
            add_filters: true,
            actions: {
                "-1": [
                    "edit",
                    "delete",
                    {
                        addItems: {
                            text: $__("Add items"),
                            icon: "fa fa-plus",
                            callback: doAddItems,
                        },
                    },
                ],
            },
        };

        const onFormSave = (e, trainToSave) => {
            e.preventDefault();

            let train = JSON.parse(JSON.stringify(trainToSave)); // copy
            let train_id = train.train_id;

            delete train.train_id;
            delete train.default_processing;
            delete train.items;

            const client = APIClient.preservation;
            if (train_id) {
                return client.trains.update(train, train_id).then(
                    train => {
                        baseResource.setMessage($__("Train updated"));
                        return train;
                    },
                    error => {}
                );
            } else {
                return client.trains.create(train).then(
                    train => {
                        baseResource.setMessage($__("Train created"));
                        return train;
                    },
                    error => {}
                );
            }
        };
        const getTableFilterFormElementsLabel = () => {
            return $__("Filter by:");
        };
        const tableUrl = filters => {
            let url = baseResource.getResourceTableUrl();
            let q;
            if (filters.status_filter == "closed") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": null,
                    "me.received_on": null,
                };
            } else if (filters.status_filter == "sent") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": { "!=": null },
                    "me.received_on": null,
                };
            } else if (filters.status_filter == "received") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": { "!=": null },
                    "me.received_on": { "!=": null },
                };
            }
            if (q) {
                url += "?" + new URLSearchParams({ q: JSON.stringify(q) });
            }

            return url;
        };
        const filterTable = async (filters, table, embedded = false) => {
            let { href } = baseResource.router.resolve({ name: "TrainsList" });
            let new_route = baseResource.build_url(href, filters);
            baseResource.router.push(new_route);

            table.redraw(tableUrl(filters));
        };
        const afterResourceFetch = (componentData, resource, caller) => {
            if (caller === "show") {
                let display_table = componentData.resource.value.items.every(
                    item =>
                        item.processing_id ==
                        componentData.resource.value.default_processing_id
                );
                componentData.additionalProps.value.item_table = {
                    display: false,
                    data: [],
                    columns: [],
                };
                if (display_table) {
                    componentData.additionalProps.value.item_table.data = [];
                    componentData.resource.value.items.forEach(item => {
                        let item_row = {};
                        componentData.resource.value.default_processing.attributes.forEach(
                            attribute => {
                                item_row[attribute.processing_attribute_id] =
                                    item.attributes
                                        .filter(
                                            a =>
                                                a.processing_attribute_id ==
                                                attribute.processing_attribute_id
                                        )
                                        .map(a => a._strings.value.str);
                            }
                        );
                        item_row.item = item;
                        componentData.additionalProps.value.item_table.data.push(
                            item_row
                        );
                    });
                    componentData.additionalProps.value.item_table.columns = [];
                    componentData.additionalProps.value.item_table.columns.push(
                        {
                            name: "checkboxes",
                            className: "checkboxes",
                            width: "5%",
                            render: (data, type, row) => {
                                return "";
                            },
                        },
                        {
                            name: "",
                            title: $__("ID"),
                            data: "item.user_train_item_id",
                        }
                    );
                    resource.default_processing.attributes.forEach(a =>
                        componentData.additionalProps.value.item_table.columns.push(
                            {
                                name: a.name,
                                title: a.name,
                                data: a.processing_attribute_id,
                                render: (data, type, row) => {
                                    return data.join("<br/>");
                                },
                            }
                        )
                    );
                    componentData.additionalProps.value.item_table.columns.push(
                        {
                            name: "actions",
                            className: "actions noExport",
                            title: $__("Actions"),
                            searchable: false,
                            orderable: false,
                            render: (data, type, row) => {
                                return "";
                            },
                        }
                    );
                }
                componentData.additionalProps.value.item_table.display =
                    display_table;
            }
        };
        const appendToShow = componentData => {
            return [
                {
                    type: "component",
                    name: $__("Items"),
                    hidden: train => train.items.length,
                    componentPath:
                        "@koha-vue/components/Preservation/TrainItemsTable.vue",
                    componentProps: {
                        train: {
                            type: "resource",
                        },
                        item_table: {
                            type: "object",
                            value: componentData.additionalProps.item_table,
                        },
                    },
                },
            ];
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
            filterTable,
            afterResourceFetch,
            appendToShow,
            getTableFilterFormElementsLabel,
        };
    },
    name: "TrainResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>

<style scoped>
:deep(.filters input[type="radio"]) {
    min-width: 0 !important;
}
:deep(.filters input[type="button"]) {
    margin-left: 1rem;
}
</style>
