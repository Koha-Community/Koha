[%- BLOCK main_permissions -%]
    [% SWITCH name %]
    [%- CASE 'superlibrarian' -%]<span>Access to all librarian functions</span>
    [%- CASE 'circulate' -%]<span>Check out and check in items</span>
    [%- CASE 'catalogue' -%]<span><b>Required for staff login.</b> Staff access, allows viewing of catalogue in staff client.</span>
    [%- CASE 'parameters' -%]<span>Manage Koha system settings (Administration panel)</span>
    [%- CASE 'borrowers' -%]<span>Add, modify and view patron information</span>
    [%- CASE 'permissions' -%]<span>Set user permissions</span>
    [%- CASE 'reserveforothers' -%]<span>Place and modify holds for patrons</span>
    [%- CASE 'editcatalogue' -%]<span>Edit catalog (Modify bibliographic/holdings data)</span>
    [%- CASE 'updatecharges' -%]<span>Manage patrons fines and fees</span>
    [%- CASE 'acquisition' -%]<span>Acquisition and/or suggestion management</span>
    [%- CASE 'tools' -%]<span>Use all tools (expand for granular tools permissions)</span>
    [%- CASE 'editauthorities' -%]<span>Edit authorities</span>
    [%- CASE 'serials' -%]<span>Manage serial subscriptions</span>
    [%- CASE 'reports' -%]<span>Allow access to the reports module</span>
    [%- CASE 'staffaccess' -%]<span>Allow staff members to modify permissions for other staff members</span>
    [%- CASE 'coursereserves' -%]<span>Course reserves</span>
    [%- CASE 'plugins' -%]<span>Koha plugins</span>
    [%- CASE 'lists' -%]<span>Lists</span>
    [%- CASE 'clubs' -%]<span>Patron clubs</span>
    [%- CASE 'ill' -%]<span>Create and modify Interlibrary loan requests</span>
    [%- CASE 'self_check' -%]<span>Self check modules</span>
    [%- END -%]
[%- END -%]

