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
    </div>
</template>

<script>
import { inject, createVNode, render, ref, onMounted } from "vue";
import { APIClient } from "../../fetch/api-client";
import { useDataTable } from "../../composables/datatables";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { useRouter } from "vue-router";
import { $__ } from "@koha-vue/i18n";

export default {
    setup(props) {
        const router = useRouter();
        const format_date = $date;

        const PreservationStore = inject("PreservationStore");
        const { get_lib_from_av } = PreservationStore;

        const { setConfirmationDialog, setMessage, setWarning } =
            inject("mainStore");

        const table_id = "item_list";
        useDataTable(table_id);

        const initialized = ref(false);
        const train_id_selected_for_copy = ref(null);
        const train_item_id_to_copy = ref(null);
        const selected_items = ref([]);

        const editItem = train_item_id => {
            router.push({
                name: "TrainsFormEditItem",
                params: { train_id: props.train.train_id, train_item_id },
            });
        };
        const removeItem = train_item_id => {
            setConfirmationDialog(
                {
                    title: $__("Are you sure you want to remove this item?"),
                    accept_label: $__("Yes, remove"),
                    cancel_label: $__("No, do not remove"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.train_items
                        .delete(props.train.train_id, train_item_id)
                        .then(
                            success => {
                                setMessage($__("Item removed"), true);
                                props.train.items = props.train.items.filter(
                                    i => i.train_item_id !== train_item_id
                                );
                                props.item_table.data =
                                    props.item_table.data.filter(
                                        i =>
                                            i.item.train_item_id !==
                                            train_item_id
                                    );
                                $("#" + table_id)
                                    .DataTable()
                                    .destroy();
                                build_datatable();
                            },
                            error => {}
                        );
                }
            );
        };
        const printSlip = train_item_id => {
            window.open(
                "/cgi-bin/koha/preservation/print_slip.pl?train_item_id=" +
                    train_item_id,
                "_blank"
            );
        };
        const selectTrainForCopy = train_item_id => {
            train_item_id_to_copy.value = train_item_id;

            setConfirmationDialog(
                {
                    title: $__("Copy item to the following train"),
                    message: null,
                    accept_label: $__("Save"),
                    cancel_label: $__("Cancel"),
                    inputs: [
                        {
                            name: "train_id",
                            type: "relationshipSelect",
                            label: $__("Select a train"),
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
                    size: "modal-lg",
                },
                copyItem
            );
        };
        const clearAll = () => {
            selected_items.value = [];
            if (props.item_table.display) {
                $("#" + table_id)
                    .find("input[name='user_train_item_id'][type='checkbox']")
                    .prop("checked", false);
            }
        };
        const selectAll = () => {
            if (props.item_table.display) {
                $("#" + table_id)
                    .find(
                        "input[name='user_train_item_id'][type='checkbox']:not(:disabled)"
                    )
                    .each((i, input) => {
                        selected_items.value.push($(input).val());
                        $(input).prop("checked", true);
                    });
            } else {
                selected_items.value = props.train.items
                    .filter(i => i.processing.letter_code)
                    .map(item => item.train_item_id);
            }
        };
        const printSelected = () => {
            window.open(
                "/cgi-bin/koha/preservation/print_slip.pl?%s_blank".format(
                    selected_items.value
                        .map(id => "train_item_id=" + id)
                        .join("&")
                )
            );
        };
        const updateSelectedItems = (checked, train_item_id) => {
            if (checked) {
                selected_items.value.push(train_item_id);
            } else {
                selected_items.value = selected_items.value.filter(
                    id => id != train_item_id
                );
            }
        };
        const copyItem = (result, trainToCopy) => {
            const client = APIClient.preservation;
            client.train_items
                .copy(
                    trainToCopy.train_id,
                    props.train.train_id,
                    train_item_id_to_copy.value
                )
                .then(
                    success => {
                        setMessage($__("Item copied successfully."));
                    },
                    error => {
                        setWarning(
                            $__(
                                "Item cannot be copied to a train, it is already in a non-received train."
                            )
                        );
                    }
                );
        };
        const build_datatable = () => {
            let tableId = table_id;
            let itemTable = props.item_table;
            let remove_item = removeItem;
            let edit_item = editItem;
            let print_slip = printSlip;
            let select_train_for_copy = selectTrainForCopy;
            let train = props.train;
            let update_selected_items = updateSelectedItems;

            let table = $("#" + tableId).kohaTable({
                data: itemTable.data,
                ordering: false,
                columns: itemTable.columns,
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings);
                    $.each($(this).find("td.checkboxes"), function (index, e) {
                        let tr = $(this).parent();
                        let train_item = api.row(tr).data().item;
                        let train_item_id = train_item.train_item_id;

                        let checkbox = createVNode("input", {
                            ...(!train_item.processing.letter_code && {
                                disabled: "disabled",
                                title: $__(
                                    "Cannot print slip, this item does not have a processing with a letter template defined."
                                ),
                            }),
                            type: "checkbox",
                            name: "user_train_item_id",
                            value: train_item_id,
                            onChange: e => {
                                update_selected_items(
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
                                    edit_item(train_item_id);
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-pencil",
                                    "aria-hidden": "true",
                                }),
                                " ",
                                $__("Edit"),
                            ]
                        );

                        let removeButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    remove_item(train_item_id);
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-trash",
                                    "aria-hidden": "true",
                                }),
                                " ",
                                $__("Remove"),
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
                                            select_train_for_copy(
                                                train_item_id
                                            );
                                        },
                                    },
                                    [
                                        createVNode("i", {
                                            class: "fa fa-copy",
                                            "aria-hidden": "true",
                                        }),
                                        " ",
                                        $__("Copy"),
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
                                        print_slip(train_item_id);
                                    },
                                },
                                [
                                    createVNode("i", {
                                        class: "fa fa-print",
                                        "aria-hidden": "true",
                                    }),
                                    $__("Print slip"),
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
        };

        onMounted(() => {
            build_datatable();
        });

        return {
            format_date,
            get_lib_from_av,
            table_id,
            setConfirmationDialog,
            setMessage,
            setWarning,
            initialized,
            train_id_selected_for_copy,
            train_item_id_to_copy,
            selected_items,
            selectAll,
            clearAll,
            printSelected,
        };
    },
    props: {
        train: {
            type: Object,
            required: true,
        },
        item_table: Object,
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
