<template>
    <div id="acquisitions-menu" class="sidebar_menu icon-collapse">
        <h5>{{ $__("Acquisitions") }}</h5>
        <ul>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/acqui-home.pl"
                    :title="$__('Acquisitions home')"
                    ><i class="fa-solid fa-house fa-fw" aria-hidden="true"></i>
                    <span class="menu-label">{{
                        $__("Acquisitions home")
                    }}</span></a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/histsearch.pl"
                    :title="$__('Advanced search')"
                    ><i
                        class="fa-solid fa-magnifying-glass fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("Advanced search")
                    }}</span></a
                >
            </li>
            <li
                v-if="
                    orderreceive ||
                    isUserPermitted('CAN_user_acquisition_order_receive')
                "
            >
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/lateorders.pl"
                    :title="$__('Late orders')"
                    ><i class="fa-solid fa-clock fa-fw" aria-hidden="true"></i>
                    <span class="menu-label">{{ $__("Late orders") }}</span></a
                >
            </li>
            <li
                v-if="
                    suggestionscreate ||
                    suggestionsmanage ||
                    suggestionsdelete ||
                    isUserPermitted(
                        'CAN_user_suggestions_suggestions_create'
                    ) ||
                    isUserPermitted(
                        'CAN_user_suggestions_suggestions_manage'
                    ) ||
                    isUserPermitted('CAN_user_suggestions_suggestions_delete')
                "
            >
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/suggestion/suggestion.pl"
                    :title="$__('Suggestions')"
                    ><i
                        class="fa-solid fa-lightbulb fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{ $__("Suggestions") }}</span></a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/invoices.pl"
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
                    edifactEnabled &&
                    (edimanage ||
                        isUserPermitted('CAN_user_acquisition_edi_manage'))
                "
            >
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/edifactmsgs.pl"
                    :title="$__('EDIFACT messages')"
                    ><i
                        class="fa-solid fa-envelope fa-fw"
                        aria-hidden="true"
                    ></i>
                    <span class="menu-label">{{
                        $__("EDIFACT messages")
                    }}</span></a
                >
            </li>
        </ul>
        <template
            v-if="
                reports ||
                circulateremainingpermissions ||
                isUserPermitted('CAN_user_reports') ||
                isUserPermitted(
                    'CAN_user_circulate_circulate_remaining_permissions'
                )
            "
        >
            <h5>{{ $__("Reports") }}</h5>
            <ul>
                <template v-if="reports || isUserPermitted('CAN_user_reports')">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/reports/acquisitions_stats.pl"
                            :title="$__('Acquisitions statistics wizard')"
                            ><i
                                class="fa-solid fa-chart-column fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Acquisitions statistics wizard")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/reports/orders_by_fund.pl"
                            :title="$__('Orders by fund')"
                            ><i
                                class="fa-solid fa-money-bill-wave fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Orders by fund")
                            }}</span></a
                        >
                    </li>
                </template>
                <li
                    v-if="
                        circulateremainingpermissions ||
                        isUserPermitted(
                            'CAN_user_circulate_circulate_remaining_permissions'
                        )
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/circ/reserveratios.pl"
                        :title="$__('Hold ratios')"
                        ><i
                            class="fa-solid fa-scale-balanced fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Hold ratios")
                        }}</span></a
                    >
                </li>
            </ul>
        </template>
        <template
            v-if="
                periodmanage ||
                isUserPermitted('CAN_user_acquisition_period_manage') ||
                budgetmanage ||
                isUserPermitted('CAN_user_acquisition_budget_manage') ||
                currenciesmanage ||
                isUserPermitted('CAN_user_acquisition_currencies_manage') ||
                (edifactEnabled &&
                    (edimanage ||
                        isUserPermitted('CAN_user_acquisition_edi_manage'))) ||
                (marcOrdersEnabled &&
                    (marcordermanage ||
                        isUserPermitted(
                            'CAN_user_acquisition_marc_order_manage'
                        ))) ||
                manageadditionalfields ||
                isUserPermitted('CAN_user_acquisition_edi_manage')
            "
        >
            <h5>{{ $__("Administration") }}</h5>
            <ul>
                <li
                    v-if="
                        periodmanage ||
                        isUserPermitted('CAN_user_acquisition_period_manage')
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/aqbudgetperiods.pl"
                        :title="$__('Budgets')"
                        ><i
                            class="fa-solid fa-coins fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{ $__("Budgets") }}</span></a
                    >
                </li>
                <li
                    v-if="
                        budgetmanage ||
                        isUserPermitted('CAN_user_acquisition_budget_manage')
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/aqbudgets.pl"
                        :title="$__('Funds')"
                        ><i
                            class="fa-solid fa-sack-dollar fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{ $__("Funds") }}</span></a
                    >
                </li>
                <li
                    v-if="
                        currenciesmanage ||
                        isUserPermitted(
                            'CAN_user_acquisition_currencies_manage'
                        )
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/currency.pl"
                        :title="$__('Currencies')"
                        ><i
                            class="fa-solid fa-money-bill-1 fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Currencies")
                        }}</span></a
                    >
                </li>
                <template
                    v-if="
                        (edifactEnabled && edimanage) ||
                        (edifactEnabled &&
                            isUserPermitted('CAN_user_acquisition_edi_manage'))
                    "
                >
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/edi_accounts.pl"
                            :title="$__('EDI accounts')"
                            ><i
                                class="fa-solid fa-network-wired fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("EDI accounts")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/edi_ean_accounts.pl"
                            :title="$__('Library EANs')"
                            ><i
                                class="fa-solid fa-barcode fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Library EANs")
                            }}</span></a
                        >
                    </li>
                </template>
                <template
                    v-if="
                        (marcOrdersEnabled && marcordermanage) ||
                        (marcOrdersEnabled &&
                            isUserPermitted(
                                'CAN_user_acquisition_marc_order_manage'
                            ))
                    "
                >
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/marc_order_accounts.pl"
                            :title="$__('MARC order accounts')"
                            ><i
                                class="fa-solid fa-code fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("MARC order accounts")
                            }}</span></a
                        >
                    </li>
                </template>
                <li
                    v-if="
                        manageadditionalfields ||
                        isUserPermitted(
                            'CAN_user_parameters_manage_additional_fields'
                        ) ||
                        invoiceedit ||
                        isUserPermitted('CAN_user_acquisition_edit_invoices')
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqinvoices"
                        :title="$__('Manage invoice fields')"
                        ><i
                            class="fa-solid fa-list-check fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Manage invoice fields")
                        }}</span></a
                    >
                </li>
                <template
                    v-if="
                        (manageadditionalfields ||
                            isUserPermitted(
                                'CAN_user_parameters_manage_additional_fields'
                            )) &&
                        (ordermanage ||
                            isUserPermitted(
                                'CAN_user_acquisition_order_manage'
                            ))
                    "
                >
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqbasket"
                            :title="$__('Manage order basket fields')"
                            ><i
                                class="fa-solid fa-list-check fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Manage order basket fields")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqorders"
                            :title="$__('Manage order line fields')"
                            ><i
                                class="fa-solid fa-list-check fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Manage order line fields")
                            }}</span></a
                        >
                    </li>
                </template>
            </ul>
        </template>
    </div>
