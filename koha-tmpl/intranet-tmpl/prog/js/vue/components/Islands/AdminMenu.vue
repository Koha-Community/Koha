<template>
    <div id="admin-menu" class="sidebar_menu icon-collapse">
        <template v-if="can_user_parameters_manage_sysprefs">
            <h5>{{ $__("System preferences") }}</h5>
            <ul>
                <li>
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/preferences.pl"
                        :title="$__('System preferences')"
                        ><i
                            class="fa-solid fa-sliders fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("System preferences")
                        }}</span></a
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
                            :title="$__('Libraries')"
                            ><i
                                class="fa-solid fa-building fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Libraries")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/library_groups.pl"
                            :title="$__('Library groups')"
                            ><i
                                class="fa-solid fa-sitemap fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Library groups")
                            }}</span></a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_itemtypes">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/itemtypes.pl"
                        :title="$__('Item types')"
                        ><i
                            class="fa-solid fa-shapes fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Item types")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_auth_values">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/authorised_values.pl"
                        :title="$__('Authorized values')"
                        ><i
                            class="fa-solid fa-list-check fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Authorized values")
                        }}</span></a
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
                        :title="$__('Patron categories')"
                        ><i
                            class="fa-solid fa-id-badge fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Patron categories")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_circ_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/smart-rules.pl"
                        :title="$__('Circulation and fine rules')"
                        ><i
                            class="fa-solid fa-gavel fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Circulation and fine rules")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_patron_attributes">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/patron-attr-types.pl"
                        :title="$__('Patron attribute types')"
                        ><i
                            class="fa-solid fa-tags fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Patron attribute types")
                        }}</span></a
                    >
                </li>
                <template v-if="can_user_parameters_manage_transfers">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/branch_transfer_limits.pl"
                            :title="$__('Library transfer limits')"
                            ><i
                                class="fa-solid fa-truck fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Library transfer limits")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/transport-cost-matrix.pl"
                            :title="$__('Transport cost matrix')"
                            ><i
                                class="fa-solid fa-route fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Transport cost matrix")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/float_limits.pl"
                            :title="$__('Library float limits')"
                            ><i
                                class="fa-solid fa-water fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Library float limits")
                            }}</span></a
                        >
                    </li>
                </template>
                <li v-if="can_user_sip2_manage_sip2">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/sip2/sip2.pl"
                        :title="$__('Self-service circulation (SIP2)')"
                        ><i
                            class="fa-solid fa-satellite-dish fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Self-service circulation (SIP2)")
                        }}</span></a
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
                        :title="$__('Shibboleth configuration')"
                        ><i
                            class="fa-solid fa-key fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Shibboleth configuration")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_item_circ_alerts">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/item_circulation_alerts.pl"
                        :title="$__('Item circulation alerts')"
                        ><i
                            class="fa-solid fa-bell fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Item circulation alerts")
                        }}</span></a
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
                        :title="$__('Desks')"
                        ><i
                            class="fa-solid fa-desktop fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{ $__("Desks") }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_cities">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/cities.pl"
                        :title="$__('Cities and towns')"
                        ><i
                            class="fa-solid fa-city fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Cities and towns")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_curbside_pickups">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/curbside_pickup.pl"
                        :title="$__('Curbside pickup')"
                        ><i
                            class="fa-solid fa-car fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Curbside pickup")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_patron_restrictions">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/restrictions.pl"
                        :title="$__('Patron restriction types')"
                        ><i
                            class="fa-solid fa-ban fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Patron restriction types")
                        }}</span></a
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
                            :title="$__('Debit types')"
                            ><i
                                class="fa-solid fa-arrow-down fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Debit types")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/credit_types.pl"
                            :title="$__('Credit types')"
                            ><i
                                class="fa-solid fa-arrow-up fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Credit types")
                            }}</span></a
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
                        :title="$__('Cash registers')"
                        ><i
                            class="fa-solid fa-cash-register fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Cash registers")
                        }}</span></a
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
                        :title="$__('Plugins')"
                        ><i
                            class="fa-solid fa-puzzle-piece fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{ $__("Plugins") }}</span></a
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
                        :title="$__('Jobs')"
                        ><i
                            class="fa-solid fa-gears fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{ $__("Jobs") }}</span></a
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
                            :title="$__('MARC bibliographic framework')"
                            ><i
                                class="fa-solid fa-diagram-project fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("MARC bibliographic framework")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/koha2marclinks.pl"
                            :title="$__('Koha to MARC mapping')"
                            ><i
                                class="fa-solid fa-right-left fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Koha to MARC mapping")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/checkmarc.pl"
                            :title="$__('MARC bibliographic framework test')"
                            ><i
                                class="fa-solid fa-vial fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("MARC bibliographic framework test")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/authtypes.pl"
                            :title="$__('Authority types')"
                            ><i
                                class="fa-solid fa-address-book fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Authority types")
                            }}</span></a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_classifications">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/classsources.pl"
                        :title="$__('Classification configuration')"
                        ><i
                            class="fa-solid fa-layer-group fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Classification configuration")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_matching_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/matching-rules.pl"
                        :title="$__('Record matching rules')"
                        ><i
                            class="fa-solid fa-code-compare fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Record matching rules")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_record_sources">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/record_sources"
                        :title="$__('Record sources')"
                        ><i
                            class="fa-solid fa-database fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Record sources")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_marc_overlay_rules">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/marc-overlay-rules.pl"
                        :title="$__('Record overlay rules')"
                        ><i
                            class="fa-solid fa-clone fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Record overlay rules")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_oai_sets">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/oai_sets.pl"
                        :title="$__('OAI sets configuration')"
                        ><i
                            class="fa-solid fa-boxes-packing fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("OAI sets configuration")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_item_search_fields">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/items_search_fields.pl"
                        :title="$__('Item search fields')"
                        ><i
                            class="fa-solid fa-magnifying-glass fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Item search fields")
                        }}</span></a
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
                        :title="$__('Search filters')"
                        ><i
                            class="fa-solid fa-filter fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Search filters")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_search_engine_config">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/searchengine/elasticsearch/mappings.pl"
                        :title="
                            $__('Search engine configuration (Elasticsearch)')
                        "
                        ><i
                            class="fa-solid fa-server fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Search engine configuration (Elasticsearch)")
                        }}</span></a
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
                        :title="$__('Currencies and exchange rates')"
                        ><i
                            class="fa-solid fa-money-bill-transfer fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Currencies and exchange rates")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_acquisition_period_manage">
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
                <li v-if="can_user_acquisition_budget_manage">
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
                <template v-if="edifact && can_user_acquisition_edi_manage">
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
                <li
                    v-if="
                        marcorderingautomation &&
                        can_user_acquisition_marc_order_manage
                    "
                >
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/marc_order_accounts.pl"
                        :title="$__('MARC ordering accounts')"
                        ><i
                            class="fa-solid fa-code fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("MARC ordering accounts")
                        }}</span></a
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
                        :title="$__('Identity providers')"
                        ><i
                            class="fa-solid fa-fingerprint fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Identity providers")
                        }}</span></a
                    >
                </li>
                <template v-if="can_user_parameters_manage_search_targets">
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/z3950servers.pl"
                            :title="$__('Z39.50/SRU servers')"
                            ><i
                                class="fa-solid fa-satellite fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("Z39.50/SRU servers")
                            }}</span></a
                        >
                    </li>
                    <li>
                        <a
                            :ref="el => templateRefs.push(el)"
                            href="/cgi-bin/koha/admin/oai_servers.pl"
                            :title="$__('OAI repositories')"
                            ><i
                                class="fa-solid fa-cloud-arrow-down fa-fw"
                                aria-hidden="true"
                            ></i>
                            <span class="menu-label">{{
                                $__("OAI repositories")
                            }}</span></a
                        >
                    </li>
                </template>
                <li v-if="can_user_parameters_manage_smtp_servers">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/smtp_servers.pl"
                        :title="$__('SMTP servers')"
                        ><i
                            class="fa-solid fa-envelope fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("SMTP servers")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_file_transports">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/file_transports.pl"
                        :title="$__('File transports')"
                        ><i
                            class="fa-solid fa-file-export fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("File transports")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_didyoumean">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/didyoumean.pl"
                        :title="$__('Did you mean?')"
                        ><i
                            class="fa-solid fa-circle-question fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Did you mean?")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_column_config">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/columns_settings.pl"
                        :title="$__('Table settings')"
                        ><i
                            class="fa-solid fa-table-cells fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Table settings")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_audio_alerts">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/audio_alerts.pl"
                        :title="$__('Audio alerts')"
                        ><i
                            class="fa-solid fa-volume-high fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Audio alerts")
                        }}</span></a
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
                        :title="$__('SMS cellular providers')"
                        ><i
                            class="fa-solid fa-comment-sms fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("SMS cellular providers")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_usage_stats">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/usage_statistics.pl"
                        :title="$__('Share usage statistics')"
                        ><i
                            class="fa-solid fa-chart-line fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Share usage statistics")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_mana">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/share_content.pl"
                        :title="$__('Share content with Mana KB')"
                        ><i
                            class="fa-solid fa-share-nodes fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Share content with Mana KB")
                        }}</span></a
                    >
                </li>
                <li v-if="can_user_parameters_manage_additional_fields">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/additional-fields.pl"
                        :title="$__('Additional fields')"
                        ><i
                            class="fa-solid fa-list-ul fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Additional fields")
                        }}</span></a
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
                        :title="$__('Keyboard shortcuts')"
                        ><i
                            class="fa-solid fa-keyboard fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Keyboard shortcuts")
                        }}</span></a
                    >
                </li>
                <li v-if="illmodule && can_user_ill">
                    <a
                        :ref="el => templateRefs.push(el)"
                        href="/cgi-bin/koha/admin/ill_batch_statuses.pl"
                        :title="$__('Interlibrary loan batch statuses')"
                        ><i
                            class="fa-solid fa-people-arrows fa-fw"
                            aria-hidden="true"
                        ></i>
                        <span class="menu-label">{{
                            $__("Interlibrary loan batch statuses")
                        }}</span></a
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
        can_user_sip2_manage_sip2: Number,
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
