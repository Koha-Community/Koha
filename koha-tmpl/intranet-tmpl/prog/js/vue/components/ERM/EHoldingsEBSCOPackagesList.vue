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
                    v-for="type in authorisedValues.av_package_content_types"
                    :key="type.value"
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
import { inject, ref, reactive, computed, useTemplateRef } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import { build_url_params, build_url } from "../../composables/datatables";
import KohaTable from "../KohaTable.vue";
import { useRoute, useRouter } from "vue-router";
import { $__ } from "@k/i18n";

export default {
    setup() {
        const route = useRoute();
        const router = useRouter();
        const ERMStore = inject("ERMStore");
        const { config, get_lib_from_av, map_av_dt_filter } = ERMStore;
        const { authorisedValues } = storeToRefs(ERMStore);

        const table = useTemplateRef("table");
        const filters = reactive({
            package_name: route.query.package_name || "",
            content_type: route.query.content_type || "",
            selection_type: route.query.selection_type || "",
        });
        const packages = ref([]);
        const initialized = ref(false);
        const local_count_packages = ref(null);
        const show_table = ref(
            build_url_params(filters.value).length ? true : false
        );

        const getTableColumns = () => {
            let get_lib_from_av = get_lib_from_av;
            let escape_str = escape_str;

            return [
                {
                    title: $__("Name"),
                    data: "me.package_id:me.name",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let node =
                            '<a href="/cgi-bin/koha/erm/eholdings/ebsco/packages/' +
                            row.package_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.package_id})`) +
                            "</a>";
                        if (row.is_selected) {
                            node +=
                                " " +
                                '<i class="fa fa-check-square" style="color: green; float: right;" title="' +
                                $__("Is selected") +
                                '" />';
                        }
                        return node;
                    },
                },
                {
                    title: $__("Vendor"),
                    data: "vendor_id",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return row.vendor ? escape_str(row.vendor.name) : "";
                    },
                },
                {
                    title: $__("Type"),
                    data: "package_type",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_types",
                                row.package_type
                            )
                        );
                    },
                },
                {
                    title: $__("Content type"),
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_content_types",
                                row.content_type
                            )
                        );
                    },
                },
            ];
        };
        const tableOptions = ref({
            columns: getTableColumns(),
            url: "/api/v1/erm/eholdings/ebsco/packages",
            options: {
                embed: "resources+count,vendor.name",
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                lengthMenu: [
                    [10, 20, 50, 100],
                    [10, 20, 50, 100],
                ],
            },
            table_settings: eholdings_titles_table_settings,
            actions: { 0: ["show"] },
            default_filters: {
                name: function () {
                    return filters.value.package_name || "";
                },
                content_type: function () {
                    return filters.value.content_type || "";
                },
                selection_type: function () {
                    return filters.value.selection_type || "";
                },
            },
        });
        const local_packages_url = computed(() => {
            let { href } = router.resolve({
                name: "EHoldingsLocalPackagesList",
            });
            return build_url(href, filters.value);
        });

        const filter_table = async () => {
            let { href } = router.resolve({
                name: "EHoldingsEBSCOPackagesList",
            });
            let new_route = build_url(href, filters.value);
            router.push(new_route);
            show_table.value = true;
            local_count_packages.value = null;

            if (config.settings.ERMProviders.includes("local")) {
                const client = APIClient.erm;
                const query = filters.value
                    ? {
                          "me.name": {
                              like: "%" + filters.value.package_name + "%",
                          },
                          ...(filters.value.content_type
                              ? {
                                    "me.content_type":
                                        filters.value.content_type,
                                }
                              : {}),
                      }
                    : {};
                client.localPackages.count(query).then(
                    count => (local_count_packages.value = count),
                    error => {}
                );
            }

            if (table.value) {
                table.value.redraw("/api/v1/erm/eholdings/ebsco/packages");
            }
        };

        const doShow = ({ package_id }, dt, event) => {
            event.preventDefault();
            router.push({
                name: "EHoldingsEBSCOPackagesShow",
                params: { package_id },
            });
        };

        return {
            get_lib_from_av,
            escape_str,
            map_av_dt_filter,
            config,
            table,
            authorisedValues,
            filters,
            packages,
            initialized,
            local_count_packages,
            show_table,
            tableOptions,
            local_packages_url,
            filter_table,
            doShow,
        };
    },
    components: { KohaTable },
    name: "EHoldingsEBSCOPackagesList",
};
</script>
