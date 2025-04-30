<template>
    <div id="vendor-menu" class="sidebar_menu" v-if="vendorId">
        <ul>
            <li
                v-if="
                    ordermanage ||
                    isUserPermitted('CAN_user_acquisition_order_manage')
                "
            >
                <a
                    ref="booksellers"
                    :href="`/cgi-bin/koha/acqui/booksellers.pl?booksellerid=${vendorId}`"
                    >{{ $__("Baskets") }}</a
                >
            </li>
            <li
                v-if="
                    groupmanage ||
                    isUserPermitted('CAN_user_acquisition_group_manage')
                "
            >
                <a
                    ref="basketgroup"
                    :href="`/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=${vendorId}`"
                    >{{ $__("Basket groups") }}</a
                >
            </li>
            <li
                v-if="
                    contractsmanage ||
                    isUserPermitted('CAN_user_acquisition_contracts_manage')
                "
            >
                <a
                    ref="aqcontract"
                    :href="`/cgi-bin/koha/admin/aqcontract.pl?booksellerid=${vendorId}`"
                    >{{ $__("Contracts") }}</a
                >
            </li>
            <li
                v-if="
                    issuemanage ||
                    isUserPermitted('CAN_user_acquisition_issue_manage')
                "
            >
                <a
                    ref="vendor_issues"
                    :href="`/cgi-bin/koha/acqui/vendor_issues.pl?booksellerid=${vendorId}`"
                    >{{ $__("Vendor issues") }}</a
                >
            </li>
            <li>
                <a
                    ref="invoices"
                    :href="`/cgi-bin/koha/acqui/invoices.pl?supplierid=${vendorId}`"
                    >{{ $__("Invoices") }}</a
                >
            </li>
            <li
                v-if="
                    ordermanage ||
                    isUserPermitted('CAN_user_acquisition_order_manage')
                "
            >
                <a
                    v-if="basketno"
                    ref="uncertainprice"
                    :href="`/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=${vendorId}&amp;basketno=${basketno}&amp;owner=1`"
                    >{{ $__("Uncertain prices") }}</a
                >
                <a
                    v-else
                    ref="uncertainprice"
                    :href="`/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=${vendorId}&amp;owner=1`"
                    >{{ $__("Uncertain prices") }}</a
                >
            </li>
        </ul>
    </div>
</template>

<script>
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    props: {
        vendorid: {
            type: String,
        },
        basketno: {
            type: String,
        },
        ordermanage: {
            type: String,
        },
        groupmanage: {
            type: String,
        },
        contractsmanage: {
            type: String,
        },
        issuemanage: {
            type: String,
        },
    },
    setup() {
        const permissionsStore = inject("permissionsStore");
        const { isUserPermitted } = permissionsStore;
        const navigationStore = inject("navigationStore");
        const { params } = storeToRefs(navigationStore);

        return {
            isUserPermitted,
            params,
        };
    },
    data() {
        const vendorId = this.vendorid || this.params.id;
        return {
            vendorId,
        };
    },
    mounted() {
        const path = location.pathname.substring(1);

        Object.values(this.$refs)
            .find(a => a.href.includes(path))
            ?.classList.add("current");
    },
};
</script>

<style></style>
