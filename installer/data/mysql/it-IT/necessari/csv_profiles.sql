INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type )
VALUES ( "issues to claim", "CSV export per fascicoli in ritardo", "FORNITORE=aqbooksellers.name|TITOLO=subscription.title|NUMERO FASC=serial.serialseq|IN RITARDO DAL=serial.planneddate", ",", "sql" );
