<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else-if="agreements" id="agreements_list">
        <Toolbar v-if="before_route_entered" />
        <fieldset v-if="agreements.length">
            <label for="expired_filter">{{ $t("Filter by expired") }}:</label>
            <input
                type="checkbox"
                id="expired_filter"
                v-model="filters.by_expired"
                @keyup.enter="filter_table"
            />
            {{ $t("on") }}
            <flat-pickr
                id="max_expiration_date_filter"
                v-model="filters.max_expiration_date"
                :config="fp_config"
            />

            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$t('Filter')"
            />
        </fieldset>
        <table v-if="agreements.length" :id="table_id"></table>
        <div v-else-if="initialized" class="dialog message">
            {{ $t("There are no agreements defined") }}
        </div>
    </div>
</template>

<script>
import flatPickr from 'vue-flatpickr-component'
import Toolbar from "./AgreementsToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchAgreements } from "../../fetch"
import { useDataTable, build_url } from "../../composables/datatables"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const table_id = "agreement_list"
        useDataTable(table_id)

        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            table_id,
        }
    },
    data: function () {
        return {
            fp_config: flatpickr_defaults, dates_fixed: 0,
            agreements: [],
            initialized: false,
            filters: {
                by_expired: this.$route.query.by_expired || false,
                max_expiration_date: this.$route.query.max_expiration_date || "",
            },
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
    computed: {
        datatable_url() {
            let url = '/api/v1/erm/agreements'
            if (this.filters.by_expired)
                url += '?max_expiration_date=' + $date_to_rfc3339(this.filters.max_expiration_date)
            return url
        }
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
        filter_table: async function () {
            let new_route = build_url("/cgi-bin/koha/erm/agreements", this.filters)
            this.$router.push(new_route)
            if (this.filters.by_expired) {
                if (!this.filters.max_expiration_date)
                    this.filters.max_expiration_date = new Date()
            }
            $('#' + this.table_id).DataTable().ajax.url(this.datatable_url).draw()
        },
        table_url: function () {

        },
        build_datatable: function () {
            let show_agreement = this.show_agreement
            let edit_agreement = this.edit_agreement
            let delete_agreement = this.delete_agreement
            let select_agreement = this.select_agreement
            let get_lib_from_av = this.get_lib_from_av
            let map_av_dt_filter = this.map_av_dt_filter
            let datatable_url = this.datatable_url
            let default_search = this.$route.query.q
            let actions = this.before_route_entered ? 'edit_delete' : 'select'
            let table_id = this.table_id

            window['vendors'] = this.vendors.map(e => {
                e['_id'] = e['id']
                e['_str'] = e['name']
                return e
            })
            let vendors_map = this.vendors.reduce((map, e) => {
                map[e.id] = e
                return map
            }, {})
            let avs = ['av_agreement_statuses', 'av_agreement_closure_reasons', 'av_agreement_renewal_priorities']
            avs.forEach(function (av_cat) {
                window[av_cat] = map_av_dt_filter(av_cat)
            })

            window['av_agreement_is_perpetual'] = [{ _id: 0, _str: _('No') }, { _id: 1, _str: _("Yes") }]

            const table = $("#" + table_id).kohaTable({
                ajax: {
                    url: datatable_url
                },
                order: [[0, "asc"]],
                autoWidth: false,
                search: { search: default_search },
                columnDefs: [{
                    targets: [0, 2],
                    render: function (data, type, row, meta) {
                        if (type == 'display') {
                            return escape_str(data)
                        }
                        return data
                    }
                }],
                columns: [
                    {
                        title: __("Name"),
                        data: "me.agreement_id:me.name",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
                    },
                    {
                        title: __("Vendor"),
                        data: "vendor_id",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return row.vendor_id != undefined ? escape_str(vendors_map[row.vendor_id].name) : ""
                        }
                    },
                    {
                        title: __("Description"),
                        data: "description",
                        searchable: true,
                        orderable: true
                    },
                    {
                        title: __("Status"),
                        data: "status",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_agreement_statuses", row.status))
                        }
                    },
                    {
                        title: __("Closure reason"),
                        data: "closure_reason",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_agreement_closure_reasons", row.closure_reason))
                        }
                    },
                    {
                        title: __("Is perpetual"),
                        data: "is_perpetual",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(row.is_perpetual ? _("Yes") : _("No"))
                        }
                    },
                    {
                        title: __("Renewal priority"),
                        data: "renewal_priority",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_agreement_renewal_priorities", row.renewal_priority))
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

                    if (actions == 'edit_delete') {
                        $.each($(this).find("td .actions"), function (index, e) {
                            let tr = $(this).parent().parent()
                            let agreement_id = api.row(tr).data().agreement_id
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
                            let tr = $(this).parent().parent()
                            let agreement_id = api.row(tr).data().agreement_id
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
                        let tr = $(this).parent()
                        let row = api.row(tr).data()
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
    components: { flatPickr, Toolbar },
    name: "AgreementsList",
    emits: ["select-agreement", "close"],
}
</script>

<style scoped>
#agreement_list {
    display: table;
}
</style>
