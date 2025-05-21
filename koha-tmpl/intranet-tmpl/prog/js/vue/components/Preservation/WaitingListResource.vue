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
        const PreservationStore = inject("PreservationStore");
        const { config, itemsRecentlyAddedToWaitingList } =
            storeToRefs(PreservationStore);

        return {
            ...BaseResource.setup({
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
                    deleteSuccessMessage: __(
                        "Item removed from the waiting list"
                    ),
                    displayName: __("Item"),
                    displayNameLowerCase: __("item"),
                    displayNamePlural: __("Items"),
                    editLabel: null,
                    emptyListMessage: __(
                        "There are no items in the waiting list"
                    ),
                    newLabel: __("Add to waiting list"),
                },
                config,
                itemsRecentlyAddedToWaitingList,
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
                    label: this.$__("ID"),
                    type: "text",
                    showInTable: false,
                },
                {
                    name: "biblio.title",
                    label: this.$__("Title"),
                    type: "text",
                    showInTable: {
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
                    label: this.$__("Author"),
                    type: "text",
                    showInTable: true,
                },
                {
                    name: "callnumber",
                    label: this.$__("Call number"),
                    type: "text",
                    showInTable: true,
                },
                {
                    name: "external_id",
                    label: this.$__("Barcode"),
                    type: "text",
                    showInTable: true,
                },
            ],
            tableOptions: {
                url: "/api/v1/preservation/waiting-list/items",
                options: { embed: "biblio" },
                add_filters: true,
                actions: {
                    0: ["show"],
                    1: ["show"],
                    "-1": [
                        {
                            removeItem: {
                                text: this.$__("Remove"),
                                icon: "fa fa-close",
                                callback: this.doRemoveItem,
                            },
                        },
                    ],
                },
            },
            tableFilters,
        };
    },
    methods: {
        additionalToolbarButtons(resource, componentData) {
            let addItemsToWaitingList = this.addItemsToWaitingList;
            let addItemsToTrain = this.addItemsToTrain;
            let itemsRecentlyAddedToWaitingList =
                this.itemsRecentlyAddedToWaitingList;
            return {
                list: [
                    {
                        onClick: () =>
                            this.setConfirmationDialog(
                                {
                                    title: this.$__(
                                        "Add items to waiting list"
                                    ),
                                    accept_label: this.$__("Save"),
                                    cancel_label: this.$__("Cancel"),
                                    inputs: [
                                        {
                                            name: "barcode_list",
                                            type: "textarea",
                                            textAreaRows: 10,
                                            textAreaCols: 50,
                                            label: this.$__("Barcode list"),
                                            required: true,
                                        },
                                    ],
                                },
                                addItemsToWaitingList
                            ),
                        icon: "plus",
                        title: this.$__("Add to waiting list"),
                    },
                    itemsRecentlyAddedToWaitingList.length > 0
                        ? {
                              onClick: () =>
                                  this.setConfirmationDialog(
                                      {
                                          title: this.$__(
                                              "Add items to a train"
                                          ),
                                          accept_label: this.$__("Save"),
                                          cancel_label: this.$__("Cancel"),
                                          inputs: [
                                              {
                                                  name: "train_id_selected_for_add",
                                                  type: "relationshipSelect",
                                                  label: this.$__(
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
                              title: this.$__(
                                  "Add last %s items to a train".format(
                                      itemsRecentlyAddedToWaitingList.length
                                  )
                              ),
                          }
                        : {},
                ],
            };
        },
        defaultToolbarButtons() {
            return {
                list: [],
            };
        },
        addItemsToWaitingList(result, itemList) {
            let items = [];
            itemList.barcode_list
                .split("\n")
                .forEach(barcode => items.push({ barcode }));
            const client = APIClient.preservation;
            client.waiting_list_items.createAll(items).then(
                result => {
                    if (result.length) {
                        if (result.length != items.length) {
                            this.setWarning(
                                this.$__(
                                    "%s new items added. %s items not found."
                                ).format(
                                    result.length,
                                    items.length - result.length
                                ),
                                true
                            );
                        } else {
                            this.setMessage(
                                this.$__("%s new items added.").format(
                                    result.length
                                ),
                                true
                            );
                        }
                        this.itemsRecentlyAddedToWaitingList = result;
                        if (this.$refs.table) {
                            this.$refs.table.redraw(
                                "/api/v1/preservation/waiting-list/items"
                            );
                        } else {
                            this.refreshTemplateState();
                        }
                    } else {
                        this.setWarning(this.$__("No items added"));
                    }
                },
                error => {}
            );
            itemList = "";
        },
        addItemsToTrain(result, train_id) {
            let item_ids = this.itemsRecentlyAddedToWaitingList.map(
                i => i.item_id
            );
            this.$router.push({
                name: "TrainsFormAddItems",
                params: {
                    train_id: train_id,
                    item_ids: item_ids.join(","),
                },
            });
        },
        doRemoveItem(item, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this item from the waiting list?"
                    ),
                    message: item.barcode,
                    accept_label: this.$__("Yes, remove"),
                    cancel_label: this.$__("No, do not remove"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.waiting_list_items.delete(item.item_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Item removed from the waiting list"),
                                true
                            );
                            dt.draw();
                        },
                        error => {}
                    );
                }
            );
        },
    },
    name: "WaitingListResource",
};
</script>
