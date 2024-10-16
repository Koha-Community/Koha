<template>
    <div id="vendor_baskets">
        <div v-if="parseInt(basketCount) > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @addToBasket="addToBasket"
                @closeBasket="closeBasket"
                @uncertainPrices="uncertainPrices"
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
        const patronToHTML = $patron_to_html;
        const formatDate = $date;

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
            patronToHTML,
            formatDate,
        };
    },
    data() {
        return {
            fp_config: flatpickr_defaults,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: { embed: "orders,creator,basket_group" },
                url: () => this.tableURL(),
                add_filters: true,
                actions: {
                    "-1": [
                        {
                            addToBasket: {
                                text: this.$__("Add to basket"),
                                icon: "fa fa-plus",
                            },
                        },
                        {
                            closeBasket: {
                                text: this.$__("Close basket"),
                                icon: "fa fa-close",
                                should_display: row =>
                                    row.orders.length > 0 && !row.standing,
                            },
                        },
                        {
                            uncertainPrices: {
                                text: this.$__("Uncertain prices"),
                                icon: "fa fa-question",
                                should_display: row =>
                                    row.orders.filter(o => o.uncertain_price)
                                        .length > 0,
                            },
                        },
                    ],
                },
            },
        };
    },
    methods: {
        addToBasket({ basket_id }, dt, event) {
            event.preventDefault();
            location.href =
                "/cgi-bin/koha/acqui/basket.pl?basketno=" + basket_id;
        },
        closeBasket({ basket_id }, dt, event) {
            event.preventDefault();
            location.href =
                "/cgi-bin/koha/acqui/basket.pl?basketno=" + basket_id;
        },
        uncertainPrices({ basket_id }, dt, event) {
            event.preventDefault();
            location.href =
                "/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=" +
                basket_id +
                "&owner=1";
        },
        tableURL() {
            let url =
                "/api/v1/acquisitions/baskets?q=" +
                JSON.stringify({ "me.vendor_id": this.vendorId });
            return url;
        },
        getTableColumns() {
            const escape_str = this.escape_str;
            const patronToHTML = this.patronToHTML;
            const formatDate = this.formatDate;

            return [
                {
                    title: __("Name"),
                    data: "me.name:me.basket_id",
                    searchable: true,
                    orderable: true,
                    render(data, type, row, meta) {
                        const name = row.name ? row.name : __("Unnamed basket");
                        return (
                            '<a href="/cgi-bin/koha/acqui/basket.pl?basketno=' +
                            row.basket_id +
                            '" class="show">' +
                            escape_str(`${name} (#${row.basket_id})`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Item count"),
                    data: "name",
                    searchable: false,
                    orderable: true,

                    render(data, type, row, meta) {
                        let count = row.orders.length;
                        const cancelledOrders = row.orders.filter(
                            o => o.status == "cancelled"
                        ).length;
                        if (cancelledOrders) {
                            count +=
                                " (" + cancelledOrders + __(" cancelled") + ")";
                        }
                        return count;
                    },
                },
                {
                    title: __("Bibliographic record count"),
                    data: "name",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        const recordCount = row.orders.reduce(
                            (acc, order) => {
                                if (
                                    !acc.cancelledBibs.includes(
                                        order.biblio_id
                                    ) &&
                                    order.status == "cancelled"
                                ) {
                                    acc.cancelledBibs.push(order.biblio_id);
                                }
                                if (acc.bibNumbers.includes(order.biblio_id)) {
                                    return acc;
                                }
                                acc.bibNumbers.push(order.biblio_id);
                                return acc;
                            },
                            {
                                bibNumbers: [],
                                cancelledBibs: [],
                            }
                        );
                        let count = recordCount.bibNumbers.length;
                        if (recordCount.cancelledBibs.length) {
                            count +=
                                " (" +
                                recordCount.cancelledBibs.length +
                                __(" cancelled") +
                                ")";
                        }
                        return count;
                    },
                },
                {
                    title: __("Items expected"),
                    data: "name",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        return row.orders.filter(
                            o => !o.date_received && !o.cancellation_date
                        ).length;
                    },
                },
                {
                    title: __("Created by"),
                    data: "creator_id",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        return patronToHTML(row.creator);
                    },
                },
                {
                    title: __("Date"),
                    data: "creation_date",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        return formatDate(row.creation_date);
                    },
                },
                {
                    title: __("Basket group"),
                    data: "basket_group_id",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        return row.basket_group ? row.basket_group.name : "";
                    },
                },
                {
                    title: __("Internal note"),
                    data: "note",
                    searchable: false,
                    orderable: true,
                },
                {
                    title: __("Closed"),
                    data: "close_date",
                    searchable: false,
                    orderable: true,
                    render(data, type, row, meta) {
                        return formatDate(row.close_date);
                    },
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
