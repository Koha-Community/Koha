<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="licenses_list">
        <Toolbar>
            <ToolbarButton
                :to="{ name: 'LicensesFormAdd' }"
                icon="plus"
                :title="$__('New license')"
            />
        </Toolbar>
        <div v-if="license_count > 0" class="page-section">
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
            {{ $__("There are no licenses defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref } from "vue";
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

        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            table,
            setConfirmationDialog,
            setMessage,
            license_table_settings,
        };
    },
    data: function () {
        return {
            license_count: 0,
            initialized: false,
            toolbar_options: [
                {
                    to: "LicensesFormAdd",
                    icon: "plus",
                    button_title: this.$__("New license"),
                },
            ],
            searchable_additional_fields: [],
            searchable_av_options: [],
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/licenses",
                options: { embed: "vendor,extended_attributes,+strings" },
                table_settings: this.license_table_settings,
                add_filters: true,
                filters_options: {
                    2: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    4: () => this.map_av_dt_filter("av_license_types"),
                    5: () => this.map_av_dt_filter("av_license_statuses"),
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
            vm.getLicenseCount().then(() =>
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
        async getLicenseCount() {
            const client = APIClient.erm;
            await client.licenses.count().then(
                count => {
                    this.license_count = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields.getAll("license").then(
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
        doShow: function ({ license_id }, dt, event) {
            event.preventDefault();
            this.$router.push({ name: "LicensesShow", params: { license_id } });
        },
        doEdit: function ({ license_id }, dt, event) {
            this.$router.push({
                name: "LicensesFormAddEdit",
                params: { license_id },
            });
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
                    const client = APIClient.erm;
                    client.licenses.delete(license.license_id).then(
                        success => {
                            this.setMessage(
                                this.$__("License %s deleted").format(
                                    license.name
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

            return [
                {
                    title: __("ID"),
                    data: "me.license_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/licenses/' +
                            row.license_id +
                            '" class="show">' +
                            escape_str(`${row.license_id}`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Name"),
                    data: "me.name:me.license_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/licenses/' +
                            row.license_id +
                            '" class="show">' +
                            escape_str(row.name) +
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
                        );
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
                        );
                    },
                },
                {
                    title: __("Started on"),
                    data: "started_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.started_on);
                    },
                },
                {
                    title: __("Ended on"),
                    data: "ended_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.ended_on);
                    },
                },
            ];
        },
    },
    props: {
        av_license_types: Array,
        av_license_statuses: Array,
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "LicensesList",
};
</script>
