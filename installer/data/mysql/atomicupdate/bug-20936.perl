$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('OPACHoldsHistory','0','','If ON, enables display of Patron Holds History in OPAC','YesNo')
    });

    NewVersion( $DBversion, 20936, "Add OPACHoldsHistory preferences");
}
