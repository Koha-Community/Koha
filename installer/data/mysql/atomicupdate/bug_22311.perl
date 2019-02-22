$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('OpacMoreSearches', '', NULL, 'Add additional elements to the OPAC more searches bar', 'Textarea')
    } );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22311 - Add a SysPref to allow adding content to the #moresearches div in the opac)\n";
}
