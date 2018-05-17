$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( column_exists( 'accountlines', 'dispute' ) ) {
        $dbh->do(q{
            ALTER TABLE `accountlines`
                DROP COLUMN `dispute`
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20777 - Remove unused field accountlines.dispute)\n";
}
