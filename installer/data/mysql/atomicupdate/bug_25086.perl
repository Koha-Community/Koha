$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:

    $dbh->do( "ALTER TABLE borrower_modifications MODIFY changed_fields MEDIUMTEXT DEFAULT NULL" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25086, "Set changed_fields column of borrower_modifications as nullable");
}
