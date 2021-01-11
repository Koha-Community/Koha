$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
         INSERT IGNORE INTO systempreferences
         (variable, value, explanation, options, type) VALUES
         ('DefaultSaveRecordFileID', 'biblionumber', 'Defines whether the advanced cataloging editor will use the bibliographic record number or control number field to populate the name of the save file.', 'biblionumber|controlnumber', 'Choice')
    });
    NewVersion( $DBversion, 24108, "Add system preference SaveRecordbyControlNumber");
}
