<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_notforloan } = storeToRefs(AVStore);

        const PreservationStore = inject("PreservationStore");
        const { config } = storeToRefs(PreservationStore);

        return {
            ...BaseResource.setup({
                resourceName: "train",
                nameAttr: "name",
                idAttr: "train_id",
                showComponent: "TrainsShow",
                listComponent: "TrainsList",
                addComponent: "TrainsFormAdd",
                editComponent: "TrainsFormAddEdit",
                apiClient: APIClient.preservation.trains,
                resourceTableUrl:
                    APIClient.preservation.httpClient._baseURL + "trains",
                resourceListFiltersRequired: true,
                i18n: {
                    deleteConfirmationMessage: __(
                        "Are you sure you want to remove this train?"
                    ),
                    deleteSuccessMessage: __("Train %s deleted"),
                    displayName: __("Train"),
                    displayNameLowerCase: __("train"),
                    displayNamePlural: __("Train"),
                    editLabel: __("Edit train #%s"),
                    emptyListMessage: __("There are no trains defined"),
                    newLabel: __("New train"),
                },
                av_notforloan,
                config,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilterFormElements();
        const defaults = this.getFilterValues(this.$route.query, tableFilters);

        return {
            resourceAttrs: [
                {
                    name: this.idAttr,
                    label: __("ID"),
                    type: "text",
                    hideInForm: true,
                    hideInShow: true,
                    showInTable: true,
                },
                {
                    name: "name",
                    label: __("Name"),
                    required: true,
                    type: "text",
                    showInTable: true,
                },
                {
                    name: "description",
                    required: true,
                    type: "textarea",
                    textAreaCols: 50,
                    textAreaRows: 10,
                    label: __("Description"),
                    showInTable: false,
                },
                {
                    name: "not_for_loan",
                    type: "select",
                    label: __("Status for item added to this train"),
                    avCat: "av_notforloan",
                    disabled: train => (train.train_id ? true : false),
                    defaultValue:
                        this.config.settings.not_for_loan_default_train_in,
                },
                {
                    name: "default_processing_id",
                    type: "relationshipSelect",
                    label: __("Default processing"),
                    required: true,
                    relationshipAPIClient: APIClient.preservation.processings,
                    relationshipOptionLabelAttr: "name",
                    relationshipRequiredKey: "processing_id",
                    showElement: {
                        type: "text",
                        value: "default_processing.name",
                    },
                },
                {
                    name: "created_on",
                    type: "date",
                    label: __("Created on"),
                    required: false,
                    hideInForm: true,
                    showInTable: true,
                    hideInShow: true,
                },
                {
                    name: "closed_on",
                    type: "date",
                    label: __("Closed on"),
                    required: false,
                    hideInForm: true,
                    showInTable: true,
                    format: this.format_date,
                    hidden: resource => resource.closed_on,
                },
                {
                    name: "sent_on",
                    type: "date",
                    label: __("Sent on"),
                    required: false,
                    hideInForm: true,
                    showInTable: true,
                    format: this.format_date,
                    hidden: resource => resource.sent_on,
                },
                {
                    name: "received_on",
                    type: "date",
                    label: __("Received on"),
                    required: false,
                    hideInForm: true,
                    showInTable: true,
                    format: this.format_date,
                    hidden: resource => resource.received_on,
                },
            ],
            tableOptions: {
                options: {
                    order: [
                        [2, "desc"],
                        [3, "asc"],
                        [4, "asc"],
                        [5, "asc"],
                    ],
                },
                url: () => this.tableUrl(defaults),
                add_filters: true,
                actions: {
                    0: ["show"],
                    1: ["show"],
                    "-1": [
                        "edit",
                        "delete",
                        {
                            addItems: {
                                text: this.$__("Add items"),
                                icon: "fa fa-plus",
                                callback: this.doAddItems,
                            },
                        },
                    ],
                },
            },
            tableFilters,
        };
    },
    methods: {
        async updateTrainDate(resource, attribute) {
            let train = JSON.parse(JSON.stringify(resource));
            let train_id = train.train_id;
            delete train.train_id;
            delete train.items;
            delete train.default_processing;
            train[attribute] = new Date();
            const client = APIClient.preservation;
            //if (train_id) {
            return client.trains
                .update(train, train_id)
                .then(() => this.getTrain(train_id));
            //} else {
            //    return client.trains
            //        .create(train)
            //        .then(() => this.getTrain(this.train.train_id));
            //}
        },
        closeTrain(resource) {
            this.updateTrainDate(resource, "closed_on");
        },
        sendTrain(resource) {
            this.updateTrainDate(resource, "sent_on");
        },
        receiveTrain(resource) {
            this.updateTrainDate(resource, "received_on").then(
                success => {
                    // Rebuild the table to show the "copy" button
                    $("#" + this.table_id)
                        .DataTable()
                        .destroy();
                    this.build_datatable();
                },
                error => {}
            );
        },
        onSubmit(e, trainToSave) {
            e.preventDefault();

            let train = JSON.parse(JSON.stringify(trainToSave)); // copy
            let train_id = train.train_id;

            delete train.train_id;
            delete train.default_processing;
            delete train.items;

            const client = APIClient.preservation;
            if (train_id) {
                client.trains.update(train, train_id).then(
                    success => {
                        this.setMessage(this.$__("Train updated"));
                        this.$router.push({ name: "TrainsList" });
                    },
                    error => {}
                );
            } else {
                client.trains.create(train).then(
                    success => {
                        this.setMessage(this.$__("Train created"));
                        this.$router.push({ name: "TrainsList" });
                    },
                    error => {}
                );
            }
        },
        getTableFilterFormElementsLabel() {
            return this.$__("Filter by:");
        },
        getTableFilterFormElements() {
            return [
                {
                    id: "status_filter",
                    name: "status_filter",
                    type: "radio",
                    options: [
                        { value: "", description: __("All") },
                        { value: "closed", description: _("Closed") },
                        { value: "sent", description: __("Sent") },
                        { value: "received", description: __("Received") },
                    ],
                    value: "",
                },
            ];
        },
        tableUrl(filters) {
            let url = this.getResourceTableUrl();
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
        },
        async filterTable(filters, table, embedded = false) {
            let { href } = this.$router.resolve({ name: "TrainsList" });
            let new_route = this.build_url(href, filters);
            this.$router.push(new_route);
            //if (this.$refs.table) {
            //    this.$refs.table.redraw(this.table_url());
            //}
            table.redraw(this.tableUrl(filters));

            //if (!embedded) {
            //    if (filters.by_expired && !filters.max_expiration_date) {
            //        filters.max_expiration_date = new Date()
            //            .toISOString()
            //            .substring(0, 10);
            //    }
            //    if (!filters.by_expired) {
            //        filters.max_expiration_date = "";
            //    }
            //    let { href } = this.$router.resolve({ name: "AgreementsList" });
            //    let new_route = this.build_url(href, filters);
            //    this.$router.push(new_route);
            //}
            //table.redraw(this.tableUrl(filters));
        },
        doAddItems(train, dt, event) {
            if (train.closed_on != null) {
                this.setWarning(this.$__("Cannot add items to a closed train"));
            } else {
                this.$router.push({
                    name: "TrainsFormAddItem",
                    params: { train_id: train.train_id },
                });
            }
        },
        additionalToolbarButtons(resource) {
            return {
                show: [
                    resource?.closed_on == null
                        ? {
                              to: {
                                  name: "TrainsFormAddItem",
                                  params: { train_id: resource?.train_id },
                              },
                              icon: "plus",
                              title: __("Add items"),
                              index: -1,
                          }
                        : {},
                    !resource?.closed_on &&
                    !resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => this.closeTrain(resource),
                              icon: "remove",
                              title: __("Close"),
                          }
                        : {},
                    resource?.closed_on &&
                    !resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => this.sendTrain(resource),
                              icon: "paper-plane",
                              title: __("Send"),
                          }
                        : {},
                    resource?.closed_on &&
                    resource?.sent_on &&
                    !resource?.received_on
                        ? {
                              onClick: () => this.receiveTrain(resource),
                              icon: "inbox",
                              title: __("Receive"),
                          }
                        : {},
                ].filter(b => Object.keys(b).length),
            };
        },
        afterResourceFetch(componentData, resource, caller) {
            if (caller === "show") {
                let display_table = componentData.resource.items.every(
                    item =>
                        item.processing_id ==
                        componentData.resource.default_processing_id
                );
                componentData.item_table = {
                    display: false,
                    data: [],
                    columns: [],
                };
                if (display_table) {
                    componentData.item_table.data = [];
                    componentData.resource.items.forEach(item => {
                        let item_row = {};
                        componentData.resource.default_processing.attributes.forEach(
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
                        componentData.item_table.data.push(item_row);
                    });
                    componentData.item_table.columns = [];
                    componentData.item_table.columns.push(
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
                            title: componentData.$__("ID"),
                            data: "item.user_train_item_id",
                        }
                    );
                    resource.default_processing.attributes.forEach(a =>
                        componentData.item_table.columns.push({
                            name: a.name,
                            title: a.name,
                            data: a.processing_attribute_id,
                            render: (data, type, row) => {
                                return data.join("<br/>");
                            },
                        })
                    );
                    componentData.item_table.columns.push({
                        name: "actions",
                        className: "actions noExport",
                        title: componentData.$__("Actions"),
                        searchable: false,
                        orderable: false,
                        render: (data, type, row) => {
                            return "";
                        },
                    });
                }
                componentData.item_table.display = display_table;
            }
        },
        appendToShow(componentData) {
            return [
                {
                    type: "component",
                    name: __("Items"),
                    hidden: train => train.items.length,
                    componentPath: "./Preservation/TrainItemsTable.vue",
                    componentProps: {
                        train: {
                            type: "resource",
                        },
                        item_table: {
                            type: "object",
                            value: componentData.item_table,
                        },
                    },
                },
            ];
        },
    },
    name: "TrainResource",
};
</script>
