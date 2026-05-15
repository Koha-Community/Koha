<template>
    <div id="admin-menu" class="sidebar_menu">
        <template v-if="can_user_parameters_manage_sysprefs">
            <h5>{{ $__("System preferences") }}</h5>
            <ul>
                <li>
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/preferences.pl"
                        >{{ $__("System preferences") }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_parameters_manage_libraries ||
                can_user_parameters_manage_itemtypes ||
                can_user_parameters_manage_auth_values
            "
        >
            <h5>{{ $__("Basic parameters") }}</h5>
            <ul>
                <template v-if="can_user_parameters_manage_libraries">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/branches.pl"
                            >{{ $__("Libraries") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/library_groups.pl"
                            >{{ $__("Library groups") }}</a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_itemtypes">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/itemtypes.pl"
                        >{{ $__("Item types") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_auth_values">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/authorised_values.pl"
                        >{{ $__("Authorized values") }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_parameters_manage_patron_categories ||
                can_user_parameters_manage_circ_rules ||
                can_user_parameters_manage_patron_attributes ||
                can_user_parameters_manage_transfers ||
                can_user_parameters_manage_item_circ_alerts ||
                can_user_parameters_manage_cities ||
                can_user_parameters_manage_curbside_pickups ||
                can_user_parameters_manage_patron_restrictions
            "
        >
            <h5>{{ $__("Patrons and circulation") }}</h5>
            <ul>
                <li v-if="can_user_parameters_manage_patron_categories">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/categories.pl"
                        >{{ $__("Patron categories") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_circ_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/smart-rules.pl"
                        >{{ $__("Circulation and fine rules") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_patron_attributes">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/patron-attr-types.pl"
                        >{{ $__("Patron attribute types") }}</a
                    >
                </li>
                <template v-if="can_user_parameters_manage_transfers">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/branch_transfer_limits.pl"
                            >{{ $__("Library transfer limits") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/transport-cost-matrix.pl"
                            >{{ $__("Transport cost matrix") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/float_limits.pl"
                            >{{ $__("Library float limits") }}</a
                        >
                    </li>
                </template>
                <li v-if="can_user_sip2">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/sip2/sip2.pl"
                        >{{ $__("Self-service circulation (SIP2)") }}</a
                    >
                </li>
                <li
                    v-if="
                        can_user_parameters_manage_identity_providers &&
                        shibbolethauthentication
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/shibboleth/shibboleth.pl"
                        >{{ $__("Shibboleth configuration") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_item_circ_alerts">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/item_circulation_alerts.pl"
                        >{{ $__("Item circulation alerts") }}</a
                    >
                </li>
                <li
                    v-if="
                        usecirculationdesks &&
                        can_user_parameters_manage_libraries
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/desks.pl"
                        >{{ $__("Desks") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_cities">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/cities.pl"
                        >{{ $__("Cities and towns") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_curbside_pickups">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/curbside_pickup.pl"
                        >{{ $__("Curbside pickup") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_patron_restrictions">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/restrictions.pl"
                        >{{ $__("Patron restriction types") }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_parameters_manage_accounts ||
                (usecashregisters && can_user_parameters_manage_cash_registers)
            "
        >
            <h5>{{ $__("Accounting") }}</h5>
            <ul>
                <template v-if="can_user_parameters_manage_accounts">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/debit_types.pl"
                            >{{ $__("Debit types") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/credit_types.pl"
                            >{{ $__("Credit types") }}</a
                        >
                    </li>
                </template>
                <li
                    v-if="
                        usecashregisters &&
                        can_user_parameters_manage_cash_registers
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/cash_registers.pl"
                        >{{ $__("Cash registers") }}</a
                    >
                </li>
            </ul>
        </template>

        <template v-if="can_user_plugins && plugins_enabled">
            <h5>{{ $__("Plugins") }}</h5>
            <ul>
                <li>
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/plugins/plugins-home.pl"
                        >{{ $__("Plugins") }}</a
                    >
                </li>
            </ul>
        </template>

        <template v-if="can_user_parameters_manage_background_jobs">
            <h5>{{ $__("Jobs") }}</h5>
            <ul>
                <li>
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/background_jobs.pl"
                        >{{ $__("Jobs") }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_parameters_manage_marc_frameworks ||
                can_user_parameters_manage_classifications ||
                can_user_parameters_manage_matching_rules ||
                can_user_parameters_manage_oai_sets ||
                can_user_parameters_manage_item_search_fields ||
                can_user_parameters_manage_search_engine_config ||
                can_user_parameters_manage_marc_overlay_rules ||
                (savedsearchfilters &&
                    can_user_parameters_manage_search_filters)
            "
        >
            <h5>{{ $__("Catalog") }}</h5>
            <ul>
                <template v-if="can_user_parameters_manage_marc_frameworks">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/biblio_framework.pl"
                            >{{ $__("MARC bibliographic framework") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/koha2marclinks.pl"
                            >{{ $__("Koha to MARC mapping") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/checkmarc.pl"
                            >{{ $__("MARC bibliographic framework test") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/authtypes.pl"
                            >{{ $__("Authority types") }}</a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_classifications">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/classsources.pl"
                        >{{ $__("Classification configuration") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_matching_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/matching-rules.pl"
                        >{{ $__("Record matching rules") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_record_sources">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/record_sources"
                        >{{ $__("Record sources") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_marc_overlay_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/marc-overlay-rules.pl"
                        >{{ $__("Record overlay rules") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_oai_sets">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/oai_sets.pl"
                        >{{ $__("OAI sets configuration") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_item_search_fields">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/items_search_fields.pl"
                        >{{ $__("Item search fields") }}</a
                    >
                </li>
                <li
                    v-if="
                        savedsearchfilters &&
                        can_user_parameters_manage_search_filters
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/search_filters.pl"
                        >{{ $__("Search filters") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_search_engine_config">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/searchengine/elasticsearch/mappings.pl"
                        >{{
                            $__("Search engine configuration (Elasticsearch)")
                        }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_acquisition_currencies_manage ||
                can_user_acquisition_period_manage ||
                can_user_acquisition_budget_manage ||
                (edifact && can_user_acquisition_edi_manage) ||
                (marcorderingautomation &&
                    can_user_acquisition_marc_order_manage)
            "
        >
            <h5>{{ $__("Acquisition parameters") }}</h5>
            <ul>
                <li v-if="can_user_acquisition_currencies_manage">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/currency.pl"
                        >{{ $__("Currencies and exchange rates") }}</a
                    >
                </li>
                <li v-if="can_user_acquisition_period_manage">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/aqbudgetperiods.pl"
                        >{{ $__("Budgets") }}</a
                    >
                </li>
                <li v-if="can_user_acquisition_budget_manage">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/aqbudgets.pl"
                        >{{ $__("Funds") }}</a
                    >
                </li>
                <template v-if="edifact && can_user_acquisition_edi_manage">
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
                <li
                    v-if="
                        marcorderingautomation &&
                        can_user_acquisition_marc_order_manage
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/marc_order_accounts.pl"
                        >{{ $__("MARC ordering accounts") }}</a
                    >
                </li>
            </ul>
        </template>

        <template
            v-if="
                can_user_parameters_manage_identity_providers ||
                can_user_parameters_manage_smtp_servers ||
                can_user_parameters_manage_file_transports ||
                can_user_parameters_manage_search_targets ||
                can_user_parameters_manage_didyoumean ||
                can_user_parameters_manage_column_config ||
                can_user_parameters_manage_audio_alerts ||
                (can_user_parameters_manage_sms_providers &&
                    smssenddriver == 'Email') ||
                can_user_parameters_manage_usage_stats ||
                can_user_parameters_manage_additional_fields ||
                (enableadvancedcatalogingeditor &&
                    can_user_parameters_manage_keyboard_shortcuts)
            "
        >
            <h5>{{ $__("Additional parameters") }}</h5>
            <ul>
                <li v-if="can_user_parameters_manage_identity_providers">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/identity_providers.pl"
                        >{{ $__("Identity providers") }}</a
                    >
                </li>
                <template v-if="can_user_parameters_manage_search_targets">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/z3950servers.pl"
                            >{{ $__("Z39.50/SRU servers") }}</a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/oai_servers.pl"
                            >{{ $__("OAI repositories") }}</a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_smtp_servers">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/smtp_servers.pl"
                        >{{ $__("SMTP servers") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_file_transports">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/file_transports.pl"
                        >{{ $__("File transports") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_didyoumean">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/didyoumean.pl"
                        >{{ $__("Did you mean?") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_column_config">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/columns_settings.pl"
                        >{{ $__("Table settings") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_audio_alerts">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/audio_alerts.pl"
                        >{{ $__("Audio alerts") }}</a
                    >
                </li>
                <li
                    v-if="
                        can_user_parameters_manage_sms_providers &&
                        smssenddriver == 'Email'
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/sms_providers.pl"
                        >{{ $__("SMS cellular providers") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_usage_stats">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/usage_statistics.pl"
                        >{{ $__("Share usage statistics") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_mana">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/share_content.pl"
                        >{{ $__("Share content with Mana KB") }}</a
                    >
                </li>
                <li v-if="can_user_parameters_manage_additional_fields">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/additional-fields.pl"
                        >{{ $__("Additional fields") }}</a
                    >
                </li>
                <li
                    v-if="
                        enableadvancedcatalogingeditor &&
                        can_user_parameters_manage_keyboard_shortcuts
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/adveditorshortcuts.pl"
                        >{{ $__("Keyboard shortcuts") }}</a
                    >
                </li>
                <li v-if="illmodule && can_user_ill">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/ill_batch_statuses.pl"
                        >{{ $__("Interlibrary loan batch statuses") }}</a
                    >
                </li>
            </ul>
        </template>
    </div>
    <!-- /.sidebar_menu -->
</template>

<script>
import { onMounted, ref } from "vue";

export default {
    name: "AdminMenu",
    props: {
        can_user_parameters_manage_sysprefs: Number,
        can_user_parameters_manage_libraries: Number,
        can_user_parameters_manage_itemtypes: Number,
        can_user_parameters_manage_auth_values: Number,
        can_user_parameters_manage_patron_categories: Number,
        can_user_parameters_manage_circ_rules: Number,
        can_user_parameters_manage_patron_attributes: Number,
        can_user_parameters_manage_transfers: Number,
        can_user_parameters_manage_item_circ_alerts: Number,
        can_user_parameters_manage_cities: Number,
        can_user_parameters_manage_curbside_pickups: Number,
        can_user_parameters_manage_patron_restrictions: Number,
        can_user_sip2: Number,
        can_user_parameters_manage_identity_providers: Number,
        can_user_parameters_manage_accounts: Number,
        can_user_parameters_manage_cash_registers: Number,
        can_user_plugins: Number,
        plugins_enabled: Number,
        can_user_parameters_manage_background_jobs: Number,
        can_user_parameters_manage_marc_frameworks: Number,
        can_user_parameters_manage_classifications: Number,
        can_user_parameters_manage_matching_rules: Number,
        can_user_parameters_manage_oai_sets: Number,
        can_user_parameters_manage_item_search_fields: Number,
        can_user_parameters_manage_search_engine_config: Number,
        can_user_parameters_manage_marc_overlay_rules: Number,
        can_user_parameters_manage_search_filters: Number,
        can_user_parameters_manage_record_sources: Number,
        can_user_acquisition_currencies_manage: Number,
        can_user_acquisition_period_manage: Number,
        can_user_acquisition_budget_manage: Number,
        can_user_acquisition_edi_manage: Number,
        can_user_acquisition_marc_order_manage: Number,
        can_user_parameters_manage_smtp_servers: Number,
        can_user_parameters_manage_file_transports: Number,
        can_user_parameters_manage_search_targets: Number,
        can_user_parameters_manage_didyoumean: Number,
        can_user_parameters_manage_column_config: Number,
        can_user_parameters_manage_audio_alerts: Number,
        can_user_parameters_manage_sms_providers: Number,
        can_user_parameters_manage_usage_stats: Number,
        can_user_parameters_manage_mana: Number,
        can_user_parameters_manage_additional_fields: Number,
        can_user_parameters_manage_keyboard_shortcuts: Number,
        can_user_ill: Number,
        shibbolethauthentication: Number,
        usecirculationdesks: Number,
        usecashregisters: Number,
        savedsearchfilters: Number,
        edifact: Number,
        marcorderingautomation: Number,
        smssenddriver: String,
        enableadvancedcatalogingeditor: Number,
        illmodule: Number,
    },
    setup() {
        const templateRefs = ref([]);

        onMounted(() => {
            const path = location.pathname.substring(1);

            templateRefs.value
                .find(a => a.href.includes(path))
                ?.classList.add("current");
        });
        return {
            templateRefs,
        };
    },
};
</script>

<style scoped>
.sidebar_menu a.current {
    font-weight: bold;
}
</style>
