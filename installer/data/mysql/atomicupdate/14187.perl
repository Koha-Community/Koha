$DBversion = '16.12.00.XXX';
if ( CheckVersion($DBversion) ) {
    unless (column_exists( 'branchtransfers', 'branchtransfer_id' )
        and index_exists( 'branchtransfers', 'PRIMARY' ) )
    {
        $dbh->do(
            "ALTER TABLE branchtransfers
                 ADD COLUMN branchtransfer_id int(12) NOT NULL auto_increment FIRST, ADD CONSTRAINT PRIMARY KEY (branchtransfer_id);"
        );
    }

    # Always end with this (adjust the bug info)
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 14187: branchtransfer needs a primary key (id) for DBIx and common sense.)\n";
}
