<template>
    <transition name="modal">
        <div v-if="show_modal" class="modal">
            <h2>{{ $__("Copy item to the following train") }}</h2>
            <form @submit="copyItem($event)">
                <div class="page-section">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <label class="required" for="train_list"
                                    >{{ $__("Select a train") }}:</label
                                >
                                <v-select
                                    v-model="train_id_selected_for_copy"
                                    label="name"
                                    :options="train_list"
                                    :reduce="t => t.train_id"
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="
                                                !train_id_selected_for_copy
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
                        <input type="submit" value="Copy" />
                        <input
                            type="button"
                            @click="show_modal = false"
                            :value="$__('Close')"
                        />
                    </fieldset>
                </div>
            </form>
        </div>
    </transition>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="trains_show">
        <div id="toolbar" class="btn-toolbar">
            <router-link
                :to="`/cgi-bin/koha/preservation/trains/${train.train_id}/items/add`"
                class="btn btn-default"
                ><font-awesome-icon icon="plus" />
                {{ $__("Add items") }}</router-link
            >
            <router-link
                :to="`/cgi-bin/koha/preservation/trains/edit/${train.train_id}`"
                class="btn btn-default"
                ><font-awesome-icon icon="pencil" />
                {{ $__("Edit") }}</router-link
            >
            <a @click="deleteTrain(train)" class="btn btn-default"
                ><font-awesome-icon icon="trash" /> {{ $__("Delete") }}</a
            >
            <a
                v-if="!train.closed_on"
                class="btn btn-default"
                @click="closeTrain"
                ><font-awesome-icon icon="remove" /> {{ $__("Close") }}</a
            >
            <a
                v-else-if="!train.sent_on"
                class="btn btn-default"
                @click="sendTrain"
                ><font-awesome-icon icon="paper-plane" /> {{ $__("Send") }}</a
            >
            <a
                v-else-if="!train.received_on"
                class="btn btn-default"
                @click="receiveTrain"
                ><font-awesome-icon icon="inbox" /> {{ $__("Receive") }}</a
            >
        </div>
        <h2>
            {{ $__("Train #%s").format(train.train_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Name") }}:</label>
                        <span>
                            {{ train.name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Description") }}:</label>
                        <span>
                            {{ train.description }}
                        </span>
                    </li>
                    <li v-if="train.closed_on">
                        <label>{{ $__("Closed on") }}:</label>
                        <span>
                            {{ format_date(train.closed_on) }}
                        </span>
                    </li>
                    <li v-if="train.sent_on">
                        <label>{{ $__("Sent on") }}:</label>
                        <span>
                            {{ format_date(train.sent_on) }}
                        </span>
                    </li>
                    <li v-if="train.received_on">
                        <label>{{ $__("Received on") }}:</label>
                        <span>
                            {{ format_date(train.received_on) }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $__("Status for item added to this train")
                            }}:</label
                        >
                        <span>{{
                            get_lib_from_av("av_notforloan", train.not_for_loan)
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Default processing") }}:</label>
                        <span>
                            {{ train.default_processing.name }}
                        </span>
                    </li>
                </ol>
            </fieldset>
            <fieldset v-if="train.items.length" class="rows">
                <legend>{{ $__("Items") }}</legend>
                <table v-if="item_table.display" :id="table_id"></table>
                <ol v-else>
                    <li
                        :id="`item_${counter}`"
                        class="rows"
                        v-for="(item, counter) in train.items"
                        v-bind:key="counter"
                    >
                        <!-- FIXME Counter here may change, we should pass an order by clause when retrieving the items -->
                        <label
                            >{{ counter + 1 }}
                            <span class="action_links">
                                <router-link
                                    :to="`/cgi-bin/koha/preservation/trains/${train.train_id}/items/edit/${item.train_item_id}`"
                                    :title="$__('Edit')"
                                    ><i class="fa fa-pencil"></i></router-link
                            ></span>
                        </label>
                        <div class="attributes_values">
                            <span
                                :id="`attribute_${counter_attribute}`"
                                class="attribute_value"
                                v-for="(
                                    attribute, counter_attribute
                                ) in item.attributes"
                                v-bind:key="counter_attribute"
                            >
                                <!-- FIXME We need to display the description of the AV here -->
                                {{ attribute.processing_attribute.name }}={{
                                    attribute.value
                                }}
                            </span>
                        </div>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/preservation/trains"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject, createVNode, render } from "vue"
import { APIClient } from "../../fetch/api-client"
import { useDataTable } from "../../composables/datatables"

export default {
    setup() {
        const format_date = $date

        const AVStore = inject("AVStore")
        const { get_lib_from_av } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const table_id = "item_list"
        useDataTable(table_id)

        return {
            format_date,
            get_lib_from_av,
            table_id,
            setConfirmationDialog,
            setMessage,
        }
    },
    data() {
        return {
            train: {
                train_id: null,
                name: "",
                description: "",
            },
            initialized: false,
            show_modal: false,
            item_table: {
                display: false,
                data: [],
                columns: [],
            },
            train_list: [],
            train_id_selected_for_copy: null,
            train_item_id_to_copy: null,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTrain(to.params.train_id).then(() => vm.build_datatable())
            vm.getTrainList()
        })
    },
    methods: {
        async getTrain(train_id) {
            const client = APIClient.preservation
            await client.trains.get(train_id).then(
                train => {
                    this.train = train
                    let display = this.train.items.every(
                        item =>
                            item.processing_id ==
                            this.train.default_processing_id
                    )
                    if (display) {
                        this.item_table.data = []
                        this.train.items.forEach(item => {
                            let item_row = {}
                            this.train.default_processing.attributes.forEach(
                                attribute => {
                                    if (item.attributes.length <= 0) return ""
                                    item_row[
                                        attribute.processing_attribute_id
                                    ] = item.attributes.find(
                                        a =>
                                            a.processing_attribute_id ==
                                            attribute.processing_attribute_id
                                    ).value
                                }
                            )
                            item_row.item = item
                            this.item_table.data.push(item_row)
                        })
                        this.item_table.columns = []
                        this.item_table.columns.push({
                            name: "id",
                            title: this.$__("ID"),
                            render: (data, type, row) => {
                                return 42
                            },
                        })
                        train.default_processing.attributes.forEach(a =>
                            this.item_table.columns.push({
                                name: a.name,
                                title: a.name,
                                data: a.processing_attribute_id,
                            })
                        )
                        this.item_table.columns.push({
                            name: "actions",
                            className: "actions noExport",
                            title: this.$__("Actions"),
                            searchable: false,
                            orderable: false,
                            render: (data, type, row) => {
                                return ""
                            },
                        })
                    }
                    this.initialized = true
                    this.item_table.display = display
                },
                error => {}
            )
        },
        getTrainList: function () {
            const client = APIClient.preservation
            let q = { "me.closed_on": null }
            client.trains.getAll(q).then(
                trains => (this.train_list = trains),
                error => {}
            )
        },
        deleteTrain: function (train) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this train?"
                    ),
                    message: train.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.preservation
                    client.trains.delete(train.train_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Train %s deleted").format(train.name),
                                true
                            )
                        },
                        error => {}
                    )
                }
            )
        },
        async updateTrainDate(attribute) {
            let train = JSON.parse(JSON.stringify(this.train))
            let train_id = train.train_id
            delete train.train_id
            delete train.items
            delete train.default_processing
            train[attribute] = new Date()
            const client = APIClient.preservation
            if (train_id) {
                client.trains
                    .update(train, train_id)
                    .then(() => this.getTrain(this.train.train_id))
            } else {
                client.trains
                    .create(train)
                    .then(() => this.getTrain(this.train.train_id))
            }
        },
        closeTrain() {
            this.updateTrainDate("closed_on")
        },
        sendTrain() {
            this.updateTrainDate("sent_on")
        },
        receiveTrain() {
            this.updateTrainDate("received_on")
        },
        editItem(train_item_id) {
            this.$router.push(
                `/cgi-bin/koha/preservation/trains/${this.train.train_id}/items/edit/${train_item_id}`
            )
        },
        removeItem(train_item_id) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this item?"
                    ),
                    accept_label: this.$__("Yes, remove"),
                    cancel_label: this.$__("No, do not remove"),
                },
                () => {
                    const client = APIClient.preservation
                    client.train_items
                        .delete(this.train.train_id, train_item_id)
                        .then(
                            success => {
                                this.setMessage(this.$__("Item removed"), true)
                                this.getTrain(this.train.train_id).then(() => {
                                    $("#" + this.table_id)
                                        .DataTable()
                                        .destroy()
                                    this.build_datatable()
                                })
                            },
                            error => {}
                        )
                }
            )
        },
        selectTrainForCopy(train_item_id) {
            this.show_modal = true
            this.train_item_id_to_copy = train_item_id
        },
        copyItem(event) {
            event.preventDefault()
            const client = APIClient.preservation
            let new_train_item = {}
            client.train_items
                .get(this.train.train_id, this.train_item_id_to_copy)
                .then(train_item => {
                    new_train_item = {
                        attributes: train_item.attributes.map(attr => {
                            return {
                                processing_attribute_id:
                                    attr.processing_attribute_id,
                                value: attr.value,
                            }
                        }),
                        item_id: train_item.item_id,
                        processing_id: train_item.processing_id,
                    }
                })
                .then(() =>
                    client.train_items
                        .create(new_train_item, this.train_id_selected_for_copy)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__("Item copied successfully.")
                                )
                                this.show_modal = false
                            },
                            error => {}
                        )
                )
        },
        build_datatable: function () {
            let table_id = this.table_id
            let item_table = this.item_table
            let removeItem = this.removeItem
            let editItem = this.editItem
            let selectTrainForCopy = this.selectTrainForCopy
            let train = this.train

            let table = KohaTable(table_id, {
                data: item_table.data,
                ordering: false,
                autoWidth: false,
                columns: item_table.columns,
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings)
                    $.each($(this).find("td.actions"), function (index, e) {
                        let tr = $(this).parent()
                        let train_item_id = api.row(tr).data()
                            .item.train_item_id

                        let editButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    editItem(train_item_id)
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-pencil",
                                    "aria-hidden": "true",
                                }),
                                __("Edit"),
                            ]
                        )

                        let removeButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    removeItem(train_item_id)
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-trash",
                                    "aria-hidden": "true",
                                }),
                                __("Remove"),
                            ]
                        )
                        let buttons = [editButton, "", removeButton]

                        if (train.received_on !== null) {
                            buttons.push("")
                            buttons.push(
                                createVNode(
                                    "a",
                                    {
                                        class: "btn btn-default btn-xs",
                                        role: "button",
                                        onClick: () => {
                                            selectTrainForCopy(train_item_id)
                                        },
                                    },
                                    [
                                        createVNode("i", {
                                            class: "fa fa-copy",
                                            "aria-hidden": "true",
                                        }),
                                        __("Copy"),
                                    ]
                                )
                            )
                        }

                        let n = createVNode("span", {}, buttons)
                        render(n, e)
                    })
                },
            })
        },
    },
    name: "TrainsShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
}
.attributes_values {
    float: left;
}
.attribute_value {
    display: block;
}
.modal {
    position: fixed;
    z-index: 9998;
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
