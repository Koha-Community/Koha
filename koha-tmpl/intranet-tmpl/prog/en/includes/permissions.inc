[%- BLOCK main_permissions -%]
    [% SWITCH name %]
    [%- CASE 'superlibrarian' -%]
        <span class="main_permission superlibrarian_permission">Access to all librarian functions</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'circulate' -%]
        <span class="main_permission circulate_permission">Check out and check in items</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'catalogue' -%]
        <span class="main_permission catalogue_permission">Staff access, allows viewing of catalogue in staff interface</span>
        <span class="permissioncode">([% name | html %])</span> <span class="required">Required for staff login.</span>
    [%- CASE 'parameters' -%]
        <span class="main_permission parameters_permission">Manage Koha system settings (Administration panel)</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'borrowers' -%]
        <span class="main_permission borrowers_permission">Add, modify and view patron information</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'permissions' -%]
        <span class="main_permission permissions_permission">Set user permissions</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'reserveforothers' -%]
        <span class="main_permission reserveforothers_permission">Place and modify holds for patrons</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'editcatalogue' -%]
        <span class="main_permission editcatalogue_permission">Edit catalog (Modify bibliographic/holdings data)</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'updatecharges' -%]
        <span class="main_permission updatecharges_permission">Manage patrons fines and fees</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'acquisition' -%]
        <span class="main_permission acquisition_permission">Acquisition management</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'suggestions' -%]
        <span class="main_permission suggestions_permission">Suggestions management</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'tools' -%]
        <span class="main_permission tools_permission">Use all tools (expand for granular tools permissions)</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'editauthorities' -%]
        <span class="main_permission editauthorities_permission">Edit authorities</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'serials' -%]
        <span class="main_permission serials_permission">Manage serial subscriptions</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'reports' -%]
        <span class="main_permission reports_permission">Allow access to the reports module</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'staffaccess' -%]
        <span class="main_permission staffaccess_permission">Allow staff members to modify permissions, usernames, and passwords for other staff members</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'coursereserves' -%]
        <span class="main_permission coursereserves_permission">Course reserves</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'plugins' -%]
        <span class="main_permission plugins_permission">Koha plugins</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'lists' -%]
        <span class="main_permission lists_permission">Lists</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'clubs' -%]
        <span class="main_permission clubs_permission">Patron clubs</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'ill' -%]
        <span class="main_permission ill_permission">Create and modify Interlibrary loan requests</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'self_check' -%]
        <span class="main_permission self_check_permission">Self check modules</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'stockrotation' -%]
        <span class="main_permission self_check_permission">Manage stockrotation operations</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'cash_management' -%]
        <span class="main_permission cash_management_permission">Cash management</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'problem_reports' -%]
        <span class="main_permission problem_reports_permission">OPAC problem reports management</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'recalls' -%]
        <span class="main_permission recalls_permission">Recalls</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'erm' -%]
        <span class="main_permission erm_permission">Manage the electronic resources module</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'loggedinlibrary' -%]
        <span class="main_permission loggedinlibrary_permission">Allow staff to change logged in library</span>
        <span class="permissioncode">([% name | html %])</span>
    [%- END -%]
[%- END -%]

