INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type, used_for )
VALUES ( "Réclamation de numéros", "Export CSV par défaut pour la réclamation de numéros de périodiques", "FOURNISSEUR=aqbooksellers.name|TITRE=subscription.title|NUMÉRO=serial.serialseq|EN RETARD DEPUIS=serial.planneddate", ",", "sql", "late_issues" );
