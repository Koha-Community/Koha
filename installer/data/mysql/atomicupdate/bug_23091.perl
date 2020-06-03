$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE circulation_rules SET rule_name = 'lostreturn' WHERE rule_name = 'refund'" );
    $dbh->do( "UPDATE circulation_rules SET rule_value = 'refund' WHERE rule_name = 'lostreturn' AND rule_value = 1" );

    NewVersion( $DBversion, 23091, "Update refund rules");
}
