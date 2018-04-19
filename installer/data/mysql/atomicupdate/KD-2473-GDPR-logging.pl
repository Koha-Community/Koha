$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('BorrowersViewLog','0',NULL,'If ON, log view actions on patron data','YesNo')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-2473 - GDRP logging)\n";
}