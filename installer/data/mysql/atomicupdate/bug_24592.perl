$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add LOST_FOUND debit type
    $dbh->do(qq{
        INSERT IGNORE INTO
          account_credit_types ( code, description, can_be_added_manually, is_system )
        VALUES
          ('LOST_FOUND', 'Lost item fee refund', 0, 1)
    });

    # Migrate LOST_RETURN to LOST_FOUND
    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          credit_type_code = 'LOST_FOUND'
        WHERE
          credit_type_code = 'LOST_RETURN'
    });

    # Migrate LOST + RETURNED to LOST + FOUND
    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          status = 'FOUND'
        WHERE
          debit_type_code = 'LOST'
        AND
          status = 'RETURNED'
    });

    # Drop LOST_RETURNED credit type
    $dbh->do(qq{
        DELETE FROM account_credit_types WHERE code = 'LOST_RETURN'
    });

    # Add Lost Item Found offset type
    $dbh->do(qq{
        INSERT IGNORE INTO
          account_offset_types ( type )
        VALUES
          ( 'Lost Item Found' )
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24592 - Update LOST_RETURN to LOST_FOUND)\n";
}
