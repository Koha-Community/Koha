$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET variable='NotesToHide' WHERE variable = 'NotesBlacklist'" );
    print "Bug 25709: Rename systempreference to NotesToHide\n";
    SetVersion( $DBversion );
}
