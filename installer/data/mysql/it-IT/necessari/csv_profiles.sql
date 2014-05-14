INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type )
VALUES ( "issues to claim", "CSV export per fascicoli in ritardo", "SUPPLIER=aqbooksellers.name|TITLE=subscription.title|ISSUE NUMBER=serial.serialseq|LATE SINCE=serial.planneddate", ",", "sql" );
