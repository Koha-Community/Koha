<template>
    <div
        id="copy_item_to_train"
        class="modal"
        role="dialog"
        aria-labelledby="copy_item_to_train_label"
        aria-hidden="true"
    >
        <div class="modal-dialog modal-lg">
            <div class="modal-content modal-lg">
                <form @submit="copyItem($event)">
                    <div class="modal-header">
                        <h1 class="modal-title" id="copy_item_to_train_label">
                            {{ $__("Copy item to the following train") }}
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
                                        for="train_list"
                                        >{{ $__("Select a train") }}:</label
                                    >
                                </li>
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
    <div v-else id="trains_show">
        <Toolbar>
            <ToolbarButton
                v-if="train.closed_on == null"
                :to="{
                    name: 'TrainsFormAddItem',
                    params: { train_id: train.train_id },
                }"
                icon="plus"
                :title="$__('Add items')"
            />
            <span
                v-else
                class="btn btn-default"
                disabled="disabled"
                :title="$__('Cannot add items to a closed train')"
            >
                <font-awesome-icon icon="plus" /> {{ $__("Add items") }}
            </span>
            <ToolbarButton
                :to="{
                    name: 'TrainsFormEdit',
                    params: { train_id: train.train_id },
                }"
                icon="pencil"
                :title="$__('Edit')"
            />
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
        </Toolbar>
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
                <span class="action_links">
                    <a
                        role="link"
                        @click="selectAll()"
                        :title="$__('Select all')"
                        ><i class="fa fa-check"></i>{{ $__("Select all") }}</a
                    >
                    <a @click="clearAll()" :title="$__('Clear all')"
                        ><i class="fa fa-remove"></i>{{ $__("Clear all") }}</a
                    >
                    {{ $__("Actions: ") }}
                    <a
                        v-if="selected_items.length > 0"
                        @click="printSelected()"
                        :title="$__('Print slips')"
                        ><i class="fa fa-print"></i>{{ $__("Print slips") }}</a
                    >
                    <a v-else class="disabled" :title="$__('Print slips')"
                        ><i class="fa fa-print"></i>{{ $__("Print slips") }}</a
                    >
                </span>
                <table v-if="item_table.display" :id="table_id"></table>
                <ol v-else>
                    <li
                        :id="`item_${counter}`"
                        class="rows"
                        v-for="(item, counter) in train.items"
                        v-bind:key="counter"
                    >
                        <input
                            :disabled="!item.processing.letter_code"
                            v-model="selected_items"
                            type="checkbox"
                            name="user_train_item_id"
                            :value="item.train_item_id"
                            :title="
                                !item.processing.letter_code
                                    ? $__(
                                          'Cannot print slip, this item does not have a processing with a letter template defined.'
                                      )
                                    : ''
                            "
                        />
                        <label
                            >{{ item.user_train_item_id }}
                            <span class="action_links">
                                <a
                                    role="button"
                                    @click="editItem(item.train_item_id)"
                                    :title="$__('Edit')"
                                    ><i class="fa fa-pencil"></i
                                ></a>
                                <a
                                    role="button"
                                    @click="removeItem(item.train_item_id)"
                                    :title="$__('Remove')"
                                    ><i class="fa fa-trash"></i
                                ></a>
                                <a
                                    v-if="train.received_on !== null"
                                    role="button"
                                    @click="
                                        selectTrainForCopy(item.train_item_id)
                                    "
                                    :title="$__('Copy')"
                                    ><i class="fa fa-copy"></i
                                ></a>
                                <a
                                    v-if="item.processing.letter_code !== null"
                                    role="button"
                                    @click="printSlip(item.train_item_id)"
                                    :title="$__('Print')"
                                    ><i class="fa fa-print"></i></a
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
                                {{ attribute.processing_attribute.name }}={{
                                    attribute._strings.value.str
                                }}
                            </span>
                        </div>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'TrainsList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject, createVNode, render } from "vue";
import { APIClient } from "../../fetch/api-client";
import { useDataTable } from "../../composables/datatables";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";

