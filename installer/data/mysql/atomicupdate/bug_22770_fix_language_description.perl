$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( 'UPDATE language_descriptions SET description = "Griechisch (Modern 1453-)"
      WHERE subtag = "el" and type = "language" and lang ="de"' );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22770 - Fix typo in language description for el in German)\n";
}
