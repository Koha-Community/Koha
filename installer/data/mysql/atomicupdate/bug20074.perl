$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0|);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20074: Auth_subfield_structure changes hidden attribute)\n";
}
