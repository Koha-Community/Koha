$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    my $dbh = C4::Context->dbh;
    unless ( C4::Context->preference('NorwegianPatronDBEnable') ) {
        $dbh->do(q|
            DELETE FROM systempreferences
            WHERE variable IN ('NorwegianPatronDBEnable', 'NorwegianPatronDBEndpoint', 'NorwegianPatronDBUsername', 'NorwegianPatronDBPassword', 'NorwegianPatronDBSearchNLAfterLocalHit')
        |);
        if ( TableExists('borrower_sync') ) {
            $dbh->do(q|DROP TABLE borrower_sync|);
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21068 - Remove system preferences NorwegianPatronDB*)\n";
}
