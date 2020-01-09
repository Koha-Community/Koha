$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_credit_types (code, description, can_be_added_manually, is_system)
            VALUES
              ('DISCOUNT', 'A discount applied to a patrons fine', 0, 1)
        }
    );

    $dbh->do(qq{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('DISCOUNT');
    });

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (10, 'discount', 'Perform account discount action')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 24081 - Add DISCOUNT to account_credit_types)\n";
    print "Upgrade to $DBversion done (Bug 24081 - Add DISCOUNT to account_offset_types)\n";
    print "Upgrade to $DBversion done (Bug 24081 - Add accounts discount permission)\n";
}
