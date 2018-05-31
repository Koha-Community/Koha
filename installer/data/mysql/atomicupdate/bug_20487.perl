$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
UPDATE items LEFT JOIN issues USING (itemnumber)
SET items.onloan = NULL
WHERE issues.itemnumber IS NULL
    |);

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20487: Clear items.onloan for unissued items)\n";
}
