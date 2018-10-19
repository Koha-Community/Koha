$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "alter table statistics change column ccode ccode varchar(80) default NULL" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21617: Make statistics.ccode longer)\n";
}
