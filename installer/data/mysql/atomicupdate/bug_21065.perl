$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        ALTER TABLE accountlines DROP FOREIGN KEY accountlines_ibfk_1;
    |);
    $dbh->do(q|
        ALTER TABLE accountlines CHANGE COLUMN borrowernumber borrowernumber INT(11) DEFAULT NULL;
    |);
    $dbh->do(q|
        ALTER TABLE accountlines ADD CONSTRAINT accountlines_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE SET NULL ON UPDATE CASCADE;
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21065 - Set ON DELETE SET NULL on accountlines.borrowernumber)\n";
}
