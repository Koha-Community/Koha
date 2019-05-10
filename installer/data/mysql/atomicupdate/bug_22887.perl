$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{ALTER TABLE `authorised_values` ADD CONSTRAINT `category_code` UNIQUE (category,authorised_value)} );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22887 - Add unique constraint to authorised_values)\n";
}
