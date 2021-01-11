$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
         INSERT IGNORE INTO systempreferences
         (variable, value, explanation, options, type) VALUES
         ('SaveRecordbyControlNumber', '0', 'If set, advanced cataloging editor will use the control number field to populate the name of the save file, otherwise it uses the biblionumber.', NULL, 'YesNo')
    });
    NewVersion( $DBversion, 24108, "Add system preference SaveRecordbyControlNumber");
}
