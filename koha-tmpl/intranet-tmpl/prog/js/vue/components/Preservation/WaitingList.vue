<template>
    <transition name="modal_add_to_waiting_list">
        <div v-if="show_modal_add_to_waiting_list" class="modal">
            <h2>{{ $__("Add items to waiting list") }}</h2>
            <form @submit="addItemsToWaitingList($event)">
                <div class="page-section">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <label class="required" for="barcode_list"
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
                    <fieldset class="action">
                        <input type="submit" value="Submit" />
                        <input
                            type="button"
                            @click="show_modal_add_to_waiting_list = false"
                            :value="$__('Close')"
                        />
                    </fieldset>
                </div>
            </form>
        </div>
    </transition>
    <transition name="modal_add_to_train">
        <div v-if="show_modal_add_to_train" class="modal">
            <h2>{{ $__("Add items to a train") }}</h2>
            <form @submit="addItemsToTrain($event)">
                <div class="page-section">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <label class="required" for="train_list"
                                    >{{ $__("Select a train") }}:</label
                                >
                                <v-select
                                    id="train_id"
                                    v-model="train_id_selected_for_add"
                                    label="name"
                                    :options="train_list"
                                    :reduce="t => t.train_id"
                                >
                                    <template #search="{ attributes, events }">
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
                    <fieldset class="action">
                        <input type="submit" value="Submit" />
                        <input
                            type="button"
                            @click="show_modal_add_to_train = false"
                            :value="$__('Close')"
                        />
                    </fieldset>
                </div>
            </form>
        </div>
    </transition>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="!settings.not_for_loan_waiting_list_in" id="waiting-list">
        {{ $__("You need to configure this module first.") }}
    </div>
    <div v-else id="waiting-list">
        <div id="toolbar" class="btn-toolbar">
            <a
                class="btn btn-default"
                @click="show_modal_add_to_waiting_list = true"
                ><font-awesome-icon icon="plus" />
                {{ $__("Add to waiting list") }}</a
            >
            <a
                v-if="last_items.length > 0"
                class="btn btn-default"
                @click="show_modal_add_to_train = true"
                ><font-awesome-icon icon="plus" />
                {{
                    $__("Add last %s items to a train").format(
                        last_items.length
                    )
                }}</a
            >
        </div>
        <div v-if="count_waiting_list_items > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @remove="doRemoveItem"
            ></KohaTable>
        </div>
        <div v-else class="dialog message">
            {{ $__("There are no items in the waiting list") }}
        </div>
    </div>
</template>

<script>
import flatPickr from "vue-flatpickr-component"
import { inject, ref } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const table = ref()

        const PreservationStore = inject("PreservationStore")
        const { settings } = storeToRefs(PreservationStore)

        const { setMessage, setConfirmationDialog, loading, loaded } =
            inject("mainStore")

        return {
            table,
            settings,
            setMessage,
            setConfirmationDialog,
            loading,
            loaded,
        }
    },
    data: function () {
        return {
            fp_config: flatpickr_defaults,
            count_waiting_list_items: 0,
            barcode_list: "",
            initialized: false,
            show_modal_add_to_waiting_list: false,
            show_modal_add_to_train: false,
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
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getCountWaitingListItems()
            vm.getTrainList()
        })
    },
    methods: {
        async getCountWaitingListItems() {
            const client = APIClient.preservation
            client.waiting_list_items.count().then(count => {
                this.count_waiting_list_items = count
                this.initialized = true
            })
        },
        getTrainList: function () {
            const client = APIClient.preservation
            client.trains.getAll().then(
                trains => (this.train_list = trains),
                error => {}
            )
        },
        addItemsToTrain: function (e) {
            e.preventDefault()
            let item_ids = this.last_items.map(i => i.item_id)
            this.$router.push(
                "/cgi-bin/koha/preservation/trains/" +
                    this.train_id_selected_for_add +
                    "/items/add/" +
                    item_ids.join(",")
            )
        },
        addItemsToWaitingList: function (e) {
            e.preventDefault()
            this.show_modal_add_to_waiting_list = false
            let items = []
            this.barcode_list
                .split("\n")
                .forEach(barcode => items.push({ barcode }))
            const client = APIClient.preservation
            client.waiting_list_items.createAll(items).then(
                result => {
                    if (result.length) {
                        this.setMessage(
                            this.$__("%s new items added.").format(
                                result.length
                            ),
                            true
                        )
                        this.last_items = result
                        if (this.$refs.table) {
                            this.$refs.table.redraw(
                                "/api/v1/preservation/waiting-list/items"
                            )
                        } else {
                            this.getCountWaitingListItems()
                        }
                    } else {
                        this.setMessage(this.$__("No items added"))
                    }
                },
                error => {}
            )
            this.barcode_list = ""
        },
        doShow: function (biblio, dt, event) {
            event.preventDefault()
            location.href =
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                biblio.biblio_id
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
                    const client = APIClient.preservation
                    client.waiting_list_items.delete(item.item_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Item removed from the waiting list"),
                                true
                            )
                            dt.draw()
                        },
                        error => {}
                    )
                }
            )
        },
        getTableColumns: function () {
            let escape_str = this.escape_str
            return [
                {
                    data: "biblio.title",
                    title: __("Title"),
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return `<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=${row.biblio.biblio_id}">${row.biblio.title}</a>`
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
                    title: __("Callnumber"),
                    searchable: true,
                    orderable: true,
                },
                {
                    data: "external_id",
                    title: __("Barcode"),
                    searchable: true,
                    orderable: true,
                },
            ]
        },
    },
    components: { flatPickr, KohaTable },
    name: "WaitingList",
}
</script>

<style scoped>
#waiting_list {
    display: table;
}
.modal {
    position: fixed;
    z-index: 9990;
    top: 0;
    left: 0;
    width: 35%;
    height: 30%;
    background-color: rgba(0, 0, 0, 0.5);
    display: table;
    transition: opacity 0.3s ease;
    margin: auto;
    padding: 20px 30px;
    background-color: #fff;
    border-radius: 2px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
}
</style>
