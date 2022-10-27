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
                    :value="type.authorised_value"
                >
                    {{ type.lib }}
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
            <div id="package_list_result">
                <table :id="table_id"></table>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, createVNode, render } from 'vue'
import { storeToRefs } from "pinia"
import { fetchCountLocalPackages } from './../../fetch'
import { useDataTable, build_url_params, build_url } from "../../composables/datatables"

export default {
    setup() {
        const vendorStore = inject('vendorStore')
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject('AVStore')
        const { av_package_types, av_package_content_types } = storeToRefs(AVStore)
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const table_id = "package_list"
        useDataTable(table_id)

        return {
            vendors,
            av_package_types,
            av_package_content_types,
            get_lib_from_av,
            map_av_dt_filter,
            erm_providers,
            table_id,
        }
    },
    data: function () {
        return {
            packages: [],
            initialized: true,
            filters: {
                package_name: this.$route.query.package_name || "",
                content_type: this.$route.query.content_type || "",
                selection_type: this.$route.query.selection_type || "",
            },
            show_table: false,
            local_count_packages: null,
        }
    },
    computed: {
        local_packages_url() { return build_url("/cgi-bin/koha/erm/eholdings/local/packages", this.filters) },
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.build_datatable()
        })
    },
    methods: {
        show_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/ebsco/packages/" + package_id)
        },
        filter_table: async function () {
            let new_route = build_url("/cgi-bin/koha/erm/eholdings/ebsco/packages", this.filters)
            this.$router.push(new_route)
            this.show_table = true
            this.local_count_packages = null
            $('#' + this.table_id).DataTable().draw()
            if (this.erm_providers.includes('local')) {
                this.local_count_packages = await fetchCountLocalPackages(this.filters)
            }
        },
        build_datatable: function () {
            let show_package = this.show_package
            let get_lib_from_av = this.get_lib_from_av
            let map_av_dt_filter = this.map_av_dt_filter

            if (!this.show_table) {
                this.show_table = build_url_params(this.filters).length ? true : false
            }
            let filters = this.filters
            let show_table = this.show_table
            let table_id = this.table_id

            window['vendors'] = this.vendors.map(e => {
                e['_id'] = e['id']
                e['_str'] = e['name']
                return e
            })
            let avs = ['av_package_types', 'av_package_content_types']
            avs.forEach(function (av_cat) {
                window[av_cat] = map_av_dt_filter(av_cat)
            })

            let additional_filters = {
                name: function () {
                    return filters.package_name || ""
                },
                content_type: function () {
                    return filters.content_type || ""
                },
                selection_type: function () {
                    return filters.selection_type || ""
                },
            }

            $('#' + table_id).kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/ebsco/packages",
                },
                embed: ['resources+count', 'vendor.name'],
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                aLengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]],
                deferLoading: show_table ? false : true,
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "me.package_id:me.name",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
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
                            return escape_str(get_lib_from_av("av_package_types", row.package_type))
                        }
                    }, {
                        title: __("Content type"),
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_package_content_types", row.content_type))
                        }
                    },
                ],
                drawCallback: function (settings) {

                    var api = new $.fn.dataTable.Api(settings)

                    $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                        let tr = $(this).parent()
                        let row = api.row(tr).data()
                        if (!row) return // Happen if the table is empty
                        let n = createVNode("a", {
                            role: "button",
                            href: "/cgi-bin/koha/erm/eholdings/ebsco/packages/" + row.package_id,
                            onClick: (e) => {
                                e.preventDefault()
                                show_package(row.package_id)
                            }
                        },
                            `${row.name} (#${row.package_id})`
                        )
                        if (row.is_selected) {
                            n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green", float: "right" }, title: __("Is selected") })])
                        }
                        render(n, e)
                    })
                },
            }, null, 0, additional_filters)

            if (filters.package_name.length) {
                this.filter_table()
            }
        },
    },
    name: "EHoldingsEBSCOPackagesList",
}
</script>
