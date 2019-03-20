INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type, used_for )
VALUES ( "issues to claim", "default CSV export for serial issue claims", "SUPPLIER=aqbooksellers.name|TITLE=subscription.title|ISSUE NUMBER=serial.serialseq|LATE SINCE=serial.planneddate", ",", "sql", "late_issues" );
