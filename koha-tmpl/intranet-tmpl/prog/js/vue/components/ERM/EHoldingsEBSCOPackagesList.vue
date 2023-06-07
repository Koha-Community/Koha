<template>
    <div>
        <fieldset>
            {{ $__("Package name") }}:
            <input
                type="text"
                id="package_name_filter"
                v-model="filters.package_name"
                @keyup.enter="filter_table"
            />
            {{ $__("Content type") }}:
            <select id="content_type_filter" v-model="filters.content_type">
                <option value="">{{ $__("All") }}</option>
                <option
                    v-for="type in av_package_content_types"
                    :key="type.authorised_values"
                    :value="type.value"
                >
                    {{ type.description }}
                </option>
            </select>
            {{ $__("Selection status") }}:
            <select id="selection_type_filter" v-model="filters.selection_type">
                <option value="0">{{ $__("All") }}</option>
                <option value="1">{{ $__("Selected") }}</option>
                <option value="2">{{ $__("Not selected") }}</option>
            </select>
            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$__('Submit')"
            />
        </fieldset>

        <!-- We need to display the table element to initiate DataTable -->
        <div
            id="package_list_result"
            :style="show_table ? 'display: block' : 'display: none'"
        >
            <div
                v-if="
                    local_count_packages !== undefined &&
                    local_count_packages !== null
                "
            >
                <router-link :to="local_packages_url">
                    {{
                        $__("%s packages found locally").format(
                            local_count_packages
                        )
                    }}</router-link
                >
            </div>
            <div id="package_list_result" class="page-section">
                <KohaTable
                    v-if="show_table"
                    ref="table"
                    v-bind="tableOptions"
                    @show="doShow"
                ></KohaTable>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, reactive } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"
import { build_url_params, build_url } from "../../composables/datatables"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const { av_package_types, av_package_content_types } =
            storeToRefs(AVStore)
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const ERMStore = inject("ERMStore")
        const { sysprefs } = ERMStore

        const table = ref()
        const filters = reactive({
            package_name: "",
            content_type: "",
            selection_type: "",
        })

        return {
            vendors,
            av_package_types,
            av_package_content_types,
            get_lib_from_av,
            escape_str,
            map_av_dt_filter,
            sysprefs,
            table,
        }
    },
    data: function () {
        this.filters = {
            package_name: this.$route.query.package_name || "",
            content_type: this.$route.query.content_type || "",
            selection_type: this.$route.query.selection_type || "",
        }
        let filters = this.filters

        return {
            packages: [],
            initialized: true,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/eholdings/ebsco/packages",
                options: {
                    embed: "resources+count,vendor.name",
                    ordering: false,
                    dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                    aLengthMenu: [
                        [10, 20, 50, 100],
                        [10, 20, 50, 100],
                    ],
                },
                table_settings: this.eholdings_titles_table_settings,
                actions: { 0: ["show"] },
                default_filters: {
                    name: function () {
                        return filters.package_name || ""
                    },
                    content_type: function () {
                        return filters.content_type || ""
                    },
                    selection_type: function () {
                        return filters.selection_type || ""
                    },
                },
            },
            show_table: build_url_params(filters).length ? true : false,
            local_count_packages: null,
        }
    },
    computed: {
        local_packages_url() {
            let { href } = this.$router.resolve({
                name: "EHoldingsLocalPackagesList",
            })
            return build_url(href, this.filters)
        },
    },
    methods: {
        doShow: function ({ package_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsEBSCOPackagesShow",
                params: { package_id },
            })
        },
        filter_table: async function () {
            let { href } = this.$router.resolve({
                name: "EHoldingsEBSCOPackagesList",
            })
            let new_route = build_url(href, this.filters)
            this.$router.push(new_route)
            this.show_table = true
            this.local_count_packages = null

            if (this.sysprefs.ERMProviders.includes("local")) {
                const client = APIClient.erm
                const query = this.filters
                    ? {
                          "me.name": {
                              like: "%" + this.filters.package_name + "%",
                          },
                          ...(this.filters.content_type
                              ? { "me.content_type": this.filters.content_type }
                              : {}),
                      }
                    : {}
                client.localPackages.count(query).then(
                    count => (this.local_count_packages = count),
                    error => {}
                )
            }

            if (this.$refs.table) {
                this.$refs.table.redraw("/api/v1/erm/eholdings/ebsco/packages")
            }
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let escape_str = this.escape_str

            return [
                {
                    title: __("Name"),
                    data: "me.package_id:me.name",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let node =
                            '<a href="/cgi-bin/koha/erm/eholdings/ebsco/packages/' +
                            row.package_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.package_id})`) +
                            "</a>"
                        if (row.is_selected) {
                            node +=
                                " " +
                                '<i class="fa fa-check-square-o" style="color: green; float: right;" title="' +
                                __("Is selected") +
                                '" />'
                        }
                        return node
                    },
                },
                {
                    title: __("Vendor"),
                    data: "vendor_id",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return row.vendor ? escape_str(row.vendor.name) : ""
                    },
                },
                {
                    title: __("Type"),
                    data: "package_type",
                    searchable: false,
                    orderable: false,
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
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_content_types",
                                row.content_type
                            )
                        )
                    },
                },
            ]
        },
    },
    components: { KohaTable },
    name: "EHoldingsEBSCOPackagesList",
}
</script>
