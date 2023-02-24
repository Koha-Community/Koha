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
DataTable.use(DataTablesLib)

export default {
    name: "KohaTable",
    data() {
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
                ajax: {
                    url: typeof this.url === "function" ? this.url() : this.url,
                    ..._dt_default_ajax({ options: this.options }),
                },
                buttons: _dt_buttons({ table_settings: this.table_settings }),
                default_search: this.$route.query.q,
            },
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
            let actions = this.actions["-1"]
            this.tableColumns = [
                ...this.tableColumns,
                {
                    name: "actions",
                    title: this.$__("Actions"),
                    searchable: false,
                    render: (data, type, row) => {
                        let content = []
                        this.actions["-1"].forEach(a => {
                            if (a == "edit") {
                                content.push(
                                    '<a class="edit btn btn-default btn-xs" role="button"><i class="fa fa-pencil"></i>' +
                                        this.$__("Edit") +
                                        "</a>"
                                )
                            } else if (a == "delete") {
                                content.push(
                                    '<a class="delete btn btn-default btn-xs" role="button"><i class="fa fa-trash"></i>' +
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
    },
    mounted() {
        if (Object.keys(this.actions).length) {
            const dt = this.$refs.table.dt()
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
                                $("." + action, this).on("click", e => {
                                    self.$emit(action, data, dt, e)
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
        default_search: {
            type: String,
            required: false,
        },
    },
}
</script>
