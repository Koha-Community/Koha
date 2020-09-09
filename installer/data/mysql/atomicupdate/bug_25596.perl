$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_credit_types (code, description, can_be_added_manually, is_system)
            VALUES
              ('OVERPAYMENT', 'Overpayment refund', 0, 1)
        }
    );

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_offset_types ( type ) VALUES ('Overpayment');
        }
    );

    $dbh->do(
        qq{
            UPDATE accountlines SET credit_type_code = 'OVERPAYMENT' WHERE credit_type_code = 'CREDIT' AND description = 'Overpayment refund'
        }
    );

    NewVersion( $DBversion, 25596, "Add OVERPAYMENT credit type" );
}
