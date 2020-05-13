$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Migrate LOST_RETURNED to LOST_RETURN
    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          credit_type_code = 'LOST_RETURN'
        WHERE
          credit_type_code = 'LOST_RETURNED'
    });

    # Drop LOST_RETURNED credit type
    $dbh->do(qq{
        DELETE FROM account_credit_types WHERE code = 'LOST_RETURNED'
    });

    NewVersion( $DBversion, 25389, "Catch errant cases of LOST_RETURNED");
}
