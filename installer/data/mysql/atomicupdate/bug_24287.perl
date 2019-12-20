$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists('branchtransfers', 'reason') ) {
        $dbh->do(
            qq{
                ALTER TABLE branchtransfers
                ADD
                  `reason` enum('Manual')
                AFTER
                  comments
              }
        );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24287 - Add 'reason' field to transfers table)\n";
}
