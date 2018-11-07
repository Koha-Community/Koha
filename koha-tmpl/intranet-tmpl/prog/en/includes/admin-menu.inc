[% USE Koha %]

<div id="navmenu">
<div id="navmenulist">

    [% IF ( CAN_user_parameters_manage_sysprefs ) %]
        <h5>System preferences</h5>
        <ul>
            <li><a href="/cgi-bin/koha/admin/preferences.pl">System preferences</a></li>
        </ul>
    [% END %]

    [% IF ( CAN_user_parameters_manage_libraries || CAN_user_parameters_manage_itemtypes || CAN_user_parameters_manage_auth_values ) %]
        <h5>Basic parameters</h5>
        <ul>
            [% IF ( CAN_user_parameters_manage_libraries ) %]
                <li><a href="/cgi-bin/koha/admin/branches.pl">Libraries</a></li>
                <li><a href="/cgi-bin/koha/admin/library_groups.pl">Library groups</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_itemtypes ) %]
                <li><a href="/cgi-bin/koha/admin/itemtypes.pl">Item types</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_auth_values ) %]
                <li><a href="/cgi-bin/koha/admin/authorised_values.pl">Authorized values</a></li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_parameters_patron_categories || CAN_user_parameters_manage_circ_rules || CAN_user_parameters_manage_patron_attributes || CAN_user_parameters_manage_transfers || CAN_user_parameters_manage_item_circ_alerts || CAN_user_parameters_manage_cities ) %]
        <h5>Patrons and circulation</h5>
        <ul>
            [% IF ( CAN_user_parameters_patron_categories ) %]
                <li><a href="/cgi-bin/koha/admin/categories.pl">Patron categories</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_circ_rules ) %]
                <li><a href="/cgi-bin/koha/admin/smart-rules.pl">Circulation and fines rules</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_patron_attributes ) %]
                <li><a href="/cgi-bin/koha/admin/patron-attr-types.pl">Patron attribute types</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_transfers ) %]
                <li><a href="/cgi-bin/koha/admin/branch_transfer_limits.pl">Library transfer limits</a></li>
                <li><a href="/cgi-bin/koha/admin/transport-cost-matrix.pl">Transport cost matrix</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_item_circ_alerts ) %]
                <li><a href="/cgi-bin/koha/admin/item_circulation_alerts.pl">Item circulation alerts</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_cities ) %]
                <li><a href="/cgi-bin/koha/admin/cities.pl">Cities and towns</a></li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_parameters_manage_keywords2koha_mappings || CAN_user_parameters_manage_marc_frameworks || CAN_user_parameters_manage_classifications || CAN_user_parameters_manage_matching_rules || CAN_user_parameters_manage_oai_sets || CAN_user_parameters_manage_item_search_fields || (Koha.Preference('SearchEngine') == 'Elasticsearch' && CAN_user_parameters_manage_search_engine_config) ) %]
        <h5>Catalog</h5>
        <ul>
            [% IF ( CAN_user_parameters_manage_marc_frameworks ) %]
                <li><a href="/cgi-bin/koha/admin/biblio_framework.pl">MARC bibliographic framework</a></li>
                <li><a href="/cgi-bin/koha/admin/koha2marclinks.pl">Koha to MARC mapping</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_keywords2koha_mappings ) %]
                <li><a href="/cgi-bin/koha/admin/fieldmapping.pl">Keywords to MARC mapping</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_marc_frameworks ) %]
                <li><a href="/cgi-bin/koha/admin/checkmarc.pl">MARC bibliographic framework test</a></li>
                <li><a href="/cgi-bin/koha/admin/authtypes.pl">Authority types</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_classifications ) %]
                <li><a href="/cgi-bin/koha/admin/classsources.pl">Classification sources</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_matching_rules ) %]
                <li><a href="/cgi-bin/koha/admin/matching-rules.pl">Record matching rules</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_oai_sets ) %]
                <li><a href="/cgi-bin/koha/admin/oai_sets.pl">OAI sets configuration</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_item_search_fields ) %]
                <li><a href="/cgi-bin/koha/admin/items_search_fields.pl">Item search fields</a></li>
            [% END %]
            [% IF ( Koha.Preference('SearchEngine') == 'Elasticsearch' && CAN_user_parameters_manage_search_engine_config ) %]
                <li><a href="/cgi-bin/koha/admin/searchengine/elasticsearch/mappings.pl">Search engine configuration</a></li>
            [% END %]
        </ul>
    [% END %]

    [% IF ( CAN_user_acquisition_currencies_manage || CAN_user_acquisition_period_manage || CAN_user_acquisition_budget_manage || CAN_user_acquisition_edi_manage ) %]
        <h5>Acquisition parameters</h5>

        <ul>
            [% IF ( CAN_user_acquisition_currencies_manage ) %]
                <li><a href="/cgi-bin/koha/admin/currency.pl">Currencies and exchange rates</a></li>
            [% END %]
            [% IF ( CAN_user_acquisition_period_manage ) %]
                <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">Budgets</a></li>
            [% END %]
            [% IF ( CAN_user_acquisition_budget_manage ) %]
                <li><a href="/cgi-bin/koha/admin/aqbudgets.pl">Funds</a></li>
            [% END %]
            [% IF ( CAN_user_acquisition_edi_manage ) %]
                <li><a href="/cgi-bin/koha/admin/edi_accounts.pl">EDI accounts</a></li>
                <li><a href="/cgi-bin/koha/admin/edi_ean_accounts.pl">Library EANs</a></li>
            [% END %]
        </ul>
    [% END %]

    [% IF CAN_user_plugins && plugins_enabled %]
        <h5>Plugins</h5>
        <ul>
            <li><a href="/cgi-bin/koha/plugins/plugins-home.pl">Manage plugins</a></li>
        </ul>
    [% END %]

    [% IF ( CAN_user_parameters_manage_search_targets || CAN_user_parameters_manage_didyoumean || CAN_user_parameters_manage_column_config || CAN_user_parameters_manage_audio_alerts || ( CAN_user_parameters_manage_sms_providers && Koha.Preference('SMSSendDriver') == 'Email' ) || CAN_user_parameters_manage_usage_stats ) %]
        <h5>Additional parameters</h5>
        <ul>
            <!-- <li><a href="/cgi-bin/koha/admin/printers.pl">Network Printers</a></li> -->
            [% IF ( CAN_user_parameters_manage_search_targets ) %]
                <li><a href="/cgi-bin/koha/admin/z3950servers.pl">Z39.50/SRU servers</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_didyoumean ) %]
                <li><a href="/cgi-bin/koha/admin/didyoumean.pl">Did you mean?</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_column_config ) %]
                <li><a href="/cgi-bin/koha/admin/columns_settings.pl">Columns settings</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_audio_alerts ) %]
                <li><a href="/cgi-bin/koha/admin/audio_alerts.pl">Audio alerts</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_sms_providers && Koha.Preference('SMSSendDriver') == 'Email' ) %]
                    <li><a href="/cgi-bin/koha/admin/sms_providers.pl">SMS cellular providers</a></li>
            [% END %]
            [% IF ( CAN_user_parameters_manage_usage_stats ) %]
                <li><a href="/cgi-bin/koha/admin/usage_statistics.pl">Share usage statistics</a></li>
            [% END %]
        </ul>
    [% END %]
</div>
</div>