[%- BLOCK sub_permissions -%]
  [% SWITCH name %]
    [%- CASE 'circulate_remaining_permissions' -%]
        <span class="sub_permission circulate_remaining_permissions_subpermission">
            Remaining circulation permissions
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'force_checkout' -%]
        <span class="sub_permission force_checkout_subpermission">
            Force checkout if a limitation exists
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_restrictions' -%]
        <span class="sub_permission manage_restrictions_subpermission">
            Manage restrictions for accounts
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'overdues_report' -%]
        <span class="sub_permission overdues_report_subpermission">
            Execute overdue items report
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'override_renewals' -%]
        <span class="sub_permission override_renewals_subpermission">
            Override blocked renewals
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_checkout_notes' %]
        <span class="sub_permission manage_checkout_notes_subpermission">
            Mark checkout notes as seen/not seen
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_accounts' -%]
        <span class="sub_permission manage_accounts_subpermission">
            Manage account debit and credit types
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_circ_rules' -%]
        <span class="sub_permission manage_circ_rules_subpermission">
            Manage circulation rules
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_circ_rules_from_any_libraries' -%]
        <span class="sub_permission manage_circ_rules_from_any_libraries_subpermission">
            Manage circulation rules for any library. If not set the logged in user can only edit circulation rules for their own library (please note that manage_circ_rules is still required)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'parameters_remaining_permissions' -%]
        <span class="sub_permission parameters_remaining_permissions_subpermission">
            Remaining system parameters permissions
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_circ_rules' -%]
        <span class="sub_permission manage_circ_rules_subpermission">
            Manage circulation rules
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_sysprefs' -%]
        <span class="sub_permission manage_sysprefs_subpermission">
            Manage system preferences
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_libraries' -%]
        <span class="sub_permission manage_libraries_subpermission">
            Manage libraries and library groups
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_itemtypes' -%]
        <span class="sub_permission manage_itemtypes_subpermission">
            Manage item types
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_auth_values' -%]
        <span class="sub_permission manage_auth_values_subpermission">
            Manage authorized value categories and authorized values
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_patron_categories' -%]
        <span class="sub_permission manage_patron_categories_subpermission">
            Manage patron categories
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_patron_restrictions' -%]
        <span class="sub_permission manage_patron_restrictions_subpermission">
            Manage patron restrictions
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_patron_attributes' -%]
        <span class="sub_permission manage_patron_attributes_subpermission">
            Manage extended patron attributes
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_transfers' -%]
        <span class="sub_permission manage_transfers_subpermission">
            Manage library transfer limits and transport cost matrix
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_item_circ_alerts' -%]
        <span class="sub_permission manage_item_circ_alerts_subpermission">
            Manage item circulation alerts
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_cities' -%]
        <span class="sub_permission manage_cities_subpermission">
            Manage cities and towns
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_marc_frameworks' -%]
        <span class="sub_permission manage_marc_frameworks_subpermission">
            Manage MARC bibliographic and authority frameworks and test them
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_classifications' -%]
        <span class="sub_permission manage_classifications_subpermission">
            Manage classification sources and filing rules
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_matching_rules' -%]
        <span class="sub_permission manage_matching_rules_subpermission">
            Manage record matching rules
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_oai_sets' -%]
        <span class="sub_permission manage_oai_sets_subpermission">
            Manage OAI sets
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_item_search_fields' -%]
        <span class="sub_permission manage_item_search_fields_subpermission">
            Manage item search fields
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_search_filters' -%]
        <span class="sub_permission manage_search_filters_subpermission">
            Manage saved search filters
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_search_engine_config' -%]
        <span class="sub_permission manage_search_engine_config_subpermission">
            Manage search engine configuration
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_marc_overlay_rules' -%]
        <span class="sub_permission manage_marc_overlay_rules_subpermission">
          Manage MARC overlay rules configuration
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_search_targets' -%]
        <span class="sub_permission manage_search_targets_subpermission">
            Manage Z39.50 and SRU server configuration
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_didyoumean' -%]
        <span class="sub_permission manage_didyoumean_subpermission">
            Manage Did you mean? configuration
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_smtp_servers' -%]
        <span class="sub_permission manage_manage_smtp_servers_subpermission">
            Manage SMTP servers
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_column_config' -%]
        <span class="sub_permission manage_column_config_subpermission">
            Manage column configuration
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_audio_alerts' -%]
        <span class="sub_permission manage_audio_alerts_subpermission">
            Manage audio alerts
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_additional_fields' -%]
        <span class="sub_permission manage_aditional_fields_subpermission">
            Manage additional fields for baskets or subscriptions (requires edit_subscription or order_manage permissions)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_sms_providers' -%]
        <span class="sub_permission manage_sms_providers_subpermission">
            Manage SMS cellular providers
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_usage_stats' -%]
        <span class="sub_permission manage_usage_stats_subpermission">
            Manage usage statistics settings
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_mana' -%]
        <span class="sub_permission manage_mana_subpermission">
            Manage Mana KB content sharing
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_keyboard_shortcuts' -%]
        <span class="sub_permission manage_keyboard_shortcuts_subpermission">
            Manage keyboard shortcuts for the advanced cataloging editor
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_background_jobs' -%]
        <span class="sub_permission manage_background_jobs_subpermission">
            Manage background jobs
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_curbside_pickups' -%]
        <span class="sub_permission manage_curbside_pickups_subpermission">
            Manage curbside pickups
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_borrowers' -%]
        <span class="sub_permission delete_borrowers_subpermission">
            Delete patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_borrowers' -%]
        <span class="sub_permission edit_borrowers_subpermission">
            Add, modify and view patron information
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'view_borrower_infos_from_any_libraries' -%]
        <span class="sub_permission view_borrower_infos_from_any_libraries_subpermission">
            View patron infos from any libraries. If not set the logged in user could only access patron infos from its own library or group of libraries.
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'modify_holds_priority' -%]
        <span class="sub_permission modify_holds_priority_subpermission">
            Modify holds priority
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'place_holds' -%]
        <span class="sub_permission place_holds_subpermission">
            Place holds for patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_all_items' -%]
        <span class="sub_permission delete_all_items_subpermission">
            Delete all items at once
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_catalogue' -%]
        <span class="sub_permission edit_catalogue_subpermission">
            Edit catalog (Modify bibliographic/holdings data)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'advanced_editor' -%]
        <span class="sub_permission advanced_editor_subpermission">
            Use the advanced cataloging editor (requires edit_catalogue)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'create_shared_macros' -%]
        <span class="sub_permission create_shared_macros_subpermission">
            Create shared macros (requires advanced_editor)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_shared_macros' -%]
        <span class="sub_permission delete_shared_macros_subpermission">
            Delete shared macros (requires advanced_editor)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_items' -%]
        <span class="sub_permission edit_items_subpermission">
            Edit items (not including items restricted by library group)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_any_item' -%]
        <span class="sub_permission edit_items_subpermission">
            Edit any item including items that would otherwise be restricted
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_items_restricted' -%]
        <span class="sub_permission edit_items_restricted_subpermission">
            Limit item modification to subfields defined in the SubfieldsToAllowForRestrictedEditing preference (please note that edit_item is still required)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'fast_cataloging' -%]
        <span class="sub_permission fast_cataloging_subpermission">
            Fast cataloging
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_item_groups' -%]
        <span class="sub_permission manage_item_groups_subpermission">
            Create, update and delete item groups, add or remove items from an item group
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_item_editor_templates' -%]
        <span class="sub_permission manage_item_editor_templates_subpermission">
            Create, update and delete item editor templates owned by others
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'remaining_permissions' -%]
        <span class="sub_permission remaining_permissions_subpermission">
            Remaining permissions for managing fines and fees
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'discount' -%]
        <span class="sub_permission discount_subpermission">
            Discount debits for patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'payout' -%]
        <span class="sub_permission payout_subpermission">
            Payout credits to patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'refund' -%]
        <span class="sub_permission refund_subpermission">
            Refund payments to patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'writeoff' -%]
        <span class="sub_permission writeoff_subpermission">
            Write off fines and fees
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manual_invoice' -%]
        <span class="sub_permission manual_invoice_subpermission">
            Add manual invoices to a patron account
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manual_credit' -%]
        <span class="sub_permission manual_credit_subpermission">
            Add manual credits to a patron account
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'suggestions_manage' -%]
        <span class="sub_permission suggestions_manage_subpermission">
            Manage purchase suggestions
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'budget_add_del' -%]
        <span class="sub_permission budget_add_del_subpermission">
            Add and delete funds (but can't modify funds)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'budget_manage' -%]
        <span class="sub_permission budget_manage_subpermission">
            Manage funds
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'budget_manage_all' -%]
        <span class="sub_permission budget_manage_all_subpermission">
            Manage all funds
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'budget_modify' -%]
        <span class="sub_permission budget_modify_subpermission">
            Modify funds (can't create lines, but can modify existing ones)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'contracts_manage' -%]
        <span class="sub_permission contracts_manage_subpermission">
            Manage contracts
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'group_manage' -%]
        <span class="sub_permission group_manage_subpermission">
            Manage basket groups
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'order_manage' -%]
        <span class="sub_permission order_manage_subpermission">
            Manage basket and order lines
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'order_manage_all' -%]
        <span class="sub_permission order_manage_all_subpermission">
            Manage all baskets and order lines, regardless of restrictions on them
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'issue_manage' -%]
        <span class="sub_permission issues_manage_subpermission">
            Manage issues
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'order_receive' -%]
        <span class="sub_permission order_receive_subpermission">
            Receive orders and manage shipments
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'period_manage' -%]
        <span class="sub_permission period_manage_subpermission">
            Manage budgets
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'planning_manage' -%]
        <span class="sub_permission planning_manage_subpermission">
            Manage budget plannings
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'vendors_manage' -%]
        <span class="sub_permission vendors_manage_subpermission">
            Manage vendors
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'currencies_manage' -%]
        <span class="sub_permission currencies_manage_subpermission">
            Manage currencies and exchange rates
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'batch_upload_patron_images' -%]
        <span class="sub_permission batch_upload_patron_images_subpermission">
            Upload patron images in a batch or one at a time
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_anonymize_patrons' -%]
        <span class="sub_permission delete_anonymize_patrons_subpermission">
            Delete old borrowers and anonymize circulation history (deletes borrower checkout history)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'batch_extend_due_dates' -%]
        <span class="sub_permission batch_extend_due_dates_subpermission">
            Perform batch extend due dates
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_calendar' -%]
        <span class="sub_permission edit_calendar_subpermission">
            Define days when the library is closed
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_additional_contents' -%]
        <span class="sub_permission edit_additional_contents_subpermission">
            Write additional contents for the OPAC and staff interfaces (news and HTML customizations)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_notice_status_triggers' -%]
        <span class="sub_permission edit_notice_status_triggers_subpermission">
            Set notice/status triggers for overdue items
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_notices' -%]
        <span class="sub_permission edit_notices_subpermission">
            Define notices
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_patrons' -%]
        <span class="sub_permission edit_patrons_subpermission">
            Perform batch modification of patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_quotes' -%]
        <span class="sub_permission edit_quotes_subpermission">
            Edit quotes for quote-of-the-day feature
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'export_catalog' -%]
        <span class="sub_permission export_catalog_subpermission">
            Export bibliographic and holdings data
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'import_patrons' -%]
        <span class="sub_permission import_patrons_subpermission">
            Import patron data
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'inventory' -%]
        <span class="sub_permission inventory_subpermission">
            Perform inventory of your catalog
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'items_batchdel' -%]
        <span class="sub_permission items_batchdel_subpermission">
            Perform batch deletion of items
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'items_batchmod' -%]
        <span class="sub_permission items_batchmod_subpermission">
            Perform batch modification of items
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'items_batchmod_restricted' -%]
        <span class="sub_permission items_batchmod_restricted_subpermission">
            Limit batch item modification to subfields defined in the SubfieldsToAllowForRestrictedBatchmod preference (please note that items_batchmod is still required)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'label_creator' -%]
        <span class="sub_permission label_creator_subpermission">
            Create printable labels and barcodes from catalog and patron data
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_csv_profiles' -%]
        <span class="sub_permission manage_csv_profiles_subpermission">
            Manage CSV export profiles
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_patron_lists' -%]
        <span class="sub_permission manage_patron_lists_subpermission">
            Add, edit and delete patron lists and their contents
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_staged_marc' -%]
        <span class="sub_permission manage_staged_marc_subpermission">
            Manage staged MARC records, including completing and reversing imports
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'marc_modification_templates' -%]
        <span class="sub_permission marc_modification_templates_subpermission">
            Manage marc modification templates
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'moderate_comments' -%]
        <span class="sub_permission moderate_comments_subpermission">
            Moderate patron comments
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'moderate_tags' -%]
        <span class="sub_permission moderate_tags_subpermission">
            Moderate patron tags
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'records_batchdel' -%]
        <span class="sub_permission records_batchdel_subpermission">
            Perform batch deletion of records (bibliographic or authority)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'records_batchmod' -%]
        <span class="sub_permission records_batchmod_subpermission">
            Perform batch modification of records (biblios or authorities)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'rotating_collections' -%]
        <span class="sub_permission rotating_collections_subpermission">
            Manage rotating collections
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'schedule_tasks' -%]
        <span class="sub_permission schedule_tasks_subpermission">
            Schedule tasks to run
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'stage_marc_import' -%]
        <span class="sub_permission stage_marc_import_subpermission">
            Stage MARC records into the reservoir
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'upload_local_cover_images' -%]
        <span class="sub_permission upload_local_cover_images_subpermission">
            Upload local cover images
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'view_system_logs' -%]
        <span class="sub_permission view_system_logs_subpermission">
            Browse the system logs
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'check_expiration' -%]
        <span class="sub_permission check_expiration_subpermission">
            Check the expiration of a serial
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'claim_serials' -%]
        <span class="sub_permission claim_serials_subpermission">
            Claim missing serials
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'create_subscription' -%]
        <span class="sub_permission create_subscription_subpermission">
            Create a new subscription
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_subscription' -%]
        <span class="sub_permission delete_subscription_subpermission">
            Delete an existing subscription
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_subscription' -%]
        <span class="sub_permission edit_subscription_subpermission">
            Edit an existing subscription
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'receive_serials' -%]
        <span class="sub_permission receive_serials_subpermission">
            Serials receiving
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'renew_subscription' -%]
        <span class="sub_permission renew_subscription_subpermission">
            Renew a subscription
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'routing' -%]
        <span class="sub_permission routing_subpermission">
            Routing
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'superserials' -%]
        <span class="sub_permission superserials_subpermission">
            Manage subscriptions from any branch (only applies when IndependentBranches is used)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_reports' -%]
        <span class="sub_permission delete_reports_subpermission">
            Delete SQL reports
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'create_reports' -%]
        <span class="sub_permission create_reports_subpermission">
            Create SQL reports
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'execute_reports' -%]
        <span class="sub_permission execute_reports_subpermission">
            Execute SQL reports
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'add_reserves' -%]
        <span class="sub_permission add_reserves_subpermission">
            Add course reserves
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_reserves' -%]
        <span class="sub_permission delete_reserves_subpermission">
            Remove course reserves
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_courses' -%]
        <span class="sub_permission manage_courses_subpermission">
            Add, edit and delete courses
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'configure' -%]
        <span class="sub_permission configure_subpermission">
            Configure plugins
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage' -%]
        <span class="sub_permission manage_subpermission">
            Manage plugins ( install / uninstall )
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'report' -%]
        <span class="sub_permission report_subpermission">
            Use report plugins
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'tool' -%]
        <span class="sub_permission tool_subpermission">
            Use tool plugins
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_public_lists' -%]
        <span class="sub_permission delete_public_lists_subpermission">
            Delete public lists
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_public_lists' -%]
        <span class="sub_permission edit_public_lists_subpermission">
            Edit public lists (Name, settings, and permissions, but not explicitly contents)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_public_list_contents' -%]
        <span class="sub_permission edit_public_list_contents_subpermission">
            Edit public lists contents
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'upload_general_files' -%]
        <span class="sub_permission upload_general_files_subpermission">
            Upload any file
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'upload_manage' -%]
        <span class="sub_permission upload_manage_subpermission">
            Manage uploaded files (<em>Useless without upload_general_files</em>)
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'access_files' -%]
        <span class="sub_permission access_files_subpermission">
            Access to the files stored on the server
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_clubs' -%]
        <span class="sub_permission edit_clubs_subpermission">
            Create and edit clubs
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_templates' -%]
        <span class="sub_permission edit_templates_subpermission">
            Create and edit club templates
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'enroll' -%]
        <span class="sub_permission enroll_subpermission">
            Enroll patrons in clubs
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edi_manage' -%]
        <span class="sub_permission edi_manage_subpermission">
            Manage EDIFACT transmissions
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'reopen_closed_invoices' -%]
        <span class="sub_permission reopen_closed_invoices_subpermission">
            Reopen closed invoices
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'edit_invoices' -%]
        <span class="sub_permission edit_invoices_subpermission">
            Edit invoices
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_invoices' -%]
        <span class="sub_permission delete_invoices_subpermission">
            Delete invoices
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'merge_invoices' -%]
        <span class="sub_permission merge_invoices_subpermission">
            Merge invoices
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'delete_baskets' -%]
        <span class="sub_permission delete_baskets_subpermission">
            Delete baskets
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%# self_check %]
    [%- CASE 'self_checkin_module' -%]
        <span class="sub_permission self_checkin_module_subpermission">
            Log into the self check-in module. Note: this permission prevents the patron from using any other OPAC functionality
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'self_checkout_module' -%]
        <span class="sub_permission self_checkout_module_subpermission">
            Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_rota_items' -%]
        <span class="sub_permission manage_rota_items_subpermission">
            Add and remove items from rotas
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'manage_rotas' -%]
        <span class="sub_permission manage_rotas_subpermission">
            Create, edit and delete rotas
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%# cash_management %]
    [%- CASE 'manage_cash_registers' -%]
        <span class="sub_permission manage_cash_registers_subpermission">
            Add, edit and archive cash registers
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'takepayment' -%]
        <span class="sub_permission takepayment_subpermission">
            Access the point of sale page and take payments
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'cashup' -%]
        <span class="sub_permission cashup_subpermission">
            Perform cash register cashup action
        </span>
        <span class="permissioncode">([% name | html %])</span>
    [%- CASE 'anonymous_refund' -%]
        <span class="sub_permission anonymous_refund_subpermission">
            Perform anonymous refund actions
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%# problem_reports %]
    [%- CASE 'manage_problem_reports' -%]
        <span class="sub_permission manage_problem_reports_subpermission">
            Manage OPAC problem reports
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%# recalls %]
    [%- CASE 'manage_recalls' -%]
        <span class="sub_permission place_recalls_subpermission">
            Manage recalls for patrons
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%# identity_providers %]
    [%- CASE 'manage_identity_providers' -%]
        <span class="sub_permission manage_identity_providers_subpermission">
            Manage identity providers
        </span>
        <span class="permissioncode">([% name | html %])</span>
  [%- END -%]
[%- END -%]
