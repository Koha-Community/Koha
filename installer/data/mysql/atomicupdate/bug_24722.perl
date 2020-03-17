$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        ALTER TABLE reserves MODIFY priority SMALLINT(6) NOT NULL
    |);

    $dbh->do(q|
        ALTER TABLE old_reserves MODIFY priority SMALLINT(6) NOT NULL
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24722 - Enforce NOT NULL constraint for reserves.priority)\n";
}
