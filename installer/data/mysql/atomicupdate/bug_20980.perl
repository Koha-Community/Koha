$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    # Add 'Manual Credit' offset type
    $dbh->do(q{
        INSERT IGNORE INTO `account_offset_types` (`type`) VALUES ('Manual Credit');
    });

    # Fix wrong account offsets / Manual credits
    $dbh->do(q{
        UPDATE account_offsets
        SET credit_id=debit_id,
            debit_id=NULL,
            type='Manual Credit'
        WHERE amount < 0 AND
              type='Manual Debit' AND
              debit_id IN
                (SELECT accountlines_id AS debit_id
                 FROM accountlines
                 WHERE accounttype='C');
    });

    # Fix wrong account offsets / Manually forgiven amounts
    $dbh->do(q{
        UPDATE account_offsets
        SET credit_id=debit_id,
            debit_id=NULL,
            type='Writeoff'
        WHERE amount < 0 AND
              type='Manual Debit' AND
              debit_id IN
                (SELECT accountlines_id AS debit_id
                 FROM accountlines
                 WHERE accounttype='FOR');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20980 - Manual credit offsets are stored as debits)\n";
}
