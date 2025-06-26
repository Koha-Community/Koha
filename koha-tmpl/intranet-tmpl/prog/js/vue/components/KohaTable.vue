<template>
    <DataTable
        :columns="tableColumns"
        :options="{ ...dataTablesDefaults, ...allOptions }"
        ref="table"
    >
        <slot></slot>
    </DataTable>
</template>

<script>
import DataTable from "datatables.net-vue3";
import DataTablesLib from "datatables.net";
import "datatables.net-buttons";
import "datatables.net-buttons/js/buttons.html5";
import "datatables.net-buttons/js/buttons.print";
import "datatables.net-buttons/js/buttons.colVis";
import {
    onBeforeMount,
    onBeforeUnmount,
    onMounted,
    ref,
    useTemplateRef,
} from "vue";
import { useRoute } from "vue-router";
import { $__ } from "@koha-vue/i18n";

DataTable.use(DataTablesLib);

export default {
    name: "KohaTable",
    setup(props, { emit }) {
        const route = useRoute();
        let buttons = _dt_buttons({
            settings: props.options,
            table_settings: props.table_settings,
        });

        if (props.add_filters) {
            props.options.orderCellsTop = true;
        }

        if (props.table_settings) {
            let state_settings = _dt_save_restore_state(props.table_settings);
            props.options.stateSave = state_settings.stateSave;
            props.options.stateSaveCallback = state_settings.stateSaveCallback;
            props.options.stateLoadCallback = state_settings.stateLoadCallback;

            if (
                props.table_settings.hasOwnProperty("default_display_length") &&
                props.table_settings.default_display_length != null
            ) {
                props.options.pageLength =
                    props.table_settings.default_display_length;
            }
            if (
                props.table_settings.hasOwnProperty("default_sort_order") &&
                props.table_settings.default_sort_order != null
            ) {
                props.options.order = [
                    [props.table_settings.default_sort_order, "asc"],
                ];
            }
        }

        const table = useTemplateRef("table");
        const tableColumns = ref(props.columns);
        const allOptions = ref({
            paging: true,
            searching: true,
            ...(props.url && {
                ajax: {
                    url:
                        typeof props.url === "function"
                            ? props.url()
                            : props.url,
                    ..._dt_default_ajax({
                        options: { ...props.options, columns: props.columns },
                        default_filters: props.default_filters,
                    }),
                },
                serverSide: true,
                pagingType: "full_numbers",
                processing: true,
            }),
            ...(props.data && { data: props.data }),
            buttons,
            search: { search: route.query.q },
            columnDefs: [
                {
                    targets: "_all",
                    render: function (data, type, row, meta) {
                        if (type == "display") {
                            return escape_str(data);
                        }
                        return data;
                    },
                },
            ],
            ...props.options,
        });

        const redraw = url => {
            table.value.dt().ajax.url(url).draw();
        };
        const useTableObject = () => {
            let dt = table.value.dt();
            return dt;
        };

        onBeforeMount(() => {
            if (props.actions.hasOwnProperty("-1")) {
                if (props.searchable_additional_fields.length) {
                    props.searchable_additional_fields.forEach(
                        searchable_field => {
                            var _customRender = (function (searchable_field) {
                                var _render = function (data, type, row, meta) {
                                    return row._strings.additional_field_values
                                        .filter(
                                            field =>
                                                field.field_id ==
                                                searchable_field.extended_attribute_type_id
                                        )
                                        .map(el => el.value_str);
                                };
                                return _render;
                            })(searchable_field);

                            tableColumns.value.push({
                                name: searchable_field.name,
                                data: "extended_attributes",
                                datatype: "related-object",
                                related: "extended_attributes",
                                relatedKey: "field_id",
                                relatedValue:
                                    searchable_field.extended_attribute_type_id,
                                relatedSearchOn: "value",
                                className:
                                    "searchable-additional-column-" +
                                    searchable_field.extended_attribute_type_id,
                                title: searchable_field.name,
                                searchable: true,
                                sortable: false,
                                render: _customRender,
                            });

                            if (
                                searchable_field.authorised_value_category_name
                            ) {
                                let options =
                                    props.searchable_av_options[
                                        searchable_field
                                            .authorised_value_category_name
                                    ];

                                options.map(e => {
                                    e["_id"] = e["value"];
                                    e["_str"] = e["label"];
                                    return e;
                                });

                                props.filters_options[
                                    tableColumns.value.length - 1
                                ] = options;
                            }
                        }
                    );
                }

                tableColumns.value = [
                    ...tableColumns.value,
                    {
                        name: "actions",
                        className: "noExport",
                        title: $__("Actions"),
                        searchable: false,
                        sortable: false,
                        render: (data, type, row) => {
                            let content = [];
                            props.actions["-1"].forEach(action => {
                                if (typeof action === "object") {
                                    let action_name = Object.keys(action)[0];
                                    let should_display = true;

                                    if (
                                        typeof action[action_name]
                                            .should_display === "function"
                                    ) {
                                        should_display =
                                            action[action_name].should_display(
                                                row
                                            );
                                    }

                                    if (should_display) {
                                        content.push(
                                            `<a class="${action_name} btn btn-default btn-xs" role="button"><i class="${action[action_name].icon}"></i> ${action[action_name].text}</a>`
                                        );
                                    }
                                } else if (action == "edit") {
                                    content.push(
                                        '<a class="edit btn btn-default btn-xs" role="button"><i class="fa fa-pencil"></i> ' +
                                            $__("Edit") +
                                            "</a>"
                                    );
                                } else if (action == "delete") {
                                    content.push(
                                        '<a class="delete btn btn-default btn-xs" role="button"><i class="fa fa-trash"></i> ' +
                                            $__("Delete") +
                                            "</a>"
                                    );
                                } else if (action == "remove") {
                                    content.push(
                                        '<a class="remove btn btn-default btn-xs" role="button"><i class="fa fa-remove"></i> ' +
                                            $__("Remove") +
                                            "</a>"
                                    );
                                }
                            });
                            return content.join(" ");
                        },
                    },
                ];
            }
        });

        onMounted(() => {
            let dt = table.value.dt();
            let table_node = dt.table().node();
            let add_filters = props.add_filters;
            let filters_options = props.filters_options;
            if (add_filters) {
                _dt_add_filters(table_node, dt, filters_options);
            }

            dt.on("column-visibility.dt", function () {
                if (add_filters) {
                    _dt_add_filters(table_node, dt, filters_options);
                }
            });

            dt.on("search.dt", function (e, settings) {
                toggledClearFilter(
                    settings.oPreviousSearch.sSearch,
                    settings.nTable.id
                );
            });

            if (Object.keys(props.actions).length) {
                dt.on("draw", () => {
                    const dataSet = dt.rows().data();
                    Object.entries(props.actions).forEach(
                        ([col_id, actions]) => {
                            dt.column(col_id)
                                .nodes()
                                .to$()
                                .each(function (idx) {
                                    const data = dataSet[idx];
                                    actions.forEach(action => {
                                        let action_name =
                                            typeof action === "object"
                                                ? Object.keys(action)[0]
                                                : action;
                                        $("." + action_name, this).on(
                                            "click",
                                            e => {
                                                emit(action_name, data, dt, e);
                                            }
                                        );
                                    });
                                });
                        }
                    );
                });
            }
        });

        onBeforeUnmount(() => {
            const dt = table.value.dt();
            dt.destroy();
        });
        return {
            dataTablesDefaults,
            tableColumns,
            allOptions,
            redraw,
            useTableObject,
        };
    },
    components: {
        DataTable,
    },
    props: {
        url: {
            type: [String, Function],
            default: "",
        },
        columns: {
            type: Array,
            default: [],
        },
        actions: {
            type: Object,
            default: {},
        },
        options: {
            type: Object,
            default: {},
        },
        default_filters: {
            type: Object,
            required: false,
        },
        table_settings: {
            type: Object,
            required: false,
        },
        add_filters: {
            type: Boolean,
            required: false,
        },
        filters_options: {
            type: Object,
            required: false,
        },
        searchable_additional_fields: {
            type: Array,
            required: false,
            default: [],
        },
        searchable_av_options: {
            type: Array,
            required: false,
            default: [],
        },
        data: {
            type: Array,
            required: false,
            default: [],
        },
    },
};
</script>
