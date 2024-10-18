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
                    :ref="el => templateRefs.push(el)"
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
                    :ref="el => templateRefs.push(el)"
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
                    :ref="el => templateRefs.push(el)"
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
                    :ref="el => templateRefs.push(el)"
                    :href="`/cgi-bin/koha/acqui/vendor_issues.pl?booksellerid=${vendorId}`"
                    >{{ $__("Vendor issues") }}</a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
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
                    :ref="el => templateRefs.push(el)"
                    :href="`/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=${vendorId}&amp;basketno=${basketno}&amp;owner=1`"
                    >{{ $__("Uncertain prices") }}</a
                >
                <a
                    v-else
                    :ref="el => templateRefs.push(el)"
                    :href="`/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=${vendorId}&amp;owner=1`"
                    >{{ $__("Uncertain prices") }}</a
                >
            </li>
            <li v-if="ermModule && (erm || isUserPermitted('CAN_user_erm'))">
                <a
                    :href="`/cgi-bin/koha/erm/agreements?vendor_id=${vendorId}`"
                    >{{ $__("ERM agreements") }}</a
                >
            </li>
            <li v-if="ermModule && (erm || isUserPermitted('CAN_user_erm'))">
                <a :href="`/cgi-bin/koha/erm/licenses?vendor_id=${vendorId}`">{{
                    $__("ERM licenses")
                }}</a>
            </li>
        </ul>
    </div>
</template>

<script>
import { inject, onMounted, ref } from "vue";
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
        ermmodule: {
            type: String,
        },
        erm: {
            type: String,
        },
    },
    setup(props) {
        const vendorStore = inject("vendorStore");
        const { isUserPermitted, config } = vendorStore;
        const navigationStore = inject("navigationStore");
        const { params } = storeToRefs(navigationStore);

        const vendorId = ref(props.vendorid || params.value.id);
        const ermModule = props.ermmodule
            ? props.ermmodule
            : config.settings.ermModule;
        const templateRefs = ref([]);

        onMounted(() => {
            const path = location.pathname.substring(1);

            templateRefs.value
                .find(a => a.href.includes(path))
                ?.classList.add("current");
        });
        return {
            isUserPermitted,
            params,
            config,
            ermModule,
            vendorId,
            templateRefs,
        };
    },
};
</script>

<style></style>
