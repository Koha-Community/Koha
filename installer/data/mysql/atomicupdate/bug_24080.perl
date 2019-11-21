$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_debit_types (
              code,
              description,
              can_be_added_manually,
              default_amount,
              is_system
            )
            VALUES
              ('PAYOUT', 'Payment from library to patron', 0, NULL, 1)
        }
    );

    $dbh->do(qq{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('PAYOUT');
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 24080 - Add PAYOUT account_debit_type)\n";
    print "Upgrade to $DBversion done (Bug 24080 - Add PAYOUT account_offset_type)\n";
}
