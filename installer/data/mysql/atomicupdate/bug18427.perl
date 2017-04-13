$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # In order to be overcomplete, we check if the situation is what we expect
    if( !index_exists( 'serialitems', 'PRIMARY' ) ) {
        if( index_exists( 'serialitems', 'serialitemsidx' ) ) {
            $dbh->do(q|
ALTER TABLE serialitems ADD PRIMARY KEY (itemnumber), DROP INDEX serialitemsidx;
            |);
        } else {
            $dbh->do(q|ALTER TABLE serialitems ADD PRIMARY KEY (itemnumber)|);
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18427 - Add a primary key to serialitems)\n";
}
