$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_credit_types (code, description, can_be_added_manually, is_system)
            VALUES
              ('REFUND', 'A refund applied to a patrons fine', 0, 1)
        }
    );

    $dbh->do(qq{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('REFUND');
    });

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (10, 'refund', 'Perform account refund action')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23442 - Add REFUND to account_credit_types)\n";
    print "Upgrade to $DBversion done (Bug 23442 - Add REFUND to account_offset_types)\n";
    print "Upgrade to $DBversion done (Bug 23442 - Add accounts refund permission)\n";
}
