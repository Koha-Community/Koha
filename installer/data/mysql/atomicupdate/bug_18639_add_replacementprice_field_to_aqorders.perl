$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE  aqorders ADD COLUMN replacementprice DECIMAL(28,6)" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18639 - Add replacementprice field to aqorders table)\n";
}
