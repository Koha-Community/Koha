<template>
    <div>
        <fieldset v-if="train.items.length" class="rows">
            <span class="action_links">
                <a role="link" @click="selectAll()" :title="$__('Select all')"
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
                                @click="selectTrainForCopy(item.train_item_id)"
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

        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

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
    props: {
        train: {
            type: Object,
            required: true,
        },
        item_table: Object,
    },
    data() {
        return {
            initialized: false,
            train_list: [],
            train_id_selected_for_copy: null,
            train_item_id_to_copy: null,
            selected_items: [],
        };
    },
    mounted() {
        this.build_datatable();
    },
    methods: {
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
            this.train_item_id_to_copy = train_item_id;
            let copyItem = this.copyItem;

            this.setConfirmationDialog(
                {
                    title: this.$__("Copy item to the following train"),
                    message: null,
                    accept_label: this.$__("Save"),
                    cancel_label: this.$__("Cancel"),
                    inputs: [
                        {
                            name: "train_id",
                            type: "relationshipSelect",
                            label: __("Select a train"),
                            required: true,
                            relationshipAPIClient:
                                APIClient.preservation.trains,
                            relationshipOptionLabelAttr: "name",
                            relationshipRequiredKey: "train_id",
                            query: {
                                "me.closed_on": null,
                            },
                        },
                    ],
                },
                copyItem
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
        copyItem(result, trainToCopy) {
            const client = APIClient.preservation;
            client.train_items
                .copy(
                    trainToCopy.train_id,
                    this.train.train_id,
                    this.train_item_id_to_copy
                )
                .then(
                    success => {
                        this.setMessage(this.$__("Item copied successfully."));
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
        build_datatable() {
            let table_id = this.table_id;
            let item_table = this.item_table;
            let removeItem = this.removeItem;
            let editItem = this.editItem;
            let printSlip = this.printSlip;
            let selectTrainForCopy = this.selectTrainForCopy;
            let train = this.train;
            let updateSelectedItems = this.updateSelectedItems;
            let copyItem = this.copyItem;

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
    name: "TrainItemsTable",
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
