<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="vendors_list">
        <Toolbar>
            <ToolbarButton
                :to="{ name: 'VendorFormAdd' }"
                icon="plus"
                :title="$__('New vendor')"
            />
        </Toolbar>
        <div v-if="vendor_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="doShow"
                @edit="doEdit"
                @delete="doDelete"
                @select="doSelect"
                @receive="doReceive"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no vendors defined") }}
        </div>
    </div>
</template>

<script>
import flatPickr from "vue-flatpickr-component";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { storeToRefs } from "pinia";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);
        const { get_lib_from_av, map_av_dt_filter } = vendorStore;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = ref();

        const permissionsStore = inject("permissionsStore");
        const { isUserPermitted } = permissionsStore;

        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            table,
            setConfirmationDialog,
            setMessage,
            escape_str,
            isUserPermitted,
            vendorTableSettings,
        };
    },
    data() {
        return {
            fp_config: flatpickr_defaults,
            vendor_count: 0,
            initialized: false,
            searchTerm: null,
            tableOptions: {
                columns: this.getTableColumns(),
                options: {
                    embed: "aliases,baskets+count,subscriptions+count,invoices+count",
                },
                url: () => this.tableURL(),
                table_settings: this.vendorTableSettings,
                add_filters: true,
                filters_options: {
                    1: [
                        { _id: 0, _str: this.$__("Inactive") },
                        { _id: 1, _str: this.$__("Active") },
                    ],
                    ...(this.map_av_dt_filter("av_vendor_types").length && {
                        2: () => this.map_av_dt_filter("av_vendor_types"),
                    }),
                },
                actions: {
                    0: ["show"],
                    "-1": [
                        "edit",
                        {
                            delete: {
                                text: this.$__("Delete"),
                                icon: "fa fa-trash",
                                should_display: row =>
                                    row.baskets_count === 0 &&
                                    row.subscriptions_count === 0 &&
                                    row.invoices_count === 0,
                            },
                        },
                        {
                            receive: {
                                text: this.$__("Receive shipments"),
                                icon: "fa fa-inbox",
                                should_display: row =>
                                    row.active &&
                                    row.baskets_count > 0 &&
                                    this.isUserPermitted(
                                        "CAN_user_acquisition_order_receive"
                                    ),
                            },
                        },
                    ],
                },
            },
            before_route_entered: false,
            building_table: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getVendorCount().then(() => (vm.initialized = true));
            if (to.query.supplier) {
                vm.searchTerm = to.query.supplier;
            }
        });
    },
    methods: {
        async getVendorCount() {
            const client = APIClient.acquisition;
            await client.vendors.count().then(
                count => {
                    this.vendor_count = count;
                },
                error => {}
            );
        },
        doShow({ id }, dt, event) {
            event.preventDefault();
            this.$router.push({
                name: "VendorShow",
                params: { id: id },
            });
        },
        doReceive({ id }, dt, event) {
            event.preventDefault();
            window.open(`/cgi-bin/koha/acqui/parcels.pl?booksellerid=${id}`);
        },
        doEdit({ id }, dt, event) {
            this.$router.push({
                name: "VendorFormAddEdit",
                params: { id: id },
            });
        },
        doDelete(vendor, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this vendor?"
                    ),
                    message: vendor.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.acquisition;
                    client.vendors.delete(vendor.id).then(
                        success => {
                            this.setMessage(
                                this.$__("Vendor %s deleted").format(
                                    vendor.name
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
        doSelect(vendor, dt, event) {
            this.$emit("select-vendor", vendor.id);
            this.$emit("close");
        },
        tableURL() {
            let url = "/api/v1/acquisitions/vendors";
            if (this.searchTerm) {
                url += "?name=" + this.searchTerm;
            }
            return url;
        },
        getTableColumns() {
            const escape_str = this.escape_str;
            const get_lib_from_av = this.get_lib_from_av;

            return [
                {
                    title: __("Name"),
                    data: "me.name:aliases.alias:me.id",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/acquisition/vendors/' +
                            row.id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.id})`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Status"),
                    data: "active",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return escape_str(
                            row.active ? __("Active") : __("Inactive")
                        );
                    },
                },
                {
                    title: __("Type"),
                    data: "type",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return get_lib_from_av("av_vendor_types", row.type);
                    },
                },
                {
                    title: __("Invoice currency"),
                    data: "invoice_currency",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Baskets"),
                    data: "baskets",
                    searchable: false,
                    orderable: false,
                    render(data, type, row, meta) {
                        return row.baskets_count
                            ? '<a href="/cgi-bin/koha/acqui/booksellers.pl?booksellerid=' +
                                  row.id +
                                  '" class="show">' +
                                  escape_str(
                                      __("%s basket(s)").format(
                                          row.baskets_count
                                      )
                                  ) +
                                  "</a>"
                            : escape_str(__("No baskets"));
                    },
                },
                {
                    title: __("Subscriptions"),
                    data: "subscriptions",
                    searchable: false,
                    orderable: false,
                    render(data, type, row, meta) {
                        return row.subscriptions_count
                            ? '<a href="/cgi-bin/koha/serials/serials-search.pl?bookseller_filter=' +
                                  escape_str(row.name) +
                                  "&searched=1" +
                                  '" class="show">' +
                                  escape_str(
                                      __("%s subscription(s)").format(
                                          row.subscriptions_count
                                      )
                                  ) +
                                  "</a>"
                            : escape_str(__("No subscriptions"));
                    },
                },
            ];
        },
    },
    components: { flatPickr, Toolbar, ToolbarButton, KohaTable },
    name: "VendorList",
    emits: ["select-vendor", "close"],
};
</script>

<style scoped>
.filters > label[for="by_mine_filter"],
.filters > input[type="checkbox"],
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
