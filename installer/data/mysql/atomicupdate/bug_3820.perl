$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE action_logs SET info = REPLACE(info,'cardnumber_replaced','cardnumber') WHERE module='MEMBERS' AND action='MODIFY'" );
    $dbh->do( "UPDATE action_logs SET info = REPLACE(info,'previous_cardnumber','before') WHERE module='MEMBERS' AND action='MODIFY'" );
    $dbh->do( "UPDATE action_logs SET info = REPLACE(info,'new_cardnumber','after') WHERE module='MEMBERS' AND action='MODIFY'" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 3820 - Update patron modification logs)\n";
}
