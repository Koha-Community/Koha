<template>
    <div id="acquisitions-menu" class="sidebar_menu">
        <h5>{{ $__("Acquisitions") }}</h5>
        <ul>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/acqui-home.pl"
                    >{{ $__("Acquisitions home") }}</a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/histsearch.pl"
                    >{{ $__("Advanced search") }}</a
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
                    >{{ $__("Late orders") }}</a
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
                    >{{ $__("Suggestions") }}</a
                >
            </li>
            <li>
                <a
                    :ref="el => templateRefs.push(el)"
                    href="/cgi-bin/koha/acqui/invoices.pl"
                    >{{ $__("Invoices") }}</a
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
                    >{{ $__("EDIFACT messages") }}</a
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
                            >{{ $__("Acquisitions statistics wizard") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/reports/orders_by_fund.pl"
                            >{{ $__("Orders by fund") }}</a
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
                        >{{ $__("Hold ratios") }}</a
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
                        >{{ $__("Budgets") }}</a
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
                        >{{ $__("Funds") }}</a
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
                        >{{ $__("Currencies") }}</a
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
                            >{{ $__("EDI accounts") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/edi_ean_accounts.pl"
                            >{{ $__("Library EANs") }}</a
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
                            >{{ $__("MARC order accounts") }}</a
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
                        >{{ $__("Manage invoice fields") }}</a
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
                            >{{ $__("Manage order basket fields") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/additional-fields.pl?tablename=aqorders"
                            >{{ $__("Manage order line fields") }}</a
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
