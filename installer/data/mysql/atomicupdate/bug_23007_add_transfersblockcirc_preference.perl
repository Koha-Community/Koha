$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('TransfersBlockCirc','1',NULL,'Should the transfer modal block circulation staff from continuing scanning items','YesNo')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23007: Make transfer modals optionally block circ)\n";
}
