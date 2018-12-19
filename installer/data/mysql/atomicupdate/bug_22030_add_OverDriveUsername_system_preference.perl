$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('OverDriveUsername','cardnumber','cardnumber|userid','Which patron information should be passed as OverDrive username','Choice')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
