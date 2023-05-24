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
import DataTable from "datatables.net-vue3"
import DataTablesLib from "datatables.net"
import "datatables.net-buttons"
import "datatables.net-buttons/js/buttons.html5"
import "datatables.net-buttons/js/buttons.print"
import "datatables.net-buttons/js/buttons.colVis"
DataTable.use(DataTablesLib)

export default {
    name: "KohaTable",
    data() {
        let hidden_ids, included_ids
        ;[hidden_ids, included_ids] = _dt_visibility(
            this.table_settings,
            this.options
        )
        let buttons = _dt_buttons({
            included_ids,
            table_settings: this.table_settings,
        })
        return {
            data: [],
            tableColumns: this.columns,
            allOptions: {
                deferRender: true,
                paging: true,
                serverSide: true,
                searching: true,
                pagingType: "full_numbers",
                processing: true,
                autoWidth: false,
                ajax: {
                    url: typeof this.url === "function" ? this.url() : this.url,
                    ..._dt_default_ajax({
                        options: this.options,
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
                                return escape_str(data)
                            }
                            return data
                        },
                    },
                ],
                ...this.options,
            },
            hidden_ids,
            included_ids,
        }
    },
    setup() {
        return { dataTablesDefaults }
    },
    methods: {
        redraw: function (url) {
            this.$refs.table.dt().ajax.url(url).draw()
        },
    },
    beforeMount() {
        if (this.actions.hasOwnProperty("-1")) {
            this.tableColumns = [
                ...this.tableColumns,
                {
                    name: "actions",
                    title: this.$__("Actions"),
                    searchable: false,
                    render: (data, type, row) => {
                        let content = []
                        this.actions["-1"].forEach(action => {
                            if (typeof action === "object") {
                                let action_name = Object.keys(action)[0]
                                content.push(
                                    `<a class="${action_name} btn btn-default btn-xs" role="button"><i class="${action[action_name].icon}"></i> ${action[action_name].text}</a>`
                                )
                            } else if (action == "edit") {
                                content.push(
                                    '<a class="edit btn btn-default btn-xs" role="button"><i class="fa fa-pencil"></i> ' +
                                        this.$__("Edit") +
                                        "</a>"
                                )
                            } else if (action == "delete") {
                                content.push(
                                    '<a class="delete btn btn-default btn-xs" role="button"><i class="fa fa-trash"></i> ' +
                                        this.$__("Delete") +
                                        "</a>"
                                )
                            }
                        })
                        return content.join(" ")
                    },
                },
            ]
        }

        $(
            ".dt_button_clear_filter, .columns_controls, .export_controls, .dt_button_configure_table"
        ).tooltip()

        if (this.add_filters) {
            this.options.orderCellsTop = true
        }

        if (this.table_settings) {
            if (
                this.table_settings.hasOwnProperty("default_display_length") &&
                this.table_settings.default_display_length != null
            ) {
                this.options.pageLength =
                    this.table_settings.default_display_length
            }
            if (
                this.table_settings.hasOwnProperty("default_sort_order") &&
                this.table_settings.default_sort_order != null
            ) {
                this.options.order = [
                    [this.table_settings.default_sort_order, "asc"],
                ]
            }
        }
    },
    mounted() {
        let dt = this.$refs.table.dt()
        let table_node = dt.table().node()
        let add_filters = this.add_filters
        if (add_filters) {
            _dt_add_filters(table_node, dt, this.filters_options)
        }

        dt.on("column-visibility.dt", function () {
            _dt_on_visibility(add_filters, table_node, dt)
        })
            .columns(this.hidden_ids)
            .visible(false)

        if (Object.keys(this.actions).length) {
            const self = this
            dt.on("draw", () => {
                const dataSet = dt.rows().data()
                Object.entries(this.actions).forEach(([col_id, actions]) => {
                    dt.column(col_id)
                        .nodes()
                        .to$()
                        .each(function (idx) {
                            const data = dataSet[idx]
                            actions.forEach(action => {
                                let action_name =
                                    typeof action === "object"
                                        ? Object.keys(action)[0]
                                        : action
                                $("." + action_name, this).on("click", e => {
                                    self.$emit(action_name, data, dt, e)
                                })
                            })
                        })
                })
            })
        }
    },
    beforeUnmount() {
        const dt = this.$refs.table.dt()
        dt.destroy()
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
    },
}
</script>
