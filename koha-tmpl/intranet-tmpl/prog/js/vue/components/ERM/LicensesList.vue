<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="licenses_list">
        <Toolbar />
        <div v-if="license_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="doShow"
                @edit="doEdit"
                @delete="doDelete"
            ></KohaTable>
        </div>
        <div v-else class="dialog message">
            {{ $__("There are no licenses defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./LicensesToolbar.vue"
import { inject, ref } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const table = ref()

        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            table,
            setConfirmationDialog,
            setMessage,
            license_table_settings,
        }
    },
    data: function () {
        return {
            license_count: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/licenses",
                options: { embed: "vendor" },
                table_settings: this.license_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"]
                            e["_str"] = e["name"]
                            return e
                        }),
                    3: () => this.map_av_dt_filter("av_license_types"),
                    4: () => this.map_av_dt_filter("av_license_statuses"),
                },
                actions: {
                    0: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getLicenseCount().then(() => (vm.initialized = true))
        })
    },
    methods: {
        async getLicenseCount() {
            const client = APIClient.erm
            await client.licenses.count().then(
                count => {
                    this.license_count = count
                },
                error => {}
            )
        },
        doShow: function ({ license_id }, dt, event) {
            event.preventDefault()
            this.$router.push({ name: "LicensesShow", params: { license_id } })
        },
        doEdit: function ({ license_id }, dt, event) {
            this.$router.push({
                name: "LicensesFormAddEdit",
                params: { license_id },
            })
        },
        doDelete: function (license, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this license?"
                    ),
                    message: license.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm
                    client.licenses.delete(license.license_id).then(
                        success => {
                            this.setMessage(
                                this.$__("License %s deleted").format(
                                    license.name
                                ),
                                true
                            )
                            dt.draw()
                        },
                        error => {}
                    )
                }
            )
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av

            return [
                {
                    title: __("Name"),
                    data: "me.license_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/licenses/' +
                            row.license_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.license_id})`) +
                            "</a>"
                        )
                    },
                },
                {
                    title: __("Vendor"),
                    data: "vendor_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.vendor_id != undefined
                            ? '<a href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=' +
                                  row.vendor_id +
                                  '">' +
                                  escape_str(row.vendor.name) +
                                  "</a>"
                            : ""
                    },
                },

                {
                    title: __("Description"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Type"),
                    data: "type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_license_types", row.type)
                        )
                    },
                },
                {
                    title: __("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_license_statuses", row.status)
                        )
                    },
                },
                {
                    title: __("Started on"),
                    data: "started_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.started_on)
                    },
                },
                {
                    title: __("Ended on"),
                    data: "ended_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.ended_on)
                    },
                },
            ]
        },
    },
    props: {
        av_license_types: Array,
        av_license_statuses: Array,
    },
    components: { Toolbar, KohaTable },
    name: "LicensesList",
}
</script>
