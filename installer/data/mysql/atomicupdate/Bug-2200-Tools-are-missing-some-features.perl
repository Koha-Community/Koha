$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "INSERT INTO permissions (module, code, description) VALUES ( 'tools','records_batchdel','Perform batch deletion of records (bibliographic or authority)');" );
    $dbh->do( "INSERT INTO permissions (module, code, description) VALUES ('tools','records_batchmod','Perform batch modification of records (biblios or authorities)');" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 2200 - Tools are missing some features)\n";
}