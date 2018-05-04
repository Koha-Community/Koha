$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # From: https://stackoverflow.com/questions/3311903/remove-duplicate-rows-in-mysql
    $dbh->do(q|
DELETE a
FROM virtualshelfshares as a, virtualshelfshares as b
WHERE a.id < b.id AND a.borrowernumber IS NOT NULL AND a.borrowernumber=b.borrowernumber AND a.shelfnumber=b.shelfnumber
    |);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20754: Remove double accepted list shares)\n";
}
