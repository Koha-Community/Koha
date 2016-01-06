INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
    SELECT 'ExportCircHistory', COUNT(*), NULL, "Display the export circulation options",  'YesNo'
    FROM systempreferences
    WHERE ( variable = 'ExportRemoveFields' AND value != "" AND value IS NOT NULL )
        OR ( variable = 'ExportWithCsvProfile' AND value != "" AND value IS NOT NULL );
DELETE FROM systempreferences WHERE variable="ExportWithCsvProfile";
