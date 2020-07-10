$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_credit_types (code, description, can_be_added_manually, is_system)
            VALUES
              ('CANCELLATION', 'A cancellation applied to a patron charge', 0, 1)
        }
    );

    $dbh->do(
        qq{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('CANCELLATION');
    }
    );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 24603, "Add CANCELLATION credit_type_code" );
}
