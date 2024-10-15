<template>
    <div id="vendor_baskets">
        <div v-if="parseInt(basketCount) > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="doShow"
                @edit="doEdit"
                @delete="doDelete"
                @select="doSelect"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no baskets defined") }}
        </div>
    </div>
</template>

<script>
import { inject, ref } from "vue";
import { storeToRefs } from "pinia";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = ref();

        return {
            vendors,
            table,
            setConfirmationDialog,
            setMessage,
            escape_str,
        };
    },
    data() {
        return {
            fp_config: flatpickr_defaults,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.tableURL(),
                add_filters: true,
                // filters_options: {
                //     1: [
                //         { _id: 0, _str: this.$__("Inactive") },
                //         { _id: 1, _str: this.$__("Active") },
                //     ],
                //     ...(this.map_av_dt_filter("vendor_types").length && {
                //         2: () => this.map_av_dt_filter("vendor_types"),
                //     }),
                // },
                actions: {
                    "-1": ["edit", "delete"],
                },
            },
            before_route_entered: false,
            building_table: false,
        };
    },
    methods: {
        doShow({ id }, dt, event) {
            event.preventDefault();
            this.$router.push({
                name: "VendorShow",
                params: { vendor_id: id },
            });
        },
        doEdit({ id }, dt, event) {
            this.$router.push({
                name: "VendorFormAddEdit",
                params: { vendor_id: id },
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
            let url =
                "/api/v1/acquisitions/baskets?q=" +
                JSON.stringify({ vendor_id: this.vendorId });
            return url;
        },
        getTableColumns() {
            const escape_str = this.escape_str;
            const get_lib_from_av = this.get_lib_from_av;

            return [
                {
                    title: __("Name"),
                    data: "me.name:me.basket_id",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/acqui/basket.pl?basket_id=' +
                            row.basket_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.basket_id})`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Item count"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return escape_str(row.name);
                    },
                },
                {
                    title: __("Bibliographic record count"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return escape_str(row.name);
                    },
                },
                {
                    title: __("Items expected"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        return escape_str(row.name);
                    },
                },
                {
                    title: __("Created by"),
                    data: "creator_id",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Date"),
                    data: "creation_date",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Basket group"),
                    data: "basket_group_id",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Internal note"),
                    data: "note",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Close"),
                    data: "close_date",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
    },
    components: { KohaTable },
    props: {
        basketCount: {
            type: String,
            default: "0",
        },
        vendorId: {
            type: Number,
        },
    },
    name: "VendorBaskets",
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
