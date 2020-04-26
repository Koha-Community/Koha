$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
     $dbh->do( "UPDATE items set issues=0 where issues is null" );
     $dbh->do( "UPDATE deleteditems set issues=0 where issues is null" );
     $dbh->do( "ALTER TABLE items ALTER issues set default 0" );
     $dbh->do( "ALTER TABLE deleteditems ALTER issues set default 0" );
    # or perform some test and warn
    # if( !column_exists( 'biblio', 'biblionumber' ) ) {
    #    warn "There is something wrong";
    # }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 23081, "Set default to 0 for items.issues");
}
