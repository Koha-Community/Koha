$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE payments_transactions ADD COLUMN manager_id int(11) default NULL AFTER user_branch" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3068: Add manager id to payments_transactions)\n";
}