[%- BLOCK sub_permissions -%]
  [% SWITCH name %]
    [%- CASE 'circulate_remaining_permissions' -%]<span>Remaining circulation permissions</span>
    [%- CASE 'force_checkout' -%]<span>Force checkout if a limitation exists</span>
    [%- CASE 'manage_restrictions' -%]<span>Manage restrictions for accounts</span>
    [%- CASE 'overdues_report' -%]<span>Execute overdue items report</span>
    [%- CASE 'override_renewals' -%]<span>Override blocked renewals</span>
    [%- CASE 'manage_checkout_notes' %]<span>Mark checkout notes as seen/not seen</span>
    [%- CASE 'manage_circ_rules' -%]<span>manage circulation rules</span>
    [%- CASE 'manage_circ_rules_restricted' -%]<span>Limit circulation rules editing to the user's own library (please note that manage_circ_rules is still required)</span>
    [%- CASE 'parameters_remaining_permissions' -%]<span>Remaining system parameters permissions</span>
    [%- CASE 'edit_borrowers' -%]<span>Add, modify and view patron information</span>
    [%- CASE 'view_borrower_infos_from_any_libraries' -%]<span>View patron infos from any libraries. If not set the logged in user could only access patron infos from its own library or group of libraries.</span>
    [%- CASE 'modify_holds_priority' -%]<span>Modify holds priority</span>
    [%- CASE 'place_holds' -%]<span>Place holds for patrons</span>
    [%- CASE 'delete_all_items' -%]<span>Delete all items at once</span>
    [%- CASE 'edit_catalogue' -%]<span>Edit catalog (Modify bibliographic/holdings data)</span>
    [%- CASE 'edit_items' -%]<span>Edit items</span>
    [%- CASE 'edit_items_restricted' -%]<span>Limit item modification to subfields defined in the SubfieldsToAllowForRestrictedEditing preference (please note that edit_item is still required)</span>
    [%- CASE 'fast_cataloging' -%]<span>Fast cataloging</span>
    [%- CASE 'remaining_permissions' -%]<span>Remaining permissions for managing fines and fees</span>
    [%- CASE 'writeoff' -%]<span>Write off fines and fees</span>
    [%- CASE 'suggestions_manage' -%]<span>Manage purchase suggestions</span>
    [%- CASE 'budget_add_del' -%]<span>Add and delete budgets (but can't modify budgets)</span>
    [%- CASE 'budget_manage' -%]<span>Manage budgets</span>
    [%- CASE 'budget_manage_all' -%]<span>Manage all budgets</span>
    [%- CASE 'budget_modify' -%]<span>Modify budget (can't create lines, but can modify existing ones)</span>
    [%- CASE 'contracts_manage' -%]<span>Manage contracts</span>
    [%- CASE 'group_manage' -%]<span>Manage basket groups</span>
    [%- CASE 'order_manage' -%]<span>Manage basket and order lines</span>
    [%- CASE 'order_manage_all' -%]<span>Manage all baskets and order lines, regardless of restrictions on them</span>
    [%- CASE 'order_receive' -%]<span>Receive orders and manage shipments</span>
    [%- CASE 'period_manage' -%]<span>Manage budgets</span>
    [%- CASE 'planning_manage' -%]<span>Manage budget plannings</span>
    [%- CASE 'vendors_manage' -%]<span>Manage vendors</span>
    [%- CASE 'currencies_manage' -%]<span>Manage currencies and exchange rates</span>
    [%- CASE 'batch_upload_patron_images' -%]<span>Upload patron images in a batch or one at a time</span>
    [%- CASE 'delete_anonymize_patrons' -%]<span>Delete old borrowers and anonymize circulation history (deletes borrower reading history)</span>
    [%- CASE 'edit_calendar' -%]<span>Define days when the library is closed</span>
    [%- CASE 'edit_news' -%]<span>Write news for the OPAC and staff interfaces</span>
    [%- CASE 'edit_notice_status_triggers' -%]<span>Set notice/status triggers for overdue items</span>
    [%- CASE 'edit_notices' -%]<span>Define notices</span>
    [%- CASE 'edit_patrons' -%]<span>Perform batch modification of patrons</span>
    [%- CASE 'edit_quotes' -%]<span>Edit quotes for quote-of-the-day feature</span>
    [%- CASE 'export_catalog' -%]<span>Export bibliographic and holdings data</span>
    [%- CASE 'import_patrons' -%]<span>Import patron data</span>
    [%- CASE 'inventory' -%]<span>Perform inventory of your catalog</span>
    [%- CASE 'items_batchdel' -%]<span>Perform batch deletion of items</span>
    [%- CASE 'items_batchmod' -%]<span>Perform batch modification of items</span>
    [%- CASE 'items_batchmod_restricted' -%]<span>Limit batch item modification to subfields defined in the SubfieldsToAllowForRestrictedBatchmod preference (please note that items_batchmod is still required)</span>
    [%- CASE 'label_creator' -%]<span>Create printable labels and barcodes from catalog and patron data</span>
    [%- CASE 'manage_csv_profiles' -%]<span>Manage CSV export profiles</span>
    [%- CASE 'manage_patron_lists' -%]<span>Add, edit and delete patron lists and their contents</span>
    [%- CASE 'manage_staged_marc' -%]<span>Managed staged MARC records, including completing and reversing imports</span>
    [%- CASE 'marc_modification_templates' -%]<span>Manage marc modification templates</span>
    [%- CASE 'moderate_comments' -%]<span>Moderate patron comments</span>
    [%- CASE 'moderate_tags' -%]<span>Moderate patron tags</span>
    [%- CASE 'records_batchdel' -%]<span>Perform batch deletion of records (bibliographic or authority)</span>
    [%- CASE 'records_batchmod' -%]<span>Perform batch modification of records (biblios or authorities)</span>
    [%- CASE 'rotating_collections' -%]<span>Manage rotating collections</span>
    [%- CASE 'schedule_tasks' -%]<span>Schedule tasks to run</span>
    [%- CASE 'stage_marc_import' -%]<span>Stage MARC records into the reservoir</span>
    [%- CASE 'upload_local_cover_images' -%]<span>Upload local cover images</span>
    [%- CASE 'view_system_logs' -%]<span>Browse the system logs</span>
    [%- CASE 'check_expiration' -%]<span>Check the expiration of a serial</span>
    [%- CASE 'claim_serials' -%]<span>Claim missing serials</span>
    [%- CASE 'create_subscription' -%]<span>Create a new subscription</span>
    [%- CASE 'delete_subscription' -%]<span>Delete an existing subscription</span>
    [%- CASE 'edit_subscription' -%]<span>Edit an existing subscription</span>
    [%- CASE 'receive_serials' -%]<span>Serials receiving</span>
    [%- CASE 'renew_subscription' -%]<span>Renew a subscription</span>
    [%- CASE 'routing' -%]<span>Routing</span>
    [%- CASE 'superserials' -%]<span>Manage subscriptions from any branch (only applies when IndependentBranches is used)</span>
    [%- CASE 'delete_reports' -%]<span>Delete SQL reports</span>
    [%- CASE 'create_reports' -%]<span>Create SQL reports</span>
    [%- CASE 'execute_reports' -%]<span>Execute SQL reports</span>
    [%- CASE 'add_reserves' -%]<span>Add course reserves</span>
    [%- CASE 'delete_reserves' -%]<span>Remove course reserves</span>
    [%- CASE 'manage_courses' -%]<span>Add, edit and delete courses</span>
    [%- CASE 'configure' -%]<span>Configure plugins</span>
    [%- CASE 'manage' -%]<span>Manage plugins ( install / uninstall )</span>
    [%- CASE 'report' -%]<span>Use report plugins</span>
    [%- CASE 'tool' -%]<span>Use tool plugins</span>
    [%- CASE 'delete_public_lists' -%]<span>Delete public lists</span>
    [%- CASE 'upload_general_files' -%]<span>Upload any file</span>
    [%- CASE 'upload_manage' -%]<span>Manage uploaded files (<i>Useless without upload_general_files</i>)</span>
    [%- CASE 'access_files' -%]<span>Access to the files stored on the server</span>
    [%- CASE 'edit_clubs' -%]<span>Create and edit clubs</span>
    [%- CASE 'edit_templates' -%]<span>Create and edit club templates</span>
    [%- CASE 'enroll' -%]<span>Enroll patrons in clubs</span>
    [%- CASE 'edi_manage' -%]<span>Manage EDIFACT transmissions</span>
  [%# self_check %]
    [%- CASE 'self_checkin_module' -%]<span>Log into the self check-in module. Note: this permission prevents the patron from using any other OPAC functionality</span>
    [%- CASE 'self_checkout_module' -%]<span>Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID</span>
  [%- END -%]
[%- END -%]