</template>

<script>
import { inject, onMounted, ref } from "vue";
import { storeToRefs } from "pinia";

export default {
    props: {
        ordermanage: {
            type: Number,
        },
        orderreceive: {
            type: Number,
        },
        edifact: {
            type: Number,
        },
        edimanage: {
            type: Number,
        },
        reports: {
            type: Number,
        },
        circulateremainingpermissions: {
            type: Number,
        },
        periodmanage: {
            type: Number,
        },
        budgetmanage: {
            type: Number,
        },
        currenciesmanage: {
            type: Number,
        },
        manageadditionalfields: {
            type: Number,
        },
        invoiceedit: {
            type: Number,
        },
        suggestionscreate: {
            type: Number,
        },
        suggestionsmanage: {
            type: Number,
        },
        suggestionsdelete: {
            type: Number,
        },
        marcorderautomation: {
            type: Number,
        },
        marcordermanage: {
            type: Number,
        },
    },
    setup(props) {
        const navigationStore = inject("navigationStore");
        const { params } = storeToRefs(navigationStore);
        const vendorStore = inject("vendorStore");
        const { isUserPermitted } = vendorStore;
        const { config } = storeToRefs(vendorStore);

        const edifactEnabled = ref(false);
        const marcOrdersEnabled = ref(false);
        edifactEnabled.value = config.value?.settings.edifact
            ? config.value.settings.edifact
            : props.edifact;
        marcOrdersEnabled.value = config.value?.settings.marcorderautomation
            ? config.value.settings.marcorderautomation
            : props.marcorderautomation;

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
            edifactEnabled,
            marcOrdersEnabled,
            templateRefs,
        };
    },
};
</script>

<style></style>
