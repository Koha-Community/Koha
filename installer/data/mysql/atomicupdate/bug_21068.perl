$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    my $dbh = C4::Context->dbh;
    unless ( C4::Context->preference('NorwegianPatronDBEnable') ) {
        $dbh->do(q|
            DELETE FROM systempreferences
            WHERE variable IN ('NorwegianPatronDBEnable', 'NorwegianPatronDBEndpoint', 'NorwegianPatronDBUsername', 'NorwegianPatronDBPassword', 'NorwegianPatronDBSearchNLAfterLocalHit')
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21068 - Remove system preferences NorwegianPatronDB*)\n";
}
