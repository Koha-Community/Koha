$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'subscription', 'pubdatepatternformat' ) ) {
        $dbh->do(q|ALTER TABLE subscription ADD pubdatepatternformat varchar(3) default NULL AFTER mana_id|);
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22188: Add column subscription.pubdatepatternformat)\n";
}
