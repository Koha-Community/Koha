$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless( column_exists('aqbasket','create_items') ){
        $dbh->do(q{
            ALTER TABLE aqbasket
                ADD COLUMN create_items ENUM('ordering', 'receiving', 'cataloguing') default NULL AFTER is_standing
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15685: Allow creation of items (AcqCreateItem) to be customizable per-basket)\n";
}
