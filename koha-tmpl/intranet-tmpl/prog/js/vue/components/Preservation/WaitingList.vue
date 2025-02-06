<template>
    <div
        id="add_to_waiting_list"
        class="modal"
        role="dialog"
        aria-labelledby="add_to_waiting_list_label"
        aria-hidden="true"
    >
        <div class="modal-dialog modal-lg">
            <div class="modal-content modal-lg">
                <form @submit="addItemsToWaitingList($event)">
                    <div class="modal-header">
                        <h1 class="modal-title" id="add_to_waiting_list_label">
                            {{ $__("Add items to waiting list") }}
                        </h1>
                        <button
                            type="button"
                            class="btn-close"
                            data-bs-dismiss="modal"
                            aria-label="Close"
                        ></button>
                    </div>
                    <div class="modal-body">
                        <fieldset>
                            <ol>
                                <li class="form-group form-row">
                                    <label
                                        class="required col-form-label"
                                        for="barcode_list"
                                        >{{ $__("Barcode list") }}:</label
                                    >
                                    <textarea
                                        id="barcode_list"
                                        v-model="barcode_list"
                                        :placeholder="$__('Barcodes')"
                                        rows="10"
                                        cols="50"
                                        required
                                    />
                                </li>
                            </ol>
                        </fieldset>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-default approve" type="submit">
                            <i class="fa fa-check"></i> Save
                        </button>
                        <button
                            class="btn btn-default deny cancel"
                            type="button"
                            data-bs-dismiss="modal"
                        >
                            <i class="fa fa-times"></i> Cancel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <div
        id="add_to_train"
        class="modal"
        role="dialog"
        aria-labelledby="add_to_train_label"
        aria-hidden="true"
    >
        <div class="modal-dialog modal-lg">
            <div class="modal-content modal-lg">
                <form @submit="addItemsToTrain($event)">
                    <div class="modal-header">
                        <h1 class="modal-title" id="add_to_train_label">
                            {{ $__("Add items to a train") }}
                        </h1>
                        <button
                            type="button"
                            class="btn-close"
                            data-bs-dismiss="modal"
                            aria-label="Close"
                        ></button>
                    </div>
                    <div class="modal-body position-relative overflow-visible">
                        <fieldset>
                            <ol>
                                <li class="form-group form-row">
                                    <label
                                        class="required col-form-label"
                                        for="train_id"
                                        >{{ $__("Select a train") }}:</label
                                    >
                                    <v-select
                                        id="train_id"
                                        v-model="train_id_selected_for_add"
                                        label="name"
                                        :options="train_list"
                                        :reduce="t => t.train_id"
                                    >
                                        <template
                                            #search="{ attributes, events }"
                                        >
                                            <input
                                                :required="
                                                    !train_id_selected_for_add
                                                "
                                                class="vs__search"
                                                v-bind="attributes"
                                                v-on="events"
                                            />
                                        </template>
                                    </v-select>
                                    <span class="required">{{
                                        $__("Required")
                                    }}</span>
                                </li>
                            </ol>
                        </fieldset>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-default approve" type="submit">
                            <i class="fa fa-check"></i> Save
                        </button>
                        <button
                            class="btn btn-default deny cancel"
                            type="button"
                            data-bs-dismiss="modal"
                        >
                            <i class="fa fa-times"></i> Cancel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div
        v-else-if="!config.settings.not_for_loan_waiting_list_in"
        id="waiting-list"
    >
        {{ $__("You need to configure this module first.") }}
    </div>
    <div v-else id="waiting-list">
        <Toolbar>
            <a
                href="#add_to_waiting_list"
                class="btn btn-default"
                role="button"
                data-bs-toggle="modal"
                ><font-awesome-icon icon="plus" />
                {{ $__("Add to waiting list") }}</a
            >
            <a
                v-if="last_items.length > 0"
                href="#add_to_train"
                class="btn btn-default"
                role="button"
                data-bs-toggle="modal"
                ><font-awesome-icon icon="plus" />
                {{
                    $__("Add last %s items to a train").format(
                        last_items.length
                    )
                }}</a
            >
        </Toolbar>
        <div v-if="count_waiting_list_items > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @remove="doRemoveItem"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no items in the waiting list") }}
        </div>
    </div>
</template>

<script>
import flatPickr from "vue-flatpickr-component";
import Toolbar from "../Toolbar.vue";
import { inject, ref } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const table = ref();

        const PreservationStore = inject("PreservationStore");
        const { config } = PreservationStore;

        const {
            setMessage,
            setWarning,
            setConfirmationDialog,
            loading,
            loaded,
        } = inject("mainStore");

        return {
            table,
            config,
            setMessage,
            setWarning,
            setConfirmationDialog,
            loading,
            loaded,
        };
    },
    data: function () {
        return {
            fp_config: flatpickr_defaults,
            count_waiting_list_items: 0,
            barcode_list: "",
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/preservation/waiting-list/items",
                options: { embed: "biblio" },
                add_filters: true,
                actions: {
                    0: ["show"],
                    "-1": ["remove"],
                },
            },
            last_items: [],
            train_list: [],
            train_id_selected_for_add: null,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getCountWaitingListItems();
            vm.getTrainList();
        });
    },
    methods: {
        async getCountWaitingListItems() {
            const client = APIClient.preservation;
            client.waiting_list_items.count().then(count => {
                this.count_waiting_list_items = count;
                this.initialized = true;
            });
        },
        getTrainList: function () {
            const client = APIClient.preservation;
            client.trains.getAll().then(
                trains => (this.train_list = trains),
                error => {}
            );
        },
        addItemsToTrain: function (e) {
            e.preventDefault();
            $("#add_to_train").modal("hide");
            let item_ids = this.last_items.map(i => i.item_id);
            this.$router.push({
                name: "TrainsFormAddItems",
                params: {
                    train_id: this.train_id_selected_for_add,
                    item_ids: item_ids.join(","),
                },
            });
        },
        addItemsToWaitingList: function (e) {
            e.preventDefault();
            $("#add_to_waiting_list").modal("hide");
            let items = [];
            this.barcode_list
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
                        this.last_items = result;
                        if (this.$refs.table) {
                            this.$refs.table.redraw(
                                "/api/v1/preservation/waiting-list/items"
                            );
                        } else {
                            this.getCountWaitingListItems();
                        }
                    } else {
                        this.setWarning(this.$__("No items added"));
                    }
                },
                error => {}
            );
            this.barcode_list = "";
        },
        doShow: function (biblio, dt, event) {
            event.preventDefault();
            location.href =
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                biblio.biblio_id;
        },
        doRemoveItem: function (item, dt, event) {
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
        getTableColumns: function () {
            let escape_str = this.escape_str;
            return [
                {
                    data: "biblio.title",
                    title: __("Title"),
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return `<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=${row.biblio.biblio_id}">${row.biblio.title}</a>`;
                    },
                },
                {
                    data: "biblio.author",
                    title: __("Author"),
                    searchable: true,
                    orderable: true,
                },
                {
                    data: "callnumber",
                    title: __("Call number"),
                    searchable: true,
                    orderable: true,
                },
                {
                    data: "external_id",
                    title: __("Barcode"),
                    searchable: true,
                    orderable: true,
                },
            ];
        },
    },
    components: { flatPickr, KohaTable, Toolbar },
    name: "WaitingList",
};
</script>

<style scoped>
#waiting_list {
    display: table;
}
</style>
