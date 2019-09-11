$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (25, 'takepayment', 'Access the point of sale page and take payments')
    });


    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23354 - Add point of sale permissions)\n";
}
