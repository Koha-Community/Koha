SET FOREIGN_KEY_CHECKS=0;

INSERT INTO permissions (module_bit, code, description) VALUES
   ( 1, 'circulate_remaining_permissions', 'Permessi rimanenti per la circolazione'),
   ( 1, 'override_renewals', 'Sblocca i rinnovi bloccati'),
   (13, 'edit_news', 'Scrivi le news per l\'OPAC e per l\'interfaccia staff'),
   (13, 'label_creator', 'Crea etichette da stampare e barcodes dal catalogo e dai dati degli utenti'),
   (13, 'edit_calendar', 'Definisci i giorni di chiusura della biblioteca'),
   (13, 'moderate_comments', 'Modera i commenti degli utenti'),
   (13, 'edit_notices', 'Definisci gli avvisi'),
   (13, 'edit_notice_status_triggers', 'Imposta il messaggio o lo stato degli avvisi per le copie in ritardo'),
   (13, 'view_system_logs', 'Scorri i log di sistema'),
   (13, 'inventory', 'Lavora sugli inventari (stocktaking) del tuo catalogo'),
   (13, 'stage_marc_import', 'Opera sui Record MARC presenti nella zona di lavoro'),
   (13, 'manage_staged_marc', 'Gestisci i record MARC in lavorazione, inclusi il completare e il cancellare gli import'),
   (13, 'export_catalog', 'Esporta i dati bibliografici e di copia'),
   (13, 'import_patrons', 'Importa i dati utente'),
   (13, 'delete_anonymize_patrons', 'Cancella i vecchi prestiti e rendi anonimo lo storico della circolazione (canella in lettura lo storico utenti prestito)'),
   (13, 'batch_upload_patron_images', 'Aggiorna le foto utente in modalità batch o al momento'),
   (13, 'schedule_tasks', 'Schedula i task da far andare'),
   (13, 'manage_csv_profiles', 'Gestisci i profili CSV di export'),
   (15, 'check_expiration', 'Controlla la scadenza di una risora in continuazione'),
   (15, 'claim_serials', 'Richiedi i fascicoli non arrivati'),
   (15, 'create_subscription', 'Crea un nuovo abbonamento'),
   (15, 'delete_subscription', 'Cancella un abbonamento esistente'),
   (15, 'edit_subscription', 'Modifica un abbonamento esistente'),
   (15, 'receive_serials', 'Ricevi fascicoli'),
   (15, 'renew_subscription', 'Rinnova un abbonamento'),
   (15, 'routing', 'Routing')
;
SET FOREIGN_KEY_CHECKS=1;
