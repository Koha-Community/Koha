<template>
    <h2>{{ $__("Import from a list") }}</h2>
    <div v-if="job_id" class="dialog message">
        {{ $__("Import in progress,") }}
        <router-link :to="`/cgi-bin/koha/admin/background_jobs/${job_id}`">
            {{ $__("see job #%s").format(job_id) }}
        </router-link>
    </div>
    <div id="package_list">
        {{ $__("To the following local package") }}:
        <v-select
            v-model="package_id"
            label="name"
            :reduce="(p) => p.package_id"
            :options="packages"
            :clearable="false"
        >
        </v-select>
    </div>
    <div id="import_list_result">
        <table :id="table_id"></table>
    </div>
</template>

<script>
import { setMessage, setError, setWarning } from "../../messages"
import { createVNode, render } from 'vue'
import { useDataTable } from "../../composables/datatables"
import { checkError, fetchLocalPackages } from '../../fetch.js'

export default {
    setup() {
        const table_id = "list_list"
        useDataTable(table_id)

        return {
            table_id,
            logged_in_user_lists,
        }
    },
    data() {
        return {
            job_id: null,
            package_id: null,
            packages: [],
        }
    },
    beforeCreate() {
        fetchLocalPackages().then((packages) => {
            this.packages = packages
            if (this.packages.length) {
                this.package_id = packages[0].package_id
            }
        })
    },
    methods: {
        import_from_list: async function (list_id) {
            if (!this.package_id) {
                setError(this.$__("Cannot import, no package selected"))
                return
            }
            if (!list_id) return
            await fetch('/api/v1/erm/eholdings/local/titles/import', {
                method: "POST",
                body: JSON.stringify({ list_id, package_id: this.package_id }),
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
            })
                .then(checkError)
                .then(
                    (result) => {
                        this.job_id = result.job_id
                    },
                    (error) => {
                        setError(error)
                    }
                )
        },
        build_datatable: function () {
            let lists = this.logged_in_user_lists
            let table_id = this.table_id
            let import_from_list = this.import_from_list
            $('#' + table_id).dataTable($.extend(true, {}, dataTablesDefaults, {
                data: lists,
                order: [[0, "asc"]],
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "shelfname",
                        searchable: true,
                        orderable: true,
                        width: '100%',
                        render: function (data, type, row, meta) {
                            return row.shelfname + ' (#' + row.shelfnumber + ')'
                        }
                    },
                    {
                        title: __("Actions"),
                        data: function (row, type, val, meta) {
                            return '<div class="actions"></div>'
                        },
                        className: "actions noExport",
                        searchable: false,
                        orderable: false
                    }
                ],
                drawCallback: function (settings) {

                    var api = new $.fn.dataTable.Api(settings)

                    $.each($(this).find("td .actions"), function (index, e) {
                        let tr = $(this).parent().parent()
                        let list_id = api.row(tr).data().shelfnumber
                        let importButton = createVNode("a", {
                            class: "btn btn-default btn-xs", role: "button", onClick: () => {
                                import_from_list(list_id)
                            }
                        },
                            [createVNode("i", { class: "fa fa-download", 'aria-hidden': "true" }), __("Import")])

                        let n = createVNode('span', {}, [importButton])
                        render(n, e)
                    })
                }
            }))
        },
    },
    mounted() {
        this.build_datatable()
    },
    name: "EHoldingsLocalTitlesFormImport",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
