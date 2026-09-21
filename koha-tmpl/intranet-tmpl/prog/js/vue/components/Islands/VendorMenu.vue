<template>
    <div id="vendor-menu" class="sidebar_menu icon-collapse" v-if="vendorId">
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
                    :title="$__('Baskets')"
                    ><i
                        class="fa-solid fa-basket-shopping fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{ $__("Baskets") }}</span></a
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
                    :title="$__('Basket groups')"
                    ><i
                        class="fa-solid fa-layer-group fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("Basket groups")
                    }}</span></a
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
                    :title="$__('Contracts')"
                    ><i
                        class="fa-solid fa-file-signature fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{ $__("Contracts") }}</span></a
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
                    :title="$__('Vendor issues')"
                    ><i
                        class="fa-solid fa-triangle-exclamation fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("Vendor issues")
                    }}</span></a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    :href="`/cgi-bin/koha/acqui/invoices.pl?supplierid=${vendorId}`"
                    :title="$__('Invoices')"
                    ><i
                        class="fa-solid fa-file-invoice-dollar fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{ $__("Invoices") }}</span></a
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
                    :title="$__('Uncertain prices')"
                    ><i
                        class="fa-solid fa-question fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("Uncertain prices")
                    }}</span></a
                >
                <a
                    v-else
                    :ref="el => templateRefs.push(el)"
                    :href="`/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=${vendorId}&amp;owner=1`"
                    :title="$__('Uncertain prices')"
                    ><i
                        class="fa-solid fa-question fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("Uncertain prices")
                    }}</span></a
                >
            </li>
            <li v-if="ermModule && (erm || isUserPermitted('CAN_user_erm'))">
                <a
                    :href="`/cgi-bin/koha/erm/agreements?vendor_id=${vendorId}`"
                    :title="$__('ERM agreements')"
                    ><i
                        class="fa-solid fa-file-contract fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("ERM agreements")
                    }}</span></a
                >
            </li>
            <li v-if="ermModule && (erm || isUserPermitted('CAN_user_erm'))">
                <a
                    :href="`/cgi-bin/koha/erm/licenses?vendor_id=${vendorId}`"
                    :title="$__('ERM licenses')"
                    ><i
                        class="fa-solid fa-file-shield fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{ $__("ERM licenses") }}</span></a
                >
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
