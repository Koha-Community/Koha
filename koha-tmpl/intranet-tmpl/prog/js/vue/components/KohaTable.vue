<template>
    <DataTable
        :columns="tableColumns"
        :options="{ ...dataTablesDefaults, ...allOptions }"
        :data="data"
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

DataTable.use(DataTablesLib);

export default {
    name: "KohaTable",
    data() {
        let buttons = _dt_buttons({
            settings: this.options,
            table_settings: this.table_settings,
        });

        if (this.add_filters) {
            this.options.orderCellsTop = true;
        }

        if (this.table_settings) {
            let state_settings = _dt_save_restore_state(this.table_settings);
            this.options.stateSave = state_settings.stateSave;
            this.options.stateSaveCallback = state_settings.stateSaveCallback;
            this.options.stateLoadCallback = state_settings.stateLoadCallback;

            if (
                this.table_settings.hasOwnProperty("default_display_length") &&
                this.table_settings.default_display_length != null
            ) {
                this.options.pageLength =
                    this.table_settings.default_display_length;
            }
            if (
                this.table_settings.hasOwnProperty("default_sort_order") &&
                this.table_settings.default_sort_order != null
            ) {
                this.options.order = [
                    [this.table_settings.default_sort_order, "asc"],
                ];
            }
        }

        return {
            data: [],
            tableColumns: this.columns,
            allOptions: {
                paging: true,
                serverSide: true,
                searching: true,
                pagingType: "full_numbers",
                processing: true,
                autoWidth: false,
                ajax: {
                    url: typeof this.url === "function" ? this.url() : this.url,
                    ..._dt_default_ajax({
                        options: { ...this.options, columns: this.columns },
                        default_filters: this.default_filters,
                    }),
                },
                buttons,
                search: { search: this.$route.query.q },
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
                ...this.options,
            },
        };
    },
    setup() {
        return { dataTablesDefaults };
    },
    methods: {
        redraw: function (url) {
            this.$refs.table.dt().ajax.url(url).draw();
        },
        useTableObject: function () {
            let dt = this.$refs.table.dt();
            return dt;
        },
    },
    beforeMount() {
        if (this.actions.hasOwnProperty("-1")) {
            if (this.searchable_additional_fields.length) {
                this.searchable_additional_fields.forEach(searchable_field => {
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

                    this.tableColumns.push({
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

                    if (searchable_field.authorised_value_category_name) {
                        let options =
                            this.searchable_av_options[
                                searchable_field.authorised_value_category_name
                            ];

                        options.map(e => {
                            e["_id"] = e["value"];
                            e["_str"] = e["label"];
                            return e;
                        });

                        this.filters_options[this.tableColumns.length - 1] =
                            options;
                    }
                });
            }

            this.tableColumns = [
                ...this.tableColumns,
                {
                    name: "actions",
                    className: "noExport",
                    title: this.$__("Actions"),
                    searchable: false,
                    sortable: false,
                    render: (data, type, row) => {
                        let content = [];
                        this.actions["-1"].forEach(action => {
                            if (typeof action === "object") {
                                let action_name = Object.keys(action)[0];
                                let should_display = true;

                                if (
                                    typeof action[action_name]
                                        .should_display === "function"
                                ) {
                                    should_display =
                                        action[action_name].should_display(row);
                                }

                                if (should_display) {
                                    content.push(
                                        `<a class="${action_name} btn btn-default btn-xs" role="button"><i class="${action[action_name].icon}"></i> ${action[action_name].text}</a>`
                                    );
                                }
                            } else if (action == "edit") {
                                content.push(
                                    '<a class="edit btn btn-default btn-xs" role="button"><i class="fa fa-pencil"></i> ' +
                                        this.$__("Edit") +
                                        "</a>"
                                );
                            } else if (action == "delete") {
                                content.push(
                                    '<a class="delete btn btn-default btn-xs" role="button"><i class="fa fa-trash"></i> ' +
                                        this.$__("Delete") +
                                        "</a>"
                                );
                            } else if (action == "remove") {
                                content.push(
                                    '<a class="remove btn btn-default btn-xs" role="button"><i class="fa fa-remove"></i> ' +
                                        this.$__("Remove") +
                                        "</a>"
                                );
                            }
                        });
                        return content.join(" ");
                    },
                },
            ];
        }
    },
    mounted() {
        let dt = this.$refs.table.dt();
        let table_node = dt.table().node();
        let add_filters = this.add_filters;
        let filters_options = this.filters_options;
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

        if (Object.keys(this.actions).length) {
            const self = this;
            dt.on("draw", () => {
                const dataSet = dt.rows().data();
                Object.entries(this.actions).forEach(([col_id, actions]) => {
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
                                $("." + action_name, this).on("click", e => {
                                    self.$emit(action_name, data, dt, e);
                                });
                            });
                        });
                });
            });
        }
    },
    beforeUnmount() {
        const dt = this.$refs.table.dt();
        dt.destroy();
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
    },
};
</script>
