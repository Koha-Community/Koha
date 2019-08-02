$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('PreserveSerialNotes','1','','When a new "Expected" issue is generated, should it be prefilled with last created issue notes?','YesNo');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23416 - Add PreserveSerialNotes syspref)\n";
}
