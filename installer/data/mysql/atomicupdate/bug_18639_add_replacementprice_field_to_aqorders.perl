$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'aqorders', 'replacementprice' ){
        $dbh->do( "ALTER TABLE  aqorders ADD COLUMN replacementprice DECIMAL(28,6)" );
        $dbh->do( "UPDATE aqorders set replacementprice = rrp WHERE replacementprice IS NULL" );
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18639 - Add replacementprice field to aqorders table)\n";
}
