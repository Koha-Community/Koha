INSERT INTO permissions (module_bit, code, description) VALUES
   ( 1, 'circulate_remaining_permissions', 'Remaining circulation permissions'),
   ( 1, 'override_renewals', 'Override blocked renewals'),
   (13, 'edit_news', 'Write news for the OPAC and staff interfaces'),
   (13, 'label_creator', 'Create printable labels and barcodes from catalog and patron data'),
   (13, 'edit_calendar', 'Define days when the library is closed'),
   (13, 'moderate_comments', 'Moderate patron comments'),
   (13, 'edit_notices', 'Define notices'),
   (13, 'edit_notice_status_triggers', 'Set notice/status triggers for overdue items'),
   (13, 'view_system_logs', 'Browse the system logs'),
   (13, 'inventory', 'Perform inventory (stocktaking) of your catalogue'),
   (13, 'stage_marc_import', 'Stage MARC records into the reservoir'),
   (13, 'manage_staged_marc', 'Managed staged MARC records, including completing and reversing imports'),
   (13, 'export_catalog', 'Export bibliographic and holdings data'),
   (13, 'import_patrons', 'Import patron data'),
   (13, 'delete_anonymize_patrons', 'Delete old borrowers and anonymize circulation history (deletes borrower reading history)'),
   (13, 'batch_upload_patron_images', 'Upload patron images in batch or one at a time'),
   (13, 'schedule_tasks', 'Schedule tasks to run')
;
