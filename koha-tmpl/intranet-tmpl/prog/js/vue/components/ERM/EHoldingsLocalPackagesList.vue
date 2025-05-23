<template>
    <div>
        <div v-if="!initialized">{{ $__("Loading") }}</div>
        <div v-else id="packages_list">
            <Toolbar>
                <ToolbarButton
                    :to="{ name: 'EHoldingsLocalPackagesFormAdd' }"
                    icon="plus"
                    :title="$__('New package')"
                />
            </Toolbar>
            <div
                v-if="package_count > 0"
                id="package_list_result"
                class="page-section"
            >
                <KohaTable
                    ref="table"
                    v-bind="tableOptions"
                    :searchable_additional_fields="searchable_additional_fields"
                    :searchable_av_options="searchable_av_options"
                    @show="doShow"
                    @edit="doEdit"
                    @delete="doDelete"
                ></KohaTable>
            </div>
            <div v-else class="alert alert-info">
                {{ $__("There are no packages defined") }}
            </div>
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref, reactive } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const ERMStore = inject("ERMStore");
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = ref();
        const filters = reactive({
            package_name: "",
            content_type: "",
        });

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
        };
    },
    data: function () {
        this.filters = {
            package_name: this.$route.query.package_name || "",
            content_type: this.$route.query.content_type || "",
        };
        let filters = this.filters;
        return {
            package_count: 0,
            initialized: false,
            searchable_additional_fields: [],
            searchable_av_options: [],
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/eholdings/local/packages",
                options: {
                    embed: "resources+count,vendor.name,extended_attributes,+strings",
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
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    2: () => this.map_av_dt_filter("av_package_types"),
                    3: () => this.map_av_dt_filter("av_package_content_types"),
                },
                actions: {
                    0: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackageCount().then(() =>
                vm
                    .getSearchableAdditionalFields()
                    .then(() =>
                        vm
                            .getSearchableAVOptions()
                            .then(() => (vm.initialized = true))
                    )
            );
        });
    },
    methods: {
        async getPackageCount() {
            const client = APIClient.erm;
            await client.localPackages.count().then(
                count => {
                    this.package_count = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields.getAll("package").then(
                searchable_additional_fields => {
                    this.searchable_additional_fields =
                        searchable_additional_fields.filter(
                            field => field.searchable
                        );
                },
                error => {}
            );
        },
        async getSearchableAVOptions() {
            const client_av = APIClient.authorised_values;
            let av_cat_array = this.searchable_additional_fields
                .filter(field => field.authorised_value_category_name)
                .map(field => field.authorised_value_category_name);

            await client_av.values
                .getCategoriesWithValues([
                    ...new Set(av_cat_array.map(av_cat => '"' + av_cat + '"')),
                ]) // unique
                .then(av_categories => {
                    av_cat_array.forEach(av_cat => {
                        let av_match = av_categories.find(
                            element => element.category_name == av_cat
                        );
                        this.searchable_av_options[av_cat] =
                            av_match.authorised_values.map(av => ({
                                value: av.value,
                                label: av.description,
                            }));
                    });
                });
        },
        doShow: function ({ package_id }, dt, event) {
            event.preventDefault();
            this.$router.push({
                name: "EHoldingsLocalPackagesShow",
                params: { package_id },
            });
        },
        doEdit: function ({ package_id }, dt, event) {
            this.$router.push({
                name: "EHoldingsLocalPackagesFormAddEdit",
                params: { package_id },
            });
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
                    const client = APIClient.erm;
                    client.localPackages.delete(erm_package.package_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Local package %s deleted").format(
                                    erm_package.name
                                ),
                                true
                            );
                            dt.draw();
                        },
                        error => {}
                    );
                }
            );
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av;
            let escape_str = this.escape_str;
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
                        );
                    },
                },
                {
                    title: __("Vendor"),
                    data: "vendor_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.vendor_id != undefined
                            ? '<a href="/cgi-bin/koha/acquisition/vendors/' +
                                  row.vendor_id +
                                  '">' +
                                  escape_str(row.vendor.name) +
                                  "</a>"
                            : "";
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
                        );
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
                        );
                    },
                },
                {
                    title: __("Created on"),
                    data: "created_on",
                    searchable: false,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.created_on);
                    },
                },
                {
                    title: __("Notes"),
                    data: "notes",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.notes;
                    },
                },
            ];
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "EHoldingsLocalPackagesList",
};
</script>
