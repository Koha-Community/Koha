$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists('branchtransfers', 'daterequested') ) {
        $dbh->do(
            qq{
                ALTER TABLE branchtransfers
                ADD
                  `daterequested` timestamp NOT NULL default CURRENT_TIMESTAMP
                AFTER
                  `itemnumber`
              }
        );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23092 - Add 'daterequested' field to transfers table)\n";
}
