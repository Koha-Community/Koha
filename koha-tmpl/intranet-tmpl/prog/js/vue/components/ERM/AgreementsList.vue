<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else-if="this.agreements" id="agreements_list">
        <Toolbar v-if="before_route_entered" />
        <table v-if="this.agreements.length" id="agreement_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            {{ $t("There are no agreements defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./AgreementsToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchAgreements } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { av_agreement_statuses, av_agreement_closure_reasons, av_agreement_renewal_priorities } = storeToRefs(AVStore)

        return {
            vendors,
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
        }
    },
    data: function () {
        return {
            agreements: [],
            initialized: false,
            before_route_entered: false,
            building_table: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.before_route_entered = true // FIXME This is ugly, but we need to distinguish when it's used as main component or child component (from EHoldingsEBSCOPAckagesShow for instance)
            if (!vm.building_table) {
                vm.building_table = true
                vm.getAgreements().then(() => vm.build_datatable())
            }
        })
    },
    methods: {
        async getAgreements() {
            const agreements = await fetchAgreements()
            this.agreements = agreements
            this.initialized = true
        },
        show_agreement: function (agreement_id) {
            this.$router.push("/cgi-bin/koha/erm/agreements/" + agreement_id)
        },
        edit_agreement: function (agreement_id) {
            this.$router.push("/cgi-bin/koha/erm/agreements/edit/" + agreement_id)
        },
        delete_agreement: function (agreement_id) {
            this.$router.push("/cgi-bin/koha/erm/agreements/delete/" + agreement_id)
        },
        select_agreement: function (agreement_id) {
            this.$emit('select-agreement', agreement_id)
            this.$emit('close')
        },
        build_datatable: function () {
            let show_agreement = this.show_agreement
            let edit_agreement = this.edit_agreement
            let delete_agreement = this.delete_agreement
            let select_agreement = this.select_agreement
            let default_search = this.$route.query.q
            let actions = this.before_route_entered ? 'edit_delete' : 'select'

            window['vendors'] = this.vendors.map(e => {
                e['_id'] = e['id']
                e['_str'] = e['name']
                return e
            })
            let vendors_map = this.vendors.reduce((map, e) => {
                map[e.id] = e
                return map
            }, {})
            window['av_agreement_statuses'] = this.av_agreement_statuses.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })
            let av_agreement_statuses_map = this.av_agreement_statuses.reduce((map, e) => {
                map[e.authorised_value] = e
                return map
            }, {})
            window['av_agreement_closure_reasons'] = this.av_agreement_closure_reasons.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })
            let av_agreement_closure_reasons_map = this.av_agreement_closure_reasons.reduce((map, e) => {
                map[e.authorised_value] = e
                return map
            }, {})
            window['av_agreement_renewal_priorities'] = this.av_agreement_renewal_priorities.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })
            let av_agreement_renewal_priorities_map = this.av_agreement_renewal_priorities.reduce((map, e) => {
                map[e.authorised_value] = e
                return map
            }, {})
            window['av_agreement_is_perpetual'] = [{ _id: 0, _str: _('No') }, { _id: 1, _str: _("Yes") }]

            const table = $('#agreement_list').kohaTable({
                "ajax": {
                    "url": "/api/v1/erm/agreements",
                },
                "order": [[0, "asc"]],
                autoWidth: false,
                "search": { search: default_search },
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
                        "data": "me.agreement_id:me.name",
                        "searchable": true,
                        "orderable": true,
                        "render": function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
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
                        "title": __("Description"),
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
                            return escape_str(av_agreement_statuses_map[row.status].lib)
                        }
                    },
                    {
                        "title": __("Closure reason"),
                        "data": "closure_reason",
                        "searchable": true,
                        "orderable": true,
                        "render": function (data, type, row, meta) {
                            return row.closure_reason != undefined && row.closure_reason != "" ? escape_str(av_agreement_closure_reasons_map[row.closure_reason].lib) : ""
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
                            return row.renewal_priority != undefined && row.renewal_priority != "" ? escape_str(av_agreement_renewal_priorities_map[row.renewal_priority].lib) : ""
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

                    if (actions == 'edit_delete') {
                        $.each($(this).find("td .actions"), function (index, e) {
                            let agreement_id = api.row(index).data().agreement_id
                            let editButton = createVNode("a", {
                                class: "btn btn-default btn-xs", role: "button", onClick: () => {
                                    edit_agreement(agreement_id)
                                }
                            },
                                [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                            let deleteButton = createVNode("a", {
                                class: "btn btn-default btn-xs", role: "button", onClick: () => {
                                    delete_agreement(agreement_id)
                                }
                            },
                                [createVNode("i", { class: "fa fa-trash", 'aria-hidden': "true" }), __("Delete")])

                            let n = createVNode('span', {}, [editButton, " ", deleteButton])
                            render(n, e)
                        })
                    } else {
                        $.each($(this).find("td .actions"), function (index, e) {
                            let agreement_id = api.row(index).data().agreement_id
                            let selectButton = createVNode("a", {
                                class: "btn btn-default btn-xs", role: "button", onClick: () => {
                                    select_agreement(agreement_id)
                                }
                            },
                                [createVNode("i", { class: "fa fa-check", 'aria-hidden': "true" }), __("Select")])

                            let n = createVNode('span', {}, [selectButton])
                            render(n, e)
                        })
                    }

                    $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                        let row = api.row(index).data()
                        if (!row) return // Happen if the table is empty
                        let n = createVNode("a", {
                            role: "button",
                            onClick: () => {
                                show_agreement(row.agreement_id)
                            }
                        },
                            `${row.name} (#${row.agreement_id})`
                        )
                        render(n, e)
                    })
                },
                preDrawCallback: function (settings) {
                    var table_id = settings.nTable.id
                    $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'vendors')
                    $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'av_agreement_statuses')
                    $("#" + table_id).find("thead th").eq(4).attr('data-filter', 'av_agreement_closure_reasons')
                    $("#" + table_id).find("thead th").eq(5).attr('data-filter', 'av_agreement_is_perpetual')
                    $("#" + table_id).find("thead th").eq(6).attr('data-filter', 'av_agreement_renewal_priorities')
                }

            }, agreement_table_settings, 1)
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true
            this.getAgreements().then(() => this.build_datatable())
        }
    },
    beforeUnmount() {
        if ($.fn.DataTable.isDataTable('#agreement_list')) {
            $('#agreement_list')
                .DataTable()
                .destroy(true)
        }
    },
    components: { Toolbar },
    name: "AgreementsList",
    emits: ["select-agreement", "close"],
}
</script>

<style scoped>
#agreement_list {
    display: table;
}
</style>