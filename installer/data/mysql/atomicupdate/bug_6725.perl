$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('PatronDuplicateMatchingAddFields','surname|firstname|dateofbirth', NULL,'A list of fields separated by "|" to deduplicate patrons when created','Free')
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 6725, "Adds PatronDuplicateMatchingAddFields system preference");
}
