INSERT INTO permissions (module_bit, code, description) VALUES
   ( 3, 'manage_sysprefs', 'Manage global system preferences'),
   ( 3, 'manage_libraries', 'Manage libraries and library groups'),
   ( 3, 'manage_itemtypes', 'Manage item types'),
   ( 3, 'manage_auth_values', 'Manage authorized values'),
   ( 3, 'manage_patron_categories', 'Manage patron categories'),
   ( 3, 'manage_patron_attributes', 'Manage extended patron attributes'),
   ( 3, 'manage_transfers', 'Manage library transfer limits and transport cost matrix'),
   ( 3, 'manage_item_circ_alerts', 'Manage item circulation alerts'),
   ( 3, 'manage_cities', 'Manage cities and towns'),
   ( 3, 'manage_marc_frameworks', 'Manage MARC bibliographic and authority frameworks'),
   ( 3, 'manage_keywords2koha_mappings', 'Manage keywords to Koha mappings'),
   ( 3, 'manage_classifications', 'Manage classification sources'),
   ( 3, 'manage_matching_rules', 'Manage record matching rules'),
   ( 3, 'manage_oai_sets', 'Manage OAI sets'),
   ( 3, 'manage_item_search_fields', 'Manage item search fields'),
   ( 3, 'manage_search_engine_config', 'Manage search engine configuration'),
   ( 3, 'manage_search_targets', 'Manage Z39.50 and SRU server configuration'),
   ( 3, 'manage_didyoumean', 'Manage Did you mean? configuration'),
   ( 3, 'manage_column_config', 'Manage column configuration'),
   ( 3, 'manage_sms_providers', 'Manage SMS cellular providers'),
   ( 3, 'manage_audio_alerts', 'Manage audio alerts'),
   ( 3, 'manage_usage_stats', 'Manage usage statistics settings');

/* User has parameters_remaining_permissions */
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_sysprefs' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_libraries' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_itemtypes' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_auth_values' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_patron_categories' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_patron_attributes' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_transfers' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_item_circ_alerts' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_cities' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_marc_frameworks' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_keywords2koha_mappings' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_classifications' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_matching_rules' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_oai_sets' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_item_search_fields' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_search_engine_config' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_search_targets' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_didyoumean' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_column_config' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_sms_providers' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_audio_alerts' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_usage_stats' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');

/* User has catalogue permission */
INSERT INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 3, 'manage_item_search_fields'
    FROM borrowers
    WHERE borrowernumber IN
        (SELECT borrowernumber FROM user_permissions WHERE code = 'catalogue');

/* Clean up now obsolete permission */
DELETE FROM user_permissions WHERE module_bit = 3 and code = 'parameters_remaining_permissions';
DELETE FROM permissions WHERE module_bit = 3 and code = 'parameters_remaining_permissions';

-- Bug 14391: Add granular permissions to the administration module