export default {
    setup() {
        const format_date = $date;

        const PreservationStore = inject("PreservationStore");
        const { get_lib_from_av } = PreservationStore;

        const { setConfirmationDialog, setMessage, setWarning } =
            inject("mainStore");

        const table_id = "item_list";
        useDataTable(table_id);

        return {
            format_date,
            get_lib_from_av,
            table_id,
            setConfirmationDialog,
            setMessage,
            setWarning,
        };
    },
    data() {
        return {
            train: {
                train_id: null,
                name: "",
                description: "",
            },
            initialized: false,
            item_table: {
                display: false,
                data: [],
                columns: [],
            },
            train_list: [],
            train_id_selected_for_copy: null,
            train_item_id_to_copy: null,
            selected_items: [],
            av_options: {},
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTrain(to.params.train_id).then(() => vm.build_datatable());
            vm.getTrainList();
        });
    },
    methods: {
        async getTrain(train_id) {
            const client = APIClient.preservation;
            await client.trains.get(train_id).then(
                train => {
                    this.train = train;
                    let display_table = this.train.items.every(
                        item =>
                            item.processing_id ==
                            this.train.default_processing_id
                    );
                    if (display_table) {
                        this.item_table.data = [];
                        this.train.items.forEach(item => {
                            let item_row = {};
                            this.train.default_processing.attributes.forEach(
                                attribute => {
                                    item_row[
                                        attribute.processing_attribute_id
                                    ] = item.attributes
                                        .filter(
                                            a =>
                                                a.processing_attribute_id ==
                                                attribute.processing_attribute_id
                                        )
                                        .map(a => a._strings.value.str);
                                }
                            );
                            item_row.item = item;
                            this.item_table.data.push(item_row);
                        });
                        this.item_table.columns = [];
                        this.item_table.columns.push(
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
                                title: this.$__("ID"),
                                data: "item.user_train_item_id",
                            }
                        );
                        train.default_processing.attributes.forEach(a =>
                            this.item_table.columns.push({
                                name: a.name,
                                title: a.name,
                                data: a.processing_attribute_id,
                                render: (data, type, row) => {
                                    return data.join("<br/>");
                                },
                            })
                        );
                        this.item_table.columns.push({
                            name: "actions",
                            className: "actions noExport",
                            title: this.$__("Actions"),
                            searchable: false,
                            orderable: false,
                            render: (data, type, row) => {
                                return "";
                            },
                        });
                    }
                    this.initialized = true;
                    this.item_table.display = display_table;
                },
                error => {}
            );
        },
        getTrainList: function () {
            const client = APIClient.preservation;
            let q = { "me.closed_on": null };
            client.trains.getAll(q).then(
                trains => (this.train_list = trains),
                error => {}
            );
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
                    const client = APIClient.preservation;
                    client.trains.delete(train.train_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Train %s deleted").format(train.name),
                                true
                            );
                            this.$router.push({ name: "TrainsList" });
                        },
                        error => {}
                    );
                }
            );
        },
        async updateTrainDate(attribute) {
            let train = JSON.parse(JSON.stringify(this.train));
            let train_id = train.train_id;
            delete train.train_id;
            delete train.items;
            delete train.default_processing;
            train[attribute] = new Date();
            const client = APIClient.preservation;
            if (train_id) {
                return client.trains
                    .update(train, train_id)
                    .then(() => this.getTrain(this.train.train_id));
            } else {
                return client.trains
                    .create(train)
                    .then(() => this.getTrain(this.train.train_id));
            }
        },
        closeTrain() {
            this.updateTrainDate("closed_on");
        },
        sendTrain() {
            this.updateTrainDate("sent_on");
        },
        receiveTrain() {
            this.updateTrainDate("received_on").then(
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
        editItem(train_item_id) {
            this.$router.push({
                name: "TrainsFormEditItem",
                params: { train_id: this.train.train_id, train_item_id },
            });
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
                    const client = APIClient.preservation;
                    client.train_items
                        .delete(this.train.train_id, train_item_id)
                        .then(
                            success => {
                                this.setMessage(this.$__("Item removed"), true);
                                this.getTrain(this.train.train_id).then(() => {
                                    $("#" + this.table_id)
                                        .DataTable()
                                        .destroy();
                                    this.build_datatable();
                                });
                            },
                            error => {}
                        );
                }
            );
        },
        printSlip(train_item_id) {
            window.open(
                "/cgi-bin/koha/preservation/print_slip.pl?train_item_id=" +
                    train_item_id,
                "_blank"
            );
        },
        selectTrainForCopy(train_item_id) {
            $("#copy_item_to_train").modal("show");
            this.train_item_id_to_copy = train_item_id;
        },
        copyItem(event) {
            event.preventDefault();
            const client = APIClient.preservation;
            client.train_items
                .copy(
                    this.train_id_selected_for_copy,
                    this.train.train_id,
                    this.train_item_id_to_copy
                )
                .then(
                    success => {
                        this.setMessage(this.$__("Item copied successfully."));
                        $("#copy_item_to_train").modal("hide");
                    },
                    error => {
                        this.setWarning(
                            this.$__(
                                "Item cannot be copied to a train, it is already in a non-received train."
                            )
                        );
                    }
                );
        },
        clearAll() {
            this.selected_items = [];
            if (this.item_table.display) {
                $("#" + this.table_id)
                    .find("input[name='user_train_item_id'][type='checkbox']")
                    .prop("checked", false);
            }
        },
        selectAll() {
            if (this.item_table.display) {
                $("#" + this.table_id)
                    .find(
                        "input[name='user_train_item_id'][type='checkbox']:not(:disabled)"
                    )
                    .each((i, input) => {
                        this.selected_items.push($(input).val());
                        $(input).prop("checked", true);
                    });
            } else {
                this.selected_items = this.train.items
                    .filter(i => i.processing.letter_code)
                    .map(item => item.train_item_id);
            }
        },
        printSelected() {
            window.open(
                "/cgi-bin/koha/preservation/print_slip.pl?%s_blank".format(
                    this.selected_items
                        .map(id => "train_item_id=" + id)
                        .join("&")
                )
            );
        },
        updateSelectedItems(checked, train_item_id) {
            if (checked) {
                this.selected_items.push(train_item_id);
            } else {
                this.selected_items = this.selected_items.filter(
                    id => id != train_item_id
                );
            }
        },
        build_datatable: function () {
            let table_id = this.table_id;
            let item_table = this.item_table;
            let removeItem = this.removeItem;
            let editItem = this.editItem;
            let printSlip = this.printSlip;
            let selectTrainForCopy = this.selectTrainForCopy;
            let train = this.train;
            let updateSelectedItems = this.updateSelectedItems;

            let table = $("#" + table_id).kohaTable({
                data: item_table.data,
                ordering: false,
                autoWidth: false,
                columns: item_table.columns,
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings);
                    $.each($(this).find("td.checkboxes"), function (index, e) {
                        let tr = $(this).parent();
                        let train_item = api.row(tr).data().item;
                        let train_item_id = train_item.train_item_id;

                        let checkbox = createVNode("input", {
                            ...(!train_item.processing.letter_code && {
                                disabled: "disabled",
                                title: __(
                                    "Cannot print slip, this item does not have a processing with a letter template defined."
                                ),
                            }),
                            type: "checkbox",
                            name: "user_train_item_id",
                            value: train_item_id,
                            onChange: e => {
                                updateSelectedItems(
                                    e.target.checked,
                                    train_item_id
                                );
                            },
                        });

                        render(checkbox, e);
                    });
                    $.each($(this).find("td.actions"), function (index, e) {
                        let tr = $(this).parent();
                        let train_item = api.row(tr).data().item;
                        let train_item_id = train_item.train_item_id;

                        let editButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    editItem(train_item_id);
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-pencil",
                                    "aria-hidden": "true",
                                }),
                                " ",
                                __("Edit"),
                            ]
                        );

                        let removeButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    removeItem(train_item_id);
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-trash",
                                    "aria-hidden": "true",
                                }),
                                " ",
                                __("Remove"),
                            ]
                        );
                        let buttons = [editButton, " ", removeButton];

                        if (train.received_on !== null) {
                            buttons.push(" ");
                            buttons.push(
                                createVNode(
                                    "a",
                                    {
                                        class: "btn btn-default btn-xs",
                                        role: "button",
                                        onClick: () => {
                                            selectTrainForCopy(train_item_id);
                                        },
                                    },
                                    [
                                        createVNode("i", {
                                            class: "fa fa-copy",
                                            "aria-hidden": "true",
                                        }),
                                        " ",
                                        __("Copy"),
                                    ]
                                )
                            );
                        }

                        if (train_item.processing.letter_code) {
                            let printButton = createVNode(
                                "a",
                                {
                                    class: "btn btn-default btn-xs",
                                    role: "button",
                                    onClick: () => {
                                        printSlip(train_item_id);
                                    },
                                },
                                [
                                    createVNode("i", {
                                        class: "fa fa-print",
                                        "aria-hidden": "true",
                                    }),
                                    __("Print slip"),
                                ]
                            );
                            buttons.push(" ");
                            buttons.push(printButton);
                        }

                        let n = createVNode("span", {}, buttons);
                        render(n, e);
                    });
                },
            });
        },
    },
    components: { Toolbar, ToolbarButton },
    name: "TrainsShow",
};
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
    cursor: pointer;
}
.attributes_values {
    float: left;
}
.attribute_value {
    display: block;
}
input[type="checkbox"] {
    float: left;
}
</style>
