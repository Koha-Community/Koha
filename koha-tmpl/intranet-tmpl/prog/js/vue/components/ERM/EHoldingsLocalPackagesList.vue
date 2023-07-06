<template>
    <div>
        <div v-if="!initialized">{{ $__("Loading") }}</div>
        <div v-else id="packages_list">
            <Toolbar :options="this.toolbar_options" />
            <div
                v-if="package_count > 0"
                id="package_list_result"
                class="page-section"
            >
                <KohaTable
                    ref="table"
                    v-bind="tableOptions"
                    @show="doShow"
                    @edit="doEdit"
                    @delete="doDelete"
                ></KohaTable>
            </div>
            <div v-else class="dialog message">
                {{ $__("There are no packages defined") }}
            </div>
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue"
import { inject, ref, reactive } from "vue"
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
        const filters = reactive({
            package_name: "",
            content_type: "",
        })

        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            table,
            filters,
            setConfirmationDialog,
            setMessage,
            escape_str,
            eholdings_packages_table_settings,
        }
    },
    data: function () {
        this.filters = {
            package_name: this.$route.query.package_name || "",
            content_type: this.$route.query.content_type || "",
        }
        let filters = this.filters
        return {
            package_count: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/eholdings/local/packages",
                options: {
                    embed: "resources+count,vendor.name",
                    searchCols: [
                        { search: filters.package_name },
                        null,
                        null,
                        { search: filters.content_type },
                        null,
                        null,
                    ],
                },
                table_settings: this.eholdings_packages_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"]
                            e["_str"] = e["name"]
                            return e
                        }),
                    2: () => this.map_av_dt_filter("av_package_types"),
                    3: () => this.map_av_dt_filter("av_package_content_types"),
                },
                actions: {
                    0: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
            toolbar_options: [
                {
                    to: "EHoldingsLocalPackagesFormAdd",
                    icon: "plus",
                    button_title: this.$__("New package"),
                },
            ],
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackageCount().then(() => (vm.initialized = true))
        })
    },
    methods: {
        async getPackageCount() {
            const client = APIClient.erm
            await client.localPackages.count().then(
                count => {
                    this.package_count = count
                },
                error => {}
            )
        },
        doShow: function ({ package_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsLocalPackagesShow",
                params: { package_id },
            })
        },
        doEdit: function ({ package_id }, dt, event) {
            this.$router.push({
                name: "EHoldingsLocalPackagesFormAddEdit",
                params: { package_id },
            })
        },
        doDelete: function (erm_package, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this package?"
                    ),
                    message: erm_package.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm
                    client.localPackages.delete(erm_package.package_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Local package %s deleted").format(
                                    erm_package.name
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
            let escape_str = this.escape_str
            return [
                {
                    title: __("Name"),
                    data: "me.name:me.package_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eholdings/local/packages/' +
                            row.package_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.package_id})`) +
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
                    title: __("Type"),
                    data: "package_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_types",
                                row.package_type
                            )
                        )
                    },
                },
                {
                    title: __("Content type"),
                    data: "content_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_content_types",
                                row.content_type
                            )
                        )
                    },
                },
                {
                    title: __("Created on"),
                    data: "created_on",
                    searchable: false,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.created_on)
                    },
                },
                {
                    title: __("Notes"),
                    data: "notes",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.notes
                    },
                },
            ]
        },
    },
    components: { Toolbar, KohaTable },
    name: "EHoldingsLocalPackagesList",
}
</script>
