$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion )  ) {
    $dbh->do("ALTER TABLE branchtransfers ADD COLUMN branchtransfer_id int(12) NOT NULL auto_increment FIRST, ADD CONSTRAINT PRIMARY KEY (branchtransfer_id);");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14187 - branchtransfer needs a primary key (id) for DBIx and common sense.)\n";
}
