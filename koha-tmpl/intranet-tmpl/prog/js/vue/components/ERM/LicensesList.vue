<template>
    <div>
        <table v-if="licenses.length" id="license_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            There are no licenses defined.
        </div>
        <div v-else>Loading...</div>
    </div>
</template>

<script>
import ButtonEdit from "./ButtonEdit.vue"
import ButtonDelete from "./ButtonDelete.vue"
import { createVNode, defineComponent, render, resolveComponent } from 'vue'
export default {
    created() {
        const apiUrl = '/api/v1/erm/licenses'

        fetch(apiUrl)
            .then(res => res.json())
            .then(
                (result) => {
                    this.licenses = result
                    this.initialized = true
                },
                (error) => {
                    this.$emit('set-error', error)
                }
            )
    },
    updated() {
        let show_license = this.show_license
        let edit_license = this.edit_license
        let delete_license = this.delete_license
        window['licenses_av_types'] = this.av_types.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let types_map = this.av_types.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['licenses_av_statuses'] = this.av_statuses.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let statuses_map = this.av_statuses.reduce((map, e) => {
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
                        return escape_str(types_map[row.type].lib)
                    }
                },
                {
                    "title": __("Status"),
                    "data": "status",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(statuses_map[row.status].lib)
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
                    let editButton = createVNode(ButtonEdit, {
                        onClick: () => {
                            edit_license(license_id)
                        }
                    })
                    let deleteButton = createVNode(ButtonDelete, {
                        onClick: () => {
                            delete_license(license_id)
                        }
                    })
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
                $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'licenses_av_types')
                $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'licenses_av_statuses')
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
    methods: {
        show_license: function (license_id) {
            this.$emit('set-current-license-id', license_id)
            this.$emit('switch-view', 'show')
        },
        edit_license: function (license_id) {
            this.$emit('set-current-license-id', license_id)
            this.$emit('switch-view', 'add-form')
        },
        delete_license: function (license_id) {
            this.$emit('set-current-license-id', license_id)
            this.$emit('switch-view', 'confirm-delete-form')
        },
    },
    props: {
        av_types: Array,
        av_statuses: Array,
    },
    name: "LicensesList",
}
</script>
