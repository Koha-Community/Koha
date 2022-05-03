<template>
    <div>
        <table v-if="agreements.length" id="my_table"></table>
        <div v-else-if="this.initialized" class="dialog message">
            There are no agreements defined.
        </div>
        <div v-else>Loading...</div>
    </div>
</template>

<script>
import AgreementsButtonEdit from "./AgreementsButtonEdit.vue"
import AgreementsButtonDelete from "./AgreementsButtonDelete.vue"
import { createVNode, defineComponent, render, resolveComponent } from 'vue'
export default {
    created() {
        const apiUrl = '/api/v1/erm/agreements'

        fetch(apiUrl)
            .then(res => res.json())
            .then(
                (result) => {
                    this.agreements = result
                    this.initialized = true
                },
            ).catch(
                (error) => {
                    this.$emit('set-error', error)
                }
            )
    },
    updated() {
        let show_agreement = this.show_agreement
        let edit_agreement = this.edit_agreement
        let delete_agreement = this.delete_agreement
        window['av_vendors'] = this.vendors.map(e => {
            e['_id'] = e['id']
            e['_str'] = e['name']
            return e
        })
        let vendors_map = this.vendors.reduce((map, e) => {
            map[e.id] = e
            return map
        }, {})
        window['av_statuses'] = this.av_statuses.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let statuses_map = this.av_statuses.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['av_closure_reasons'] = this.av_closure_reasons.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let closure_reasons_map = this.av_closure_reasons.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['av_renewal_priorities'] = this.av_renewal_priorities.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let renewal_priorities_map = this.av_renewal_priorities.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['av_is_perpetual'] = [{ _id: 0, _str: _('No') }, { _id: 1, _str: _("Yes") }]

        $('#my_table').kohaTable({
            "ajax": {
                "url": agreements_table_url,
            },
            "order": [[1, "asc"]],
            "columnDefs": [{
                "targets": [0, 2],
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
                    "data": ["me.agreement_id", "me.name"],
                    "searchable": true,
                    "orderable": true,
                    // Rendering done in drawCallback
                },
                {
                    "title": __("Vendor"),
                    "data": "vendor_id",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.vendor_id != undefined ? escape_str(vendors_map[row.vendor_id].name) : ""
                    }
                },
                {
                    "title": __("description"),
                    "data": "description",
                    "searchable": true,
                    "orderable": true
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
                    "title": __("Closure reason"),
                    "data": "closure_reason",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.closure_reason != undefined && row.closure_reason != "" ? escape_str(closure_reasons_map[row.closure_reason].lib) : ""
                    }
                },
                {
                    "title": __("Is perpetual"),
                    "data": "is_perpetual",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(row.is_perpetual ? _("Yes") : _("No"))
                    }
                },
                {
                    "title": __("Renewal priority"),
                    "data": "renewal_priority",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.renewal_priority != undefined && row.renewal_priority != "" ? escape_str(renewal_priorities_map[row.renewal_priority].lib) : ""
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
                    let agreement_id = api.row(index).data().agreement_id
                    let editButton = createVNode(AgreementsButtonEdit, {
                        onClick: () => {
                            edit_agreement(agreement_id)
                        }
                    })
                    let deleteButton = createVNode(AgreementsButtonDelete, {
                        onClick: () => {
                            delete_agreement(agreement_id)
                        }
                    })
                    let n = createVNode('span', {}, [editButton, " ", deleteButton])
                    render(n, e)
                })

                $.each($(this).find("tr td:eq(0)"), function (index, e) {
                    let row = api.row(index).data()
                    let n = createVNode("a", {
                        role: "button",
                        onClick: () => {
                            show_agreement(row.agreement_id)
                        }
                    },
                        escape_str(`${row.name} (#${row.agreement_id})`)
                    )
                    render(n, e)
                })
            },
            preDrawCallback: function (settings) {
                var table_id = settings.nTable.id
                $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'av_vendors')
                $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'av_statuses')
                $("#" + table_id).find("thead th").eq(4).attr('data-filter', 'av_closure_reasons')
                $("#" + table_id).find("thead th").eq(5).attr('data-filter', 'av_is_perpetual')
                $("#" + table_id).find("thead th").eq(6).attr('data-filter', 'av_renewal_priorities')
            }

        }, table_settings, 1)
    },
    beforeUnmount() {
        $('#my_table')
            .DataTable()
            .destroy(true)
    },
    data: function () {
        return {
            agreements: [],
            initialized: false,
        }
    },
    methods: {
        show_agreement: function (agreement_id) {
            this.$emit('set-current-agreement-id', agreement_id)
            this.$emit('switch-view', 'show')
        },
        edit_agreement: function (agreement_id) {
            this.$emit('set-current-agreement-id', agreement_id)
            this.$emit('switch-view', 'add-form')
        },
        delete_agreement: function (agreement_id) {
            this.$emit('set-current-agreement-id', agreement_id)
            this.$emit('switch-view', 'confirm-delete-form')
        },
    },
    props: {
        vendors: Array,
        av_statuses: Array,
        av_closure_reasons: Array,
        av_renewal_priorities: Array,
    },
    name: "AgreementsList",
}
</script>
