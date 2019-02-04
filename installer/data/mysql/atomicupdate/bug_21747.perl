$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'fine_increase' ), ( 'fine_decrease' );
    });

    $dbh->do(q{
        UPDATE account_offsets SET type = 'fine_increase' WHERE type = 'Fine Update' AND amount > 0;
    });

    $dbh->do(q{
        UPDATE account_offsets SET type = 'fine_decrease' WHERE type = 'Fine Update' AND amount < 0;
    });

    $dbh->do(q{
        DELETE FROM account_offset_types WHERE type = 'Fine Update';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21747 - Update account_offset_types to include 'fine_increase' and 'fine_decrease')\n";
}
