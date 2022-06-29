<template>
    <div>
        <fieldset>
            {{ $t("Package name") }}:
            <input
                type="text"
                id="package_name_filter"
                v-model="filters.package_name"
                @keyup.enter="filter_table"
            />
            {{ $t("Content type") }}:
            <select id="content_type_filter" v-model="filters.content_type">
                <option value="">{{ $t("All") }}</option>
                <option
                    v-for="type in av_package_content_types"
                    :key="type.authorised_values"
                    :value="type.authorised_value"
                >
                    {{ type.lib }}
                </option>
            </select>
            {{ $t("Selection status") }}:
            <select id="selection_type_filter" v-model="filters.selection_type">
                <option value="0">{{ $t("All") }}</option>
                <option value="1">{{ $t("Selected") }}</option>
                <option value="2">{{ $t("Not selected") }}</option>
            </select>
            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$t('Submit')"
            />
        </fieldset>
        <div id="package_list_result" style="display: none">
            <table id="package_list"></table>
        </div>
    </div>
</template>

<script>
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = useVendorStore() // FIXME We only need that for 'manual'
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { av_package_types, av_package_content_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        return {
            vendors,
            av_package_types,
            av_package_content_types,
            get_lib_from_av,
        }
    },
    data: function () {
        return {
            packages: [],
            initialized: true,
            filters: {
                package_name: this.$route.query.q || "",
                content_type: "",
                selection_type: "",
            },
        }
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
        filter_table: function () {
            $("#package_list_result").show()
            $("#package_list").DataTable().draw()
        },
        build_datatable: function () {
            let show_package = this.show_package
            let get_lib_from_av = this.get_lib_from_av
            let filters = this.filters

            window['vendors'] = this.vendors.map(e => {
                e['_id'] = e['id']
                e['_str'] = e['name']
                return e
            })
            window['av_package_types'] = this.av_package_types.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })
            window['av_package_content_types'] = this.av_package_content_types.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
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

            $('#package_list').kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/ebsco/packages",
                },
                embed: ['resources+count', 'vendor.name'],
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                aLengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]],
                deferLoading: true,
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
                        let row = api.row(index).data()
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
                            n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green" }, title: __("Is selected") })])
                        }
                        render(n, e)
                    })
                },
            }, eholdings_packages_table_settings, 0, additional_filters)

            if (filters.package_name.length) {
                this.filter_table()
            }
        },
    },
    name: "EHoldingsEBSCOPackagesList",
}
</script>
