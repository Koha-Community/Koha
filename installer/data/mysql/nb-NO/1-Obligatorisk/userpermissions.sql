-- 
-- Permissions for Koha.
--
-- Copyright (C) 2011 Magnus Enger Libriotech
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License, or (at your option) any later
-- version.
-- 
-- Koha is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with Koha; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

INSERT INTO permissions (module_bit, code, description) VALUES
   ( 1, 'circulate_remaining_permissions', 'Øvrige rettigheter for sirkulasjon'),
   ( 1, 'override_renewals', 'Overstyre blokkerte fornyinger'),
   ( 1, 'overdues_report', 'Execute overdue items report'),
   ( 1, 'force_checkout', 'Force checkout if a limitation exists'),
   ( 1, 'manage_restrictions', 'Manage restrictions for accounts'),
   ( 3, 'parameters_remaining_permissions', 'Øvrige rettigheter knyttet til systempreferanser'),
   ( 3, 'manage_circ_rules', 'Endre sirkulasjonsregler'),
   ( 6, 'place_holds', 'Foreta reservering for lånere'),
   ( 6, 'modify_holds_priority', 'Endre rekkefølge på reserveringer'),
   ( 9, 'edit_catalogue', 'Endre katalogen (Endre bibliografiske poster og eksemplaropplysninger)'),
   ( 9, 'fast_cataloging', 'Hurtigkatalogisering'),
   ( 9, 'edit_items', 'Endre eksmeplarer'),
   (10, 'writeoff', 'Write off fines and fees'),
   (10, 'remaining_permissions', 'Remaining permissions for managing fines and fees'),
   (11, 'vendors_manage', 'Administrere leverandører'),
   (11, 'contracts_manage', 'Administrere kontrakter'),
   (11, 'period_manage', 'Administrere perioder'),
   (11, 'budget_manage', 'Administrere budsjetter'),
   (11, 'budget_modify', 'Endre budsjetter (kan ikke legge til kontolinjer, men endre eksisterende)'),
   (11, 'planning_manage', 'Administrere budsjettplaner'),
   (11, 'order_manage', 'Administrere bestillinger og kurver'),
   (11, 'order_manage_all', 'Manage all orders and baskets, regardless of restrictions on them'),
   (11, 'group_manage', 'Administrere bestillinger og kurv-grupper'),
   (11, 'order_receive', 'Administrere bestillinger og kurver'),
   (11, 'budget_add_del', 'Legge til og slette budsjetter (men ikke endre budsjetter)'),
   (11, 'budget_manage_all', 'Administrere alle budsjetter'),
   (13, 'edit_news', 'Legge ut nyhter i OPACen og det interne grensesnittet'),
   (13, 'label_creator', 'Lage etiketter og strekkoder basert på bibliografiske poster og lånerdata'),
   (13, 'edit_calendar', 'Definere dager da biblioteket er stengt'),
   (13, 'moderate_comments', 'Behandle kommentarer fra lånere'),
   (13, 'edit_notices', 'Definere meldinger'),
   (13, 'edit_notice_status_triggers', 'Definere utløsere for meldinger og statusenderinger for for sent leverte dokumenter'),
   (13, 'edit_quotes', 'Endre sitater for dagens sitat-funksjonen'),
   (13, 'view_system_logs', 'Se Koha sine logger'),
   (13, 'inventory', 'Foreta varetelling'),
   (13, 'stage_marc_import', 'Importere MARC-poster til brønnen'),
   (13, 'manage_staged_marc', 'Behandle lagrede MARC-poster, inkludert ferdigstilling og reversering av importer'),
   (13, 'export_catalog', 'Eksportere bibliografiske data og beholdningsdata'),
   (13, 'import_patrons', 'Importere låneropplysninger'),
   (13, 'edit_patrons', 'Utføre satsvise endringer av lånere'),
   (13, 'delete_anonymize_patrons', 'Slette utgåtte lånere og anonymisere lånehistorikk'),
   (13, 'batch_upload_patron_images', 'Laste opp bilder av lånere enkeltvis eller en masse'),
   (13, 'schedule_tasks', 'Planlegge oppgaver som skal kjøres'),
   (13, 'items_batchmod', 'Utføre masseendringer av eksemplarer'),
   (13, 'items_batchdel', 'Utføre masseslettinger av eksemplarer'),
   (13, 'manage_csv_profiles', 'Administrere CSV eksportprofiler'),
   (13, 'moderate_tags', 'Behandle tagger fra lånere'),
   (13, 'rotating_collections', 'Administrere roterende samlinger'),
   (13, 'upload_local_cover_images', 'Laste opp lokale omslagsbilder'),
   (13, 'manage_patron_lists', 'Add, edit and delete patron lists and their contents'),
   (13, 'marc_modification_templates', 'Manage marc modification templates'),
   (15, 'check_expiration', 'Sjekke utløpsdato for et periodikum'),
   (15, 'claim_serials', 'Purre manglende tidsskrifthefter'),
   (15, 'create_subscription', 'Opprette abonnementer'),
   (15, 'delete_subscription', 'Slette eksisterende abonnementer'),
   (15, 'edit_subscription', 'Endre eksisterende abonnementer'),
   (15, 'receive_serials', 'Heftemottak'),
   (15, 'renew_subscription', 'Fornye abonnementer'),
   (15, 'routing', 'Sirkulasjon'),
   (15, 'superserials', 'Manage subscriptions from any branch (only applies when IndependantBranches is used)'),
   (16, 'execute_reports', 'Kjøre SQL-rapporter'),
   (16, 'create_reports', 'Opprette SQL-rapporter'),
   (18, 'manage_courses', 'Add, edit and delete courses'),
   (18, 'add_reserves', 'Add course reserves'),
   (18, 'delete_reserves', 'Remove course reserves'),
   (19, 'manage', 'Manage plugins ( install / uninstall )'),
   (19, 'tool', 'Use tool plugins'),
   (19, 'report', 'Use report plugins'),
   (19, 'configure', 'Configure plugins')
;
