$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $where = q|host='clio-db.cc.columbia.edu' AND port=7090|;
    my $sql = "SELECT COUNT(*) FROM z3950servers WHERE $where";
    my ( $cnt ) = $dbh->selectrow_array( $sql );
    if( $cnt ) {
        $dbh->do( "DELETE FROM z3950servers WHERE $where" );
        print "Removed $cnt Z39.50 target(s) for Columbia University\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19043 - Z39.50 target for Columbia University is no longer publicly available.)\n";
}
