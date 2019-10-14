$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my ($socialnetworks) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='socialnetworks';
    |);
    if( $socialnetworks ){
        # If the socialnetworks preference is enabled, enable all social networks
        $dbh->do("UPDATE systempreferences SET value = 'email,facebook,linkedin,twitter', explanation = 'email|facebook|linkedin|twitter', type = 'multiple'  WHERE variable = 'SocialNetworks'");
    } else {
        $dbh->do("UPDATE systempreferences SET value = '', explanation = 'email|facebook|linkedin|twitter', type = 'multiple'  WHERE variable = 'SocialNetworks'");
    }
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 22880: Allow granular control of socialnetworks preference)\n";
}
