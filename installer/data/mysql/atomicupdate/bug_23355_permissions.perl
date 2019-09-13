$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (25, 'cashup', 'Perform cash register cashup action')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23355 - Add cash register cashup permissions)\n";
}
