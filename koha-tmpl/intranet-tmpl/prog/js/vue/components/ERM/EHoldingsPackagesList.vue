<template>
    <div v-if="erm_provider == 'manual'">
        <div v-if="!this.initialized">{{ $t("Loading") }}</div>
        <div v-else-if="this.packages" id="packages_list">
            <Toolbar />
            <table v-if="this.packages.length" id="package_list"></table>
            <div v-else-if="this.initialized" class="dialog message">
                {{ $t("There are no packages defined") }}
            </div>
        </div>

        <div id="package_list_result">
            <table id="package_list"></table>
        </div>
    </div>
    <div v-else>
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
import Toolbar from "./EHoldingsPackagesToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchPackages } from "../../fetch"

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
    inject: ['erm_provider'],
    data: function () {
        return {
            packages: [],
            initialized: false,
            filters: {
                package_name: this.$route.query.q || "",
                content_type: "",
                selection_type: "",
            },
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackages()
        })
    },
    methods: {
        async getPackages() {
            if (erm_provider == 'manual') {
                const packages = await fetchPackages()
                this.packages = packages
            }
            this.initialized = true
        },
        show_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/" + package_id)
        },
        edit_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/edit/" + package_id)
        },
        delete_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/delete/" + package_id)
        },
        filter_table: function () {
            $("#package_list_result").show()
            $("#package_list").DataTable().draw()
        }
    },
    updated() {
        let show_package = this.show_package
        let edit_package = this.edit_package
        let delete_package = this.delete_package
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

        let additional_filters = {}
        if (erm_provider != 'manual') {
            additional_filters = {
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
        }

        $('#package_list').kohaTable({
            "ajax": {
                "url": "/api/v1/erm/eholdings/packages",
            },
            "embed": ['resources+count', 'vendor.name'],
            ...(erm_provider == 'manual' ? { order: [[0, "asc"]] } : {}),
            ...(erm_provider != 'manual' ? { ordering: false } : {}),
            ...(erm_provider == 'manual' ? { search: { search: filters.package_name } } : {}),
            ...(erm_provider != 'manual' ? { dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>' } : {}),
            ...(erm_provider != 'manual' ? { lengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]] } : {}),
            ...(erm_provider != 'manual' ? { deferLoading: true } : {}),
            autoWidth: false,
            "columns": [
                {
                    "title": __("Name"),
                    "data": "me.package_id:me.name",
                    "searchable": (erm_provider == 'manual'),
                    "orderable": (erm_provider == 'manul'),
                    "render": function (data, type, row, meta) {
                        // Rendering done in drawCallback
                        return ""
                    }
                },
                {
                    "title": __("Vendor"),
                    "data": "vendor_id",
                    "searchable": (erm_provider == 'manual'),
                    "orderable": (erm_provider == 'manul'),
                    "render": function (data, type, row, meta) {
                        return row.vendor ? escape_str(row.vendor.name) : ""
                    },
                },
                {
                    "title": __("Type"),
                    "data": "package_type",
                    "searchable": (erm_provider == 'manual'),
                    "orderable": (erm_provider == 'manul'),
                    "render": function (data, type, row, meta) {
                        return escape_str(get_lib_from_av("av_package_types", row.package_type))
                    }
                }, {
                    "searchable": (erm_provider == 'manual'),
                    "orderable": (erm_provider == 'manul'),
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return escape_str(get_lib_from_av("av_package_content_types", row.content_type))
                    }
                },
                erm_provider == 'manual' ?
                    {
                        "title": __("Created on"),
                        "data": "created_on",
                        "searchable": true,
                        "orderable": true,
                        "render": function (data, type, row, meta) {
                            return $date(row.created_on)
                        }
                    } : null,
                erm_provider == 'manual' ?
                    {
                        "title": __("Actions"),
                        "data": function (row, type, val, meta) {
                            return '<div class="actions"></div>'
                        },
                        "className": "actions noExport",
                        "searchable": false,
                        "orderable": false
                    } : null,
            ].filter(Boolean),
            drawCallback: function (settings) {

                var api = new $.fn.dataTable.Api(settings)

                $.each($(this).find("td .actions"), function (index, e) {
                    let package_id = api.row(index).data().package_id
                    let editButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            edit_package(package_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                    let deleteButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            delete_package(package_id)
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
                        href: "/cgi-bin/koha/erm/eholdings/packages/" + row.package_id,
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
            ...(erm_provider == 'manual' ? {
                preDrawCallback: function (settings) {
                    var table_id = settings.nTable.id
                    if (erm_provider == 'manual') {
                        $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'vendors')
                    }
                    $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'av_package_types')
                    $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'av_package_content_types')
                }
            } : {}),
        }, eholdings_packages_table_settings, erm_provider == 'manual' ? 1 : 0, additional_filters)

        if (erm_provider != 'manual') {
            if (filters.package_name.length) {
                this.filter_table()
            }
        }
    },
    beforeUnmount() {
        $('#package_list')
            .DataTable()
            .destroy(true)
    },
    components: { Toolbar },
    name: "EHoldingsPackagesList",
}
</script>