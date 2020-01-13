$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE biblioimages
            ADD `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                AFTER `thumbnail`;
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22987 - Add biblioimages.timestamp)\n";
}
