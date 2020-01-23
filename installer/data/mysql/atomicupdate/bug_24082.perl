$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (25, 'anonymous_refund', 'Perform refund actions from cash registers')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23442 - Add a refund option to the point of sale system)\n";
}
