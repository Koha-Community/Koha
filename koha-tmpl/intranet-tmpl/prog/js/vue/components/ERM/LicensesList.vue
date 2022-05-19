<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else-if="this.licenses" id="licenses_list">
        <Toolbar />
        <table v-if="licenses.length" id="license_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            {{ $t("There are no licenses defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./LicensesToolbar.vue"
import { createVNode, render } from 'vue'
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchLicenses } from "../../fetch"

export default {
    setup() {
        const AVStore = useAVStore()
        const {
            av_license_types,
            av_license_statuses,
        } = storeToRefs(AVStore)

        return {
            av_license_types,
            av_license_statuses,
        }
    },
    updated() {
        let show_license = this.show_license
        let edit_license = this.edit_license
        let delete_license = this.delete_license
        window['av_license_types'] = this.av_license_types.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let av_license_types_map = this.av_license_types.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['av_license_statuses'] = this.av_license_statuses.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let av_license_statuses_map = this.av_license_statuses.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})

        $('#license_list').kohaTable({
            "ajax": {
                "url": licenses_table_url,
            },
            "order": [[1, "asc"]],
            "columnDefs": [{
                "targets": [0, 1],
                "render": function (data, type, row, meta) {
                    if (type == 'display') {
                        return escape_str(data)
                    }
                    return data
                }
            }],
            "columns": [
                {
                    "title": __("Name"),
                    "data": ["me.license_id", "me.name"],
                    "searchable": true,
                    "orderable": true,
                    // Rendering done in drawCallback
                },
                {
                    "title": __("Description"),
                    "data": "description",
                    "searchable": true,
                    "orderable": true
                },
                {
                    "title": __("Type"),
                    "data": "type",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(av_license_types_map[row.type].lib)
                    }
                },
                {
                    "title": __("Status"),
                    "data": "status",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(av_license_statuses_map[row.status].lib)
                    }
                },
                {
                    "title": __("Started on"),
                    "data": "started_on",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(row.started_on)
                    }
                },
                {
                    "title": __("Ended on"),
                    "data": "ended_on",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(row.ended_on)
                    }
                },
                {
                    "title": __("Actions"),
                    "data": function (row, type, val, meta) {
                        return '<div class="actions"></div>'
                    },
                    "className": "actions noExport",
                    "searchable": false,
                    "orderable": false
                }
            ],
            drawCallback: function (settings) {

                var api = new $.fn.dataTable.Api(settings)

                $.each($(this).find("td .actions"), function (index, e) {
                    let license_id = api.row(index).data().license_id
                    let editButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            edit_license(license_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                    let deleteButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            delete_license(license_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-trash", 'aria-hidden': "true" }), __("Delete")])

                    let n = createVNode('span', {}, [editButton, " ", deleteButton])
                    render(n, e)
                })

                $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                    let row = api.row(index).data()
                    if (!row) return // Happen if the table is empty
                    let n = createVNode("a", {
                        role: "button",
                        onClick: () => {
                            show_license(row.license_id)
                        }
                    },
                        escape_str(`${row.name} (#${row.license_id})`)
                    )
                    render(n, e)
                })
            },
            preDrawCallback: function (settings) {
                var table_id = settings.nTable.id
                $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'av_license_types')
                $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'av_license_statuses')
            }

        }, table_settings, 1)
    },
    beforeUnmount() {
        $('#license_list')
            .DataTable()
            .destroy(true)
    },
    data: function () {
        return {
            licenses: [],
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getLicenses()
        })
    },
    methods: {
        async getLicenses() {
            const licenses = await fetchLicenses()
            this.licenses = licenses
            this.initialized = true
        },
        show_license: function (license_id) {
            this.$router.push("/cgi-bin/koha/erm/licenses/" + license_id)
        },
        edit_license: function (license_id) {
            this.$router.push("/cgi-bin/koha/erm/licenses/edit/" + license_id)
        },
        delete_license: function (license_id) {
            this.$router.push("/cgi-bin/koha/erm/licenses/delete/" + license_id)
        },
    },
    props: {
        av_license_types: Array,
        av_license_statuses: Array,
    },
    components: { Toolbar },
    name: "LicensesList",
}
</script>
